import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/blocking_service.dart';
import 'services/usage_sync_service.dart';
import 'services/camera_service.dart';
import 'screens/permission_screen.dart';
import 'screens/login_screen.dart';
import 'dart:async';

bool isFirebaseInitialized = false;
String? firebaseError;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp();
    isFirebaseInitialized = true;
    
    // Configure Offline Persistence for Reliable Rule Enforcement
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
    
    // Initialize Enforcement Engines
    final blocking = BlockingService();
    final usage = UsageSyncService();
    final camera = CameraService();
    
    blocking.startEnforcementEngine();
    camera.startSnapshotListener();
    
    // Setup periodic usage syncing (every 5 minutes)
    Timer.periodic(Duration(minutes: 5), (_) => usage.syncUsageStats());
  } catch (e) {
    isFirebaseInitialized = false;
    firebaseError = e.toString();
  }

  runApp(KiteChildGuardianApp());
}

class KiteChildGuardianApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KiteControl Guardian',
      theme: ThemeData.dark(),
      home: isFirebaseInitialized ? AuthWrapper() : FirebaseSetupErrorScreen(error: firebaseError),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          User? user = snapshot.data;
          if (user == null) {
            return LoginScreen();
          }
          return PermissionScreen();
        }
        return Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}

class FirebaseSetupErrorScreen extends StatelessWidget {
  final String? error;
  FirebaseSetupErrorScreen({this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Setup Required")),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 64),
              SizedBox(height: 24),
              Text(
                "Firebase Not Configured",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                "You need to provide your GoogleService-Info.plist and google-services.json files.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[400]),
              ),
              if (error != null) ...[
                 SizedBox(height: 24),
                 Text(error!, style: TextStyle(color: Colors.red[300], fontSize: 12), textAlign: TextAlign.center),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
