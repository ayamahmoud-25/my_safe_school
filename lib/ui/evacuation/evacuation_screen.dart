import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:my_safe_school/ui/student/students_by_class_screen.dart';
import '../scan/scan_screen.dart';

class EvacuationScreen extends StatefulWidget {
  final String grade;
  final String classNum;

  const EvacuationScreen({
    super.key,
    required this.grade,
    required this.classNum,
  });

  @override
  State<EvacuationScreen> createState() => _EvacuationScreenState();
}

class _EvacuationScreenState extends State<EvacuationScreen> {
  final db = FirebaseDatabase.instance.ref("classes");

  int exitNumber = 0;
  String className = "";
  String classKey = "";

  @override
  void initState() {
    super.initState();
    loadExit();
  }

  Future<void> loadExit() async {
    classKey = "${widget.grade}_${widget.classNum}";
    final snap = await db.child(classKey).get();
    if (snap.exists) {
      final data = snap.value as Map<dynamic, dynamic>;
      setState(() {
        exitNumber = data["exit"] ?? 0;
        className = data["name"] ?? "";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F6FB),
        appBar: AppBar(
          title: const Text("إخلاء الصف"),
          centerTitle: true,
          backgroundColor: Colors.indigo,
          leading: const Icon(Icons.warning_amber_rounded),
        ),

        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // كارت المخرج
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.exit_to_app,
                          size: 40,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              className,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "رقم المخرج: $exitNumber",
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // زر أخذ الحضور
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.qr_code_scanner),
                  label: const Text(
                    "بدء أخذ الحضور",
                    style: TextStyle(fontSize: 18,color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ScanScreen(
                          grade: widget.grade,
                          classNum: widget.classNum,
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // زر عرض الطالبات
              SizedBox(
                width: double.infinity,
                height: 55,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.people),
                  label: const Text(
                    "عرض الطالبات",
                    style: TextStyle(fontSize: 18),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.indigo),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => StudentsByClassScreen(
                          classKey: classKey,
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
