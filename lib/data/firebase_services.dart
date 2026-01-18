import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:my_safe_school/data/firebase_client.dart';

class FirebaseServices {
  Future<void> initializeApp() async {
    await Firebase.initializeApp();
    await FirebaseClient().init();
  }

  DatabaseReference getFirebaseDBInstance() {
    return FirebaseDatabase.instance.ref();
  }
}
