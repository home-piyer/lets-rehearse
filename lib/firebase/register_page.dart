import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:solo_rehearsal/components/my_button.dart';
import 'package:solo_rehearsal/components/my_textfield.dart';
import 'package:solo_rehearsal/components/square_tile.dart';
import 'package:solo_rehearsal/firebase/auth_page.dart';
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

class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  const RegisterPage({Key? key, required this.onTap}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // text editing controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // sign user in method
  void signUserUp() async {
    //show loading circle
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    //try creating the user
    try {
      //check if password is confirmed
      if (passwordController.text == confirmPasswordController.text) {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );
      } else {
        // show error message, passwords don't match
        showErrorMessage("Passwords don't match");
      }
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
          backgroundColor: Color.fromARGB(255, 75, 31, 83),
          title: Center(
            child: Text(message, style: const TextStyle(color: Colors.white)),
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
                const SizedBox(height: 25),
                // logo
                Image.asset(
                  'lib/images/script.png',
                  width: 200, // Set the width to make the image smaller
                ),

                const SizedBox(height: 25),

                // let's create an account for you
                Text(
                  'Let\'s create an account for you',
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
                      BorderRadius.circular(100), // Set the border radius
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

                // confirm password textfield
                MyTextField(
                  controller: confirmPasswordController,
                  hintText: 'Confirm Password',
                  obscureText: true,
                  borderRadius:
                      BorderRadius.circular(30), // Set the border radius
                ),

                const SizedBox(height: 25),

                // sign in button
                MyButton(
                  text: "Sign Up",
                  onTap: signUserUp,
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
                    // Google sign up button
                    GestureDetector(
                      onTap: () async {
                        await AuthService.signInWithGoogle();
                      },
                      child: SquareTile(
                        imagePath: 'lib/images/google.png',
                        borderRadius:
                            BorderRadius.circular(30), // Set the border radius
                      ),
                    ),

                    // Spacing between the buttons
                    SizedBox(width: 25),

                    // Apple sign up button
                    GestureDetector(
                      onTap: () async {
                        await AuthService.signInWithApple();
                      },
                      child: SquareTile(
                        imagePath: 'lib/images/apple.png',
                        borderRadius:
                            BorderRadius.circular(30), // Set the border radius
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 50),

                // not a member? register now
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account?',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text(
                        'Login now',
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
