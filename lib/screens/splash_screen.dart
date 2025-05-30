import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:async';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  const SplashScreen({
    Key? key,
    required this.cameras,
  }) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LoginScreen(cameras: widget.cameras),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: Hero(
          tag: 'appLogo',
          child: Image.asset(
            'assets/opino_logo.png',
            width: 300,
            height: 300,
          ),
        ),
      ),
    );
  }
}