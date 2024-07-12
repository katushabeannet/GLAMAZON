import 'package:flutter/material.dart';
import 'package:glamazon/screens/splash.dart';


void main() {
  runApp(const MyApplication());
}

class MyApplication extends StatelessWidget {
  const MyApplication({super.key});
  @override


  Widget build(BuildContext context) {
    return  const MaterialApp(
      home: Splash(),
      debugShowCheckedModeBanner: false,
    );
  }
}
