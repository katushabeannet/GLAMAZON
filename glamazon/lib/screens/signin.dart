import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:glamazon/reusable_widgets/reusable_widgets.dart';
import 'package:glamazon/screens/customer-home.dart';
// import 'package:glamazon/screens/notification-deatails.dart';
import 'package:glamazon/screens/signup.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final TextEditingController _emailTextController = TextEditingController();
  final TextEditingController _passwordTextController = TextEditingController();
  bool _isLoading = false; // Added variable to manage loading state

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 248, 236, 220),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          color: Color.fromARGB(255, 250, 227, 197), // Single background color
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                      20, MediaQuery.of(context).size.height * 0.1, 20, 0),
                  child: Column(
                    children: <Widget>[
                      logoWidget("assets/images/logo3.png"),
                      const SizedBox(
                        height: 30,
                      ),
                      reusableTextField("Enter Your Email", Icons.email_outlined,
                          false, _emailTextController),
                      const SizedBox(
                        height: 20,
                      ),
                      reusableTextField("Enter Password", Icons.lock_outlined, true,
                          _passwordTextController),
                      const SizedBox(
                        height: 20,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _signIn();
                        },
                        child: const Text("Sign In"),
                      ),
                      signUpOption(),
                      const SizedBox(
                        height: 40,
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Future<void> _signIn() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailTextController.text,
        password: _passwordTextController.text,
      );

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ImageSlider()),
      );
    } catch (error) {
      print("Error signing in: ${error.toString()}");
      // Optionally show an error message to the user here
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Row signUpOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Don\'t Have an account?',
          style: TextStyle(color: Color(0xffd05325)),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const signUp()),
            );
          },
          child: const Text(
            '  SIGN UP ',
            style: TextStyle(
                color: Color(0xff089be3), fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
