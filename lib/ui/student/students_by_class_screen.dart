import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:my_safe_school/data/firebase_constant.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../util/Strings.dart';

class StudentsByClassScreen extends StatefulWidget {
  final String classKey;

  const StudentsByClassScreen({super.key, required this.classKey});

  @override
  State<StudentsByClassScreen> createState() => _StudentsByClassScreenState();
}

class _StudentsByClassScreenState extends State<StudentsByClassScreen> {
  final db = FirebaseDatabase.instance.ref();
  Map<String, dynamic> students = {};

  @override
  void initState() {
    super.initState();
    fetchStudents();
  }

  Future<void> fetchStudents() async {
    final snapshot = await db.child(FirebaseConstant.STUDENT_TABLE_NAME).get();
    if (!snapshot.exists) return;

    final allStudents = Map<String, dynamic>.from(snapshot.value as Map);

    final filtered = Map.fromEntries(
      allStudents.entries.where(
            (entry) => entry.value['classKey'] == widget.classKey,
      ),
    );

    setState(() {
      students = filtered;
    });
  }

  Future<void> updateStudentName(String id, String newName) async {
    await db
        .child(FirebaseConstant.STUDENT_URL_DASH)
        .child(id).child(FirebaseConstant.NAME_DASH_URL)
        .set(newName);

    setState(() {
      students[id]![Strings.NAME_KEY] = newName;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F6FB),
        appBar: AppBar(
          title: Text(" ${Strings.STUDENT_CLASS} ${widget.classKey}"),
          centerTitle: true,
          backgroundColor: Colors.indigo,
          leading: const Icon(Icons.groups),
        ),
        body: students.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: students.length,
          itemBuilder: (context, index) {
            final id = students.keys.elementAt(index);
            final data = students[id];
            final name = data[Strings.NAME_KEY] ?? '';
            final grade = data[Strings.GRADE_KEY] ?? '';
            final classNum = data[Strings.CLASS_KEY] ?? '';
            final qr = data[Strings.QR_KEY] ?? '';

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    // QR
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.indigo.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: QrImageView(
                        data: qr,
                        version: QrVersions.auto,
                        size: 80,
                      ),
                    ),

                    const SizedBox(width: 12),

                    // البيانات
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            " ${Strings.CLASS} $grade ${Strings.DASH} $classNum",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 10),

                          Align(
                            alignment: Alignment.centerLeft,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.edit, size: 18),
                              label: const Text(Strings.EDIT_NAME,style: TextStyle(color: Colors.white),),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.indigo,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () async {
                                final controller =
                                TextEditingController(text: name);

                                final newName = await showDialog<String>(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: const Text(Strings.EDIT_STUDENT_NAME),
                                    content: TextField(
                                      controller: controller,
                                      decoration: const InputDecoration(
                                        hintText: Strings.WRITE_NEW_NAME,
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context),
                                        child: const Text(Strings.CANCEL),
                                      ),
                                      ElevatedButton(
                                        onPressed: () => Navigator.pop(
                                          context,
                                          controller.text,
                                        ),
                                        child: const Text(Strings.SAVE),
                                      ),
                                    ],
                                  ),
                                );

                                if (newName != null &&
                                    newName.trim().isNotEmpty) {
                                  updateStudentName(
                                      id, newName.trim());
                                }
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
