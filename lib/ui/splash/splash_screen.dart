import 'package:flutter/material.dart';

import '../class_screen/select_class_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();

    // ⏱️ الانتقال تلقائيًا بعد 3 ثواني
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SelectClassScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // شعارك
            Image.asset(
              'images/logo.png', // ضعي هنا شعارك
              width: 180,
            ),
            const SizedBox(height: 30),

            // Loader خفيف و Material Design
            const CircularProgressIndicator(
              strokeWidth: 3,
              color: Colors.blue, // ممكن تغيّري اللون
            ),
          ],
        ),
      ),
    );
  }
}







/*
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../class_screen/select_class_screen.dart';
import '../evacuation/evacuation_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final db = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    super.initState();


    insertMockData();

    Future.delayed(Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => SelectClassScreen(),
        ),
      );
    });

  }

  Future<void> insertMockData() async {
    final snap = await db.child("students").get();
    if (snap.exists) return; // علشان ما يكررهاش

    await db.child("students").set({
      "s001": {"name":"سارة محمد","grade":"7","class":"1","qr":"s001"},
      "s002": {"name":"ريم خالد","grade":"7","class":"1","qr":"s002"},
      "s003": {"name":"نور أحمد","grade":"7","class":"2","qr":"s003"},
      "s004": {"name":"جنى علي","grade":"8","class":"1","qr":"s004"},
      "s005": {"name":"شهد حسين","grade":"8","class":"2","qr":"s005"},
    });

    await db.child("exits").set({
      "7_1": {"exit":1},
      "7_2": {"exit":1},
      "8_1": {"exit":3},
      "8_2": {"exit":3},
    });

    String today = "2026-01-12";
    await db.child("evacuations/$today/absent").set({
      "s001": true,
      "s002": true,
      "s003": true,
      "s004": true,
      "s005": true,
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
*/
