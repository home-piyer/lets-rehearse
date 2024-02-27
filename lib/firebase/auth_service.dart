import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
// Import for Apple sign-in
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
  
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      print("Error signing in with Google: $e");
      return null;
    }
  }

  static Future<UserCredential?> signInWithApple() async {
    try {
      // Check if the platform is iOS or Android
      if (!Platform.isIOS && !Platform.isAndroid) {
        print("Sign in with Apple is not available on this platform");
        return null;
      }

      // Trigger the authentication flow
      final appleIdCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Create an OAuthCredential for signing in
      final OAuthCredential credential = OAuthProvider("apple.com").credential(
        idToken: appleIdCredential.identityToken,
        accessToken: appleIdCredential.authorizationCode,
      );

      // Sign in the user with Firebase
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      print("Error signing in with Apple: $e");
      return null;
    }
  }
}
