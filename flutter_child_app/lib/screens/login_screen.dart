import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'permission_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();

  String email = '';
  String password = '';
  bool isLoading = false;
  String? errorMessage;

  void _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => PermissionScreen()));
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = "An unexpected error occurred.";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0A0A0A),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(32.0),
          child: Form(
            key: _formKey,
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
                  "Parents, please log in with your account to link this child device.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                SizedBox(height: 40),
                if (errorMessage != null) ...[
                  Text(errorMessage!, style: TextStyle(color: Colors.red), textAlign: TextAlign.center),
                  SizedBox(height: 16),
                ],
                TextFormField(
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Parent's Email",
                    labelStyle: TextStyle(color: Colors.grey),
                    prefixIcon: Icon(Icons.email, color: Colors.blue),
                    filled: true,
                    fillColor: Colors.black,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onChanged: (val) => setState(() => email = val),
                  validator: (val) => val != null && val.contains("@") ? null : "Enter a valid email",
                ),
                SizedBox(height: 16),
                TextFormField(
                  obscureText: true,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Password",
                    labelStyle: TextStyle(color: Colors.grey),
                    prefixIcon: Icon(Icons.lock, color: Colors.blue),
                    filled: true,
                    fillColor: Colors.black,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onChanged: (val) => setState(() => password = val),
                  validator: (val) => val != null && val.length >= 6 ? null : "Password must be at least 6 characters",
                ),
                SizedBox(height: 32),
                isLoading
                    ? Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text("Login Configuration", style: TextStyle(fontSize: 16)),
                        onPressed: _login,
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
