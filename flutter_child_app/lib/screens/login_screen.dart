import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'child_link_screen.dart';
import 'permission_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  bool isLoading = false;
  String? errorMessage;

  void _setupDevice() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final childId = DateTime.now().millisecondsSinceEpoch.toString();
      final childEmail = 'child_$childId@kitecontrol.local';
      final childPassword = childId + "secure";
      UserCredential cred = await _auth.createUserWithEmailAndPassword(email: childEmail, password: childPassword);
      
      final doc = await _db.collection('users').doc(cred.user!.uid).get();
      if (!doc.exists) {
        await _db.collection('users').doc(cred.user!.uid).set({
          'email': childEmail,
          'displayName': 'My Child Device',
          'role': 'CHILD',
          'familyId': '',
          'createdAt': FieldValue.serverTimestamp(),
        });
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => ChildLinkScreen()));
      } 
    } catch (e) {
      setState(() {
        errorMessage = "An unexpected error occurred: $e";
        isLoading = false;
      });
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0A0A0A),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(Icons.child_care, size: 80, color: Colors.blue),
              SizedBox(height: 16),
              Text(
                "KiteControl Child",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                "Start securing this device.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              SizedBox(height: 40),
              if (errorMessage != null) ...[
                Text(errorMessage!, style: TextStyle(color: Colors.red), textAlign: TextAlign.center),
                SizedBox(height: 16),
              ],
              isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text("Setup Device", style: TextStyle(fontSize: 16, color: Colors.white)),
                      onPressed: _setupDevice,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
