import 'package:flutter/material.dart';
import 'package:glamazon/screens/auto_image_slider.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  bool _showSlogan = false;

  @override
  void initState() {
    super.initState();
    _startAnimation();
    _navigatetohome();
  }

  _startAnimation() async {
    await Future.delayed(const Duration(seconds: 7));
    setState(() {
      _showSlogan = true;
    });
  }

  _navigatetohome() async {
    await Future.delayed(const Duration(milliseconds: 9500), () {});
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MyImageSlider()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(seconds: 7),
              builder: (context, scale, child) {
                return Transform.scale(
                  scale: scale,
                  child: SizedBox(
                    height: 200,
                    width: 200,
                    child: Image.asset('assets/images/logo3.png'), // Replace with your image path
                  ),
                );
              },
            ),
            const SizedBox(height: 0), // Reduced spacing between logo and slogan
            AnimatedOpacity(
              opacity: _showSlogan ? 1.0 : 0.0,
              duration: const Duration(seconds: 1),
              child: const Text(
                'Book ~ your ~ look ~ online',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 99, 62, 20),
                ),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 250, 227, 197),
    );
  }
}
