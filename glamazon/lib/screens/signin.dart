import 'package:flutter/material.dart';
import 'package:glamazon/reusable_widgets/reusable_widgets.dart';
import 'package:glamazon/screens/auto_image_slider.dart';
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
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
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
                reusableTextField("Enter Username", Icons.person_2_outlined,
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MyImageSlider()),
                    );
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
            ' Sign Up',
            style: TextStyle(
                color: Color(0xff089be3), fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
