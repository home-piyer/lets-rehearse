import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _name = '';
  String? _imagePath;
  final TextEditingController _nameController = TextEditingController();
  final user = FirebaseAuth.instance.currentUser!;
  late DocumentReference<Map<String, dynamic>> _userDoc;

  @override
  void initState() {
    super.initState();
    _userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userData = await _userDoc.get();
    setState(() {
      _name = userData['name'] ?? '';
      _nameController.text = _name;
      _imagePath = userData['imagePath'];
    });
  }

  Future<void> _saveUserData() async {
    await _userDoc.set({'name': _name, 'imagePath': _imagePath});
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
        _saveUserData(); // Save user data after updating image path
      });
    }
  }

  void _logout() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        title: const Text('Settings'),
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
          GestureDetector(
            onTap: _pickImage,
            child: CircleAvatar(
              backgroundColor: Color.fromARGB(255, 245, 239, 247),
              radius: 85,
              backgroundImage:
                  _imagePath != null ? FileImage(File(_imagePath!)) : null,
              child: _imagePath == null
                  ? Icon(Icons.camera_alt,
                      size: 60, color: Color.fromARGB(255, 75, 31, 83))
                  : null,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
              onChanged: (value) {
                setState(() {
                  _name = value;
                  _saveUserData();
                });
              },
            ),
          ),
          ElevatedButton(
            onPressed: _logout,
            style: ButtonStyle(
              minimumSize: MaterialStateProperty.all(Size(195, 45)),
              backgroundColor:
                  MaterialStateProperty.all(Color.fromARGB(255, 75, 31, 83)),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
            ),
            child: Text(
              'Log Out',
              style: TextStyle(
                fontSize: 19,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(
            height: 13.0,
          ),
          TextButton(
            child: Text(
              'Delete Account',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            onPressed: _deleteAccount,
            style: ButtonStyle(
              textStyle: MaterialStateProperty.all(
                  const TextStyle(decoration: TextDecoration.underline)),
              minimumSize: MaterialStateProperty.all(Size(195, 45)),
              foregroundColor: MaterialStateProperty.all(
                Color.fromARGB(255, 75, 31, 83), // Text color
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _deleteAccount() {
    // Show a confirmation dialog before deleting the account
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete Account"),
          content: Text("Are you sure you want to delete your account?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                await _userDoc.delete(); // Delete user document from Firestore
                await user.delete(); // Delete user account
                Navigator.of(context).pop(); // Close the dialog
                _logout(); // Log out user
              },
              child: Text("Delete"),
            ),
          ],
        );
      },
    );
  }
}
