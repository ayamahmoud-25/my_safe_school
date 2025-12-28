import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // الانتقال تلقائيًا بعد 3 ثواني
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Color(0xFF8A1538),
      backgroundColor:Colors.white,
    body: Center(
        child:Image.asset(
          'images/logo.png', // هنا ضعي ملف PNG
          width: 200,
        ),
      ),
    );
  }
}
