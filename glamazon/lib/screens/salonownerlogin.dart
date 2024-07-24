import 'package:flutter/material.dart';
import 'package:glamazon/screens/notification-deatails.dart';
import 'package:glamazon/screens/salonownerhome.dart';
import '../reusable_widgets/reusable_widgets.dart';
import 'ownersignup.dart';

// ignore: must_be_immutable
class SalonOwnerLogin extends StatelessWidget {
  TextEditingController _emailTextController = TextEditingController();
  TextEditingController _passwordTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Salon Owner Login'),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            hexStringToColor("#C0724A"), // Very Light Sienna
            hexStringToColor("#E0A680"), // Lighter Sienna
            hexStringToColor("#E0A680") // Lightest Sienna
          ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
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
                signInSignUpButton(context, true, () {
                  // Handle login logic here, then navigate to home screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SalonOwnerHome()),
                  );
                }),
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
