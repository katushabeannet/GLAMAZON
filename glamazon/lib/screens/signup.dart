import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:glamazon/reusable_widgets/reusable_widgets.dart';
// import 'package:glamazon/screens/customer-home.dart';
import 'package:glamazon/screens/profile-edit.dart';
import 'package:glamazon/screens/signin.dart';

class signUp extends StatefulWidget {
  const signUp({super.key});

  @override
  State<signUp> createState() => _signUpState();
}

class _signUpState extends State<signUp> {
  final TextEditingController _usernameTextController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();
  final TextEditingController _passwordTextController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color.fromARGB(255, 248, 236, 220),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Sign Up',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
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
                      reusableTextField("Enter Username", Icons.person_2_outlined,
                          false, _usernameTextController),
                      const SizedBox(
                        height: 20,
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
                      signInSignUpButton(context, false, () {
                        _signUp();
                      }),
                      signUpOption()
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Future<void> _signUp() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailTextController.text,
        password: _passwordTextController.text,
      );

      print("Signed Up");
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProfileEditScreen()),
      );
    } catch (error) {
      print("error: ${error.toString()}");
      // You might want to show an error message to the user here
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
          'Have an account?',
          style: TextStyle(color: Color(0xffbe4a21)),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SignIn()),
            );
          },
          child: const Text(
            ' LOGIN',
            style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
