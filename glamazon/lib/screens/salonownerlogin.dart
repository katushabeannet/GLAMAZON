import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:glamazon/screens/salonownerhome%20copy.dart';
import '../reusable_widgets/reusable_widgets.dart';
import 'ownersignup.dart';

class SalonOwnerLogin extends StatefulWidget {
  const SalonOwnerLogin({super.key});

  @override
  _SalonOwnerLoginState createState() => _SalonOwnerLoginState();
}

class _SalonOwnerLoginState extends State<SalonOwnerLogin> {
  final TextEditingController _emailTextController = TextEditingController();
  final TextEditingController _passwordTextController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null; // Clear previous error messages
    });

    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailTextController.text,
        password: _passwordTextController.text,
      );

      // Check the role of the user
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('owners')
          .doc(userCredential.user?.uid)
          .get();

      if (userDoc.exists) {
        String? role = userDoc['role'];
        if (role == 'salon_owner') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const SalonOwnerHome()),
          );
        } else {
          setState(() {
            _errorMessage = 'You do not have permission to log in from this screen.';
          });
        }
      } else {
        setState(() {
          _errorMessage = 'No user found for this email.';
        });
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        setState(() {
          _errorMessage = 'No user found for that email.';
        });
      } else if (e.code == 'wrong-password') {
        setState(() {
          _errorMessage = 'Wrong password provided.';
        });
      } else {
        setState(() {
          _errorMessage = 'Error: ${e.message}';
        });
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

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
          color: Color.fromARGB(255, 250, 227, 197),
        ),
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                    20, MediaQuery.of(context).size.height * 0.1, 20, 0),
                child: Column(
                  children: <Widget>[
                    logoWidget("assets/images/logo3.png"),
                    const SizedBox(height: 30),
                    reusableTextField("Enter Email", Icons.email_outlined, false,
                        _emailTextController),
                    const SizedBox(height: 20),
                    reusableTextField("Enter Password", Icons.lock_outlined, true,
                        _passwordTextController),
                    const SizedBox(height: 20),
                    _isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xff089be3),
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Login'),
                          ),
                    signUpOption(context),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
            if (_errorMessage != null)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.red[100],
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, color: Colors.red[700]),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red[700]),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
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
              MaterialPageRoute(builder: (context) => const SalonOwnerSignUp()),
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
