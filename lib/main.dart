import 'package:flutter/material.dart';
import 'package:my_safe_school/data/firebase_services.dart';
import 'package:my_safe_school/ui/class_screen/select_class_screen.dart';
import 'package:my_safe_school/util/Strings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await FirebaseServices().initializeApp();

  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: Strings.APP_TITLE,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const SelectClassScreen(),
    );
  }
}
