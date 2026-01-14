import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:qr_flutter/qr_flutter.dart';

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
    final snapshot = await db.child('students').get();
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
    await db.child('students/$id/name').set(newName);
    setState(() {
      students[id]!['name'] = newName;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F6FB),
        appBar: AppBar(
          title: Text("طالبات الصف ${widget.classKey}"),
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
            final name = data['name'] ?? '';
            final grade = data['grade'] ?? '';
            final classNum = data['class'] ?? '';
            final qr = data['qr'] ?? '';

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
                            "الصف: $grade - $classNum",
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
                              label: const Text("تعديل الاسم",style: TextStyle(color: Colors.white),),
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
                                    title: const Text("تعديل اسم الطالبة"),
                                    content: TextField(
                                      controller: controller,
                                      decoration: const InputDecoration(
                                        hintText: "اكتب الاسم الجديد",
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context),
                                        child: const Text("إلغاء"),
                                      ),
                                      ElevatedButton(
                                        onPressed: () => Navigator.pop(
                                          context,
                                          controller.text,
                                        ),
                                        child: const Text("حفظ"),
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
