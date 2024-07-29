import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:glamazon/screens/salonownerhome%20copy.dart';
import '../reusable_widgets/reusable_widgets.dart';
import 'ownersignup.dart';

// ignore: must_be_immutable
class SalonOwnerLogin extends StatefulWidget {
  SalonOwnerLogin({super.key});

  @override
  _SalonOwnerLoginState createState() => _SalonOwnerLoginState();
}

class _SalonOwnerLoginState extends State<SalonOwnerLogin> {
  final TextEditingController _emailTextController = TextEditingController();
  final TextEditingController _passwordTextController = TextEditingController();
  bool _isLoading = false; // Added variable to manage loading state

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Salon Login'),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          color: Color.fromARGB(255, 250, 227, 197), // Single background color
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
                20, MediaQuery.of(context).size.height * 0.1, 20, 0),
            child: Column(
              children: <Widget>[
                logoWidget("assets/images/logo3.png"),
                const SizedBox(
                  height: 30,
                ),
                reusableTextField("Enter Email", Icons.email_outlined, false,
                    _emailTextController),
                const SizedBox(
                  height: 20,
                ),
                reusableTextField("Enter Password", Icons.lock_outlined, true,
                    _passwordTextController),
                const SizedBox(
                  height: 20,
                ),
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: () async {
                          setState(() {
                            _isLoading = true; // Start loading
                          });
                          try {
                            UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
                              email: _emailTextController.text,
                              password: _passwordTextController.text
                            );

                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const SalonOwnerHome()),
                            );
                          } on FirebaseAuthException catch (e) {
                            if (e.code == 'user-not-found') {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('No user found for that email.')),
                              );
                            } else if (e.code == 'wrong-password') {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Wrong password provided.')),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: ${e.message}')),
                              );
                            }
                          } finally {
                            setState(() {
                              _isLoading = false; // Stop loading
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff089be3),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Login'),
                      ),
                signUpOption(context),
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

  Row signUpOption(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Don\'t have an account?',
          style: TextStyle(color: Color(0xffd05325)),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SalonOwnerSignUp()),
            );
          },
          child: const Text(
            '   SIGN UP',
            style: TextStyle(
                color: Color(0xff089be3), fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
