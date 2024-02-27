import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:solo_rehearsal/firebase/login_or_register_page.dart';
import 'package:solo_rehearsal/main_page.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Inside AuthPage's StreamBuilder
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator(); // Loading indicator
          } else if (snapshot.hasData) {
            return MainPage(); // Navigate to MainPage if user is logged in
          } else {
            return LoginOrRegisterPage(); // Show login or register page
          }
        },
      ),
    );
  }
}
