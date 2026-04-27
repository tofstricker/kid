import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'permission_screen.dart';

class ChildLinkScreen extends StatefulWidget {
  @override
  _ChildLinkScreenState createState() => _ChildLinkScreenState();
}

class _ChildLinkScreenState extends State<ChildLinkScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final TextEditingController _codeController = TextEditingController();
  bool isLoading = false;
  String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0A0A0A),
      appBar: AppBar(title: Text("Link to Parent"), backgroundColor: Colors.transparent),
      body: Padding(
        padding: EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(Icons.link, size: 80, color: Colors.blue),
            SizedBox(height: 24),
            Text(
              "Getting Started",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              "Enter the 6-digit code shown on your parent's KiteControl dashboard to link this account.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 48),
            TextField(
              controller: _codeController,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              maxLength: 6,
              style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 12),
              decoration: InputDecoration(
                counterText: "",
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey[800]!)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
              ),
            ),
            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(errorMessage!, style: TextStyle(color: Colors.red), textAlign: TextAlign.center),
              ),
            SizedBox(height: 48),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: isLoading 
                ? CircularProgressIndicator(color: Colors.white) 
                : Text("Link Device", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              onPressed: _handleLinking,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLinking() async {
    final code = _codeController.text;
    if (code.length != 6) {
      setState(() => errorMessage = "Please enter a 6-digit code");
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final String childUid = FirebaseAuth.instance.currentUser!.uid;

    try {
      final query = await _db.collection('pairing_codes')
          .where('code', isEqualTo: code)
          .where('isUsed', isEqualTo: false)
          .where('expiresAt', isGreaterThan: Timestamp.now())
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        throw Exception("Invalid or expired code");
      }

      final doc = query.docs.first;
      final familyId = doc.data()['familyId'];

      WriteBatch batch = _db.batch();
      
      batch.update(doc.reference, {'isUsed': true});
      batch.update(_db.collection('users').doc(childUid), {
        'familyId': familyId,
      });

      await batch.commit();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Account successfully linked!"), backgroundColor: Colors.green),
      );
      
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => PermissionScreen()));
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = "Linking failed. Check the code and try again.";
      });
      print("Linking error: $e");
    }
  }
}
