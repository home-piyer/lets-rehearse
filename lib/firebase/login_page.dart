import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:solo_rehearsal/firebase/auth_page.dart';
import 'package:solo_rehearsal/components/my_button.dart';
import 'package:solo_rehearsal/components/my_textfield.dart';
import 'package:solo_rehearsal/components/square_tile.dart';
import 'package:solo_rehearsal/firebase/auth_service.dart';

class MyButton extends StatelessWidget {
  final String text;
  final Function()? onTap;
  final BorderRadius borderRadius;
  final Color backgroundColor;

  MyButton({
    required this.text,
    required this.onTap,
    required this.borderRadius,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 300, // Adjust the width as needed
        height: 60, // Adjust the height as needed
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          color: backgroundColor,
        ),
        padding: const EdgeInsets.symmetric(
            vertical: 16.0,
            horizontal: 20.0), // Adjust padding for height and width
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class MyTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final BorderRadius borderRadius;
  final double width; // Add width property
  final double height; // Add height property

  MyTextField({
    required this.controller,
    required this.hintText,
    required this.obscureText,
    required this.borderRadius,
    this.width = double.infinity, // Default width to match parent's width
    this.height = 60.0, // Default height
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width, // Apply width here
      height: height, // Apply height here
      margin: EdgeInsets.symmetric(horizontal: 25.0),
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        color: Colors.grey[200],
      ),
      child: Center(
        child: TextField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hintText,
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 20.0),
          ),
        ),
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  final Function()? onTap;
  const LoginPage({Key? key, required this.onTap}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // text editing controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // sign user in method
  void signUserIn() async {
    //show loading circle
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    //try sign in
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      showErrorMessage(e.code);
    }
  }

  void showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.deepPurple,
          title: Center(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                // logo
                Image.asset(
                  'lib/images/script.png',
                  width: 200, // Set the width to make the image smaller
                ),

                const SizedBox(height: 50),

                // welcome back, you've been missed!
                Text(
                  'Welcome back you\'ve been missed!',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 25),

                // username textfield
                MyTextField(
                  controller: emailController,
                  hintText: 'Email',
                  obscureText: false,
                  borderRadius:
                      BorderRadius.circular(30), // Set the border radius
                ),

                const SizedBox(height: 10),

                // password textfield
                MyTextField(
                  controller: passwordController,
                  hintText: 'Password',
                  obscureText: true,
                  borderRadius:
                      BorderRadius.circular(30), // Set the border radius
                ),

                const SizedBox(height: 10),

                // forgot password?
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Forgot Password?',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // sign in button
                MyButton(
                  text: "Sign In",
                  onTap: signUserIn,
                  borderRadius:
                      BorderRadius.circular(30), // Set the border radius
                  backgroundColor: Color.fromARGB(255, 75, 31, 83),
                ),

                const SizedBox(height: 50),

                // or continue with
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Colors.grey[400],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          'Or continue with',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 50),

                // google + apple sign in buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // google button
                    IconButton(
                      icon: SquareTile(
                        imagePath: 'lib/images/google.png',
                        borderRadius: BorderRadius.circular(30),
                      ),
                      iconSize: 50,
                      onPressed: () async {
                        await AuthService.signInWithGoogle();
                      },
                      padding: EdgeInsets
                          .zero, // Remove padding to make the button circular
                    ),
                    SizedBox(width: 25),

                    // apple button
                    IconButton(
                      icon: SquareTile(
                        imagePath: 'lib/images/apple.png',
                        borderRadius: BorderRadius.circular(30),
                      ),
                      iconSize: 50,
                      onPressed: () async {
                        await AuthService.signInWithApple();
                      },
                      padding: EdgeInsets
                          .zero, // Remove padding to make the button circular
                    ),
                  ],
                ),

                const SizedBox(height: 50),

                // not a member? register now
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Not a member?',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text(
                        'Register now',
                        style: TextStyle(
                          color: Color.fromARGB(255, 75, 31, 83),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
