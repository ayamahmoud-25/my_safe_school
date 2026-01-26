import 'package:flutter/material.dart';
import 'package:my_safe_school/data/firebase_services.dart';
import 'package:my_safe_school/ui/class_screen/select_class_screen.dart';
import 'package:my_safe_school/util/Strings.dart';
import 'package:my_safe_school/util/widget_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await FirebaseServices().initializeApp();
  } catch (e) {
    print("Catch Error: $e");
    WidgetHelper().showToast("Catch Error:  ${e.toString()}");
  }

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
