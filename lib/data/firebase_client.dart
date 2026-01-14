
import 'package:firebase_database/firebase_database.dart';
import 'package:my_safe_school/data/firebase_basic_data.dart';
import 'package:my_safe_school/data/firebase_constant.dart';
import 'package:my_safe_school/data/firebase_services.dart';

class FirebaseClient {
  DatabaseReference? databaseRef;

  Future<void> init() async {
    databaseRef = FirebaseDatabase.instance.ref();
    await insertDefaultData();
  }

  Future<void> insertDefaultData() async {
    await insertClassesTable();
  }

  Future<void> insertClassesTable() async {
    final classTableSnap = await databaseRef?.child("classes").get();
    if (classTableSnap!.exists) return;

    await databaseRef
        ?.child(FirebaseConstant.CLASSES_TABLE_NAME)
        .set(FirebaseBasicData().classDataTable());

    await databaseRef
        ?.child(FirebaseConstant.EXITS_TABLE_NAME)
        .set(FirebaseBasicData().exitsDataTable());

    await databaseRef
        ?.child(FirebaseConstant.STUDENT_TABLE_NAME)
        .set(FirebaseBasicData().studentDataTable());

    await databaseRef
        ?.child(FirebaseConstant.EVACUATIONS_URL)
        .child(FirebaseBasicData().getCurrentDate())
        .set(FirebaseBasicData().evacuationsTable());
  }
}
