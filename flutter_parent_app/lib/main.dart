import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';

bool isFirebaseInitialized = false;
String? firebaseError;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    isFirebaseInitialized = true;
  } catch (e) {
    isFirebaseInitialized = false;
    firebaseError = e.toString();
  }
  runApp(KiteControlApp());
}

class KiteControlApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KiteControl Parent',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.orange,
        fontFamily: 'Inter',
      ),
      home: isFirebaseInitialized ? AuthWrapper() : FirebaseSetupErrorScreen(error: firebaseError),
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
                "You need to provide your GoogleService-Info.plist and google-services.json files, or define FirebaseOptions.",
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

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(body: Center(child: Text("Auth Error: \${snapshot.error}")));
        }
        if (snapshot.connectionState == ConnectionState.active) {
          User? user = snapshot.data;
          if (user == null) {
            return LoginScreen();
          }
          return DashboardScreen();
        }
        return Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}
