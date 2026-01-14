import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:my_safe_school/ui/class_screen/select_class_screen.dart';
import 'package:my_safe_school/ui/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await insertDefaultData(); // 🔹 أضف البيانات الافتراضية إذا غير موجودة

  runApp(const MyApp());
}

// 🔹 الدالة لإضافة الصفوف الافتراضية إذا لم تكن موجودة
Future<void> insertDefaultData() async {
  final db = FirebaseDatabase.instance.ref();

  final snap = await db.child("classes").get();
  if (snap.exists) return; // لو موجودة مسبقًا لا تفعل شيء

  await db.child("classes").set({
    "7_1": {
      "name": "سابع 1",
      "grade": "7",
      "class": "1",
      "students": ["s001", "s002","s003","s004","s005"],
      "exit": 1,
    },
    /*"7_2": {
      "name": "سابع 2",
      "grade": "7",
      "class": "2",
      "students": ["s003"],
      "exit": 2,
    },
    "8_1": {
      "name": "ثامن 1",
      "grade": "8",
      "class": "1",
      "students": ["s004"],
      "exit": 3,
    },*/
    "8_2": {
      "name": "ثامن 2",
      "grade": "8",
      "class": "2",
      "students": ["s006", "s007","s008"],
      "exit": 4,
    },
  });

  // 🔹 إضافة بيانات مخرج الطوارئ الافتراضية
  await db.child("exits").set({
    "7_1": {"exit": 1},
    "7_2": {"exit": 2},
    "8_1": {"exit": 3},
    "8_2": {"exit": 4},
  });

  // 🔹 إضافة جدول الغياب الافتراضي لكل الصفوف اليوم
  String today = "2026-01-12";
  await db.child("evacuations/$today").set({
    "7_1": {"absent": {}, "present": {}},
    "7_2": {"absent": {}, "present": {}},
    "8_1": {"absent": {}, "present": {}},
    "8_2": {"absent": {}, "present": {}},
  });

  // 🔹 إضافة بيانات الطلاب الافتراضية
  await db.child("students").set({
    "s001": {
      "name": "سارة محمد",
      "grade": "7",
      "class": "1",
      "classKey": "7_1",
      "qr": "s001",
    },
    "s002": {
      "name": "ريم خالد",
      "grade": "7",
      "class": "1",
      "classKey": "7_1",
      "qr": "s002",
    },
    "s003": {
      "name": "نور أحمد",
      "grade": "7",
      "class": "1",
      "classKey": "7_1",
      "qr": "s003",
    },
    "s004": {
      "name": "جنى علي",
      "grade": "7",
      "class": "1",
      "classKey": "7_1",
      "qr": "s004",
    },
    "s005": {
      "name": "شهد حسين",
      "grade": "7",
      "class": "1",
      "classKey": "7_1",
      "qr": "s005",
    },
    "s006": {
      "name": "دعاء جاد",
      "grade": "8",
      "class": "2",
      "classKey": "8_2",
      "qr": "s006",
    },
    "s007": {
      "name": "سارة علي",
      "grade": "8",
      "class": "2",
      "classKey": "8_2",
      "qr": "s007",
    },
    "s008": {
      "name": "مريم خالد",
      "grade": "8",
      "class": "2",
      "classKey": "8_2",
      "qr": "s008",
    },
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Safe School',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const SelectClassScreen(), // 🔹 هنا تبدأ الصفحة
    );
  }
}
