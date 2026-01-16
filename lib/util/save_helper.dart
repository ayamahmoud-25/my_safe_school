/*
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:my_safe_school/data/firebase_constant.dart';
import '../../util/Strings.dart';
import '../evacuation/evacuation_screen.dart';
import '../ui/evacuation/evacuation_screen.dart';

class SelectClassScreen extends StatelessWidget {
  const SelectClassScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db =
    FirebaseDatabase.instance.ref(FirebaseConstant.CLASSES_TABLE_NAME);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F6FB),

        // ================= APP BAR =================
        appBar: AppBar(
          title: const Text(
            Strings.SELECT_CLASS,
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: Colors.indigo,
          elevation: 0,
          leading: const Icon(Icons.school, color: Colors.white),

          actions: [
            IconButton(
              icon: const Icon(Icons.add, color: Colors.white),
              onPressed: () => _showAddClassDialog(context, db),
            ),
          ],
        ),

        // ================= BODY =================
        body: StreamBuilder(
          stream: db.onValue,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text(Strings.ERROR_DATA));
            }

            if (!snapshot.hasData ||
                snapshot.data!.snapshot.value == null) {
              return const Center(child: CircularProgressIndicator());
            }

            final dataMap =
            snapshot.data!.snapshot.value as Map<dynamic, dynamic>?;

            if (dataMap == null || dataMap.isEmpty) {
              return const Center(child: Text(Strings.ERROR_CLASSES_FOUND));
            }

            return GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: dataMap.length,
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.95, // حل overflow
              ),
              itemBuilder: (context, index) {
                final key = dataMap.keys.elementAt(index);
                final c = dataMap[key] as Map<dynamic, dynamic>;

                final studentsIds =
                    (c[Strings.STUDENT_KEY] as List<dynamic>?) ?? [];

                return Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  elevation: 3,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EvacuationScreen(
                            grade: c[Strings.GRADE_KEY],
                            classNum: c[Strings.CLASS_KEY],
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.indigo.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.class_,
                              size: 32,
                              color: Colors.indigo,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            c[Strings.NAME_KEY] ?? Strings.NO_NAME,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 6),

                          Text(
                            "${Strings.STUDENT_NUMBER} ${studentsIds.length}",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                            ),
                          ),

                          Text(
                            "مخرج ${c['exit']}",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  // ================= ADD CLASS DIALOG =================
  void _showAddClassDialog(
      BuildContext context, DatabaseReference db) {
    final nameCtrl = TextEditingController();
    final gradeCtrl = TextEditingController();
    final classCtrl = TextEditingController();
    final exitCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("إضافة صف جديد"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: "اسم الصف"),
                ),
                TextField(
                  controller: gradeCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "المرحلة"),
                ),
                TextField(
                  controller: classCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "الفصل"),
                ),
                TextField(
                  controller: exitCtrl,
                  keyboardType: TextInputType.number,
                  decoration:
                  const InputDecoration(labelText: "رقم المخرج"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text("إلغاء"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: const Text("حفظ"),
              onPressed: () async {
                final key =
                    "${gradeCtrl.text}_${classCtrl.text}";

                await db.child(key).set({
                  Strings.NAME_KEY: nameCtrl.text,
                  Strings.GRADE_KEY: gradeCtrl.text,
                  Strings.CLASS_KEY: classCtrl.text,
                  'exit': int.tryParse(exitCtrl.text) ?? 0,
                  Strings.STUDENT_KEY: [],
                });

                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
*/
