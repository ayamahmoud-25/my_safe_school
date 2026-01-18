import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ResultScreen extends StatefulWidget {
  final String classKey;
  final String date;

  const ResultScreen({
    super.key,
    required this.classKey,
    required this.date,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final db = FirebaseDatabase.instance.ref();

  List<Map<String, dynamic>> presentStudents = [];
  List<Map<String, dynamic>> absentStudents = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadAttendance();
  }

  Future<void> loadAttendance() async {
    setState(() => loading = true);

    // كل الطالبات في الصف
    final classSnap =
    await db.child("classes/${widget.classKey}/students").get();
    if (!classSnap.exists) {
      setState(() => loading = false);
      return;
    }

    final List<String> allStudentIds =
    List<String>.from(classSnap.value as List);

    // الحاضرات
    final presentSnap = await db
        .child(
        "evacuations/${widget.date}/${widget.classKey}/present")
        .get();

    Map<String, dynamic> presentMap = {};
    if (presentSnap.exists) {
      presentMap = Map<String, dynamic>.from(presentSnap.value as Map);
    }

    List<Map<String, dynamic>> tempPresent = [];
    List<Map<String, dynamic>> tempAbsent = [];

    for (final id in allStudentIds) {
      final studentSnap = await db.child("students/$id").get();
      if (!studentSnap.exists) continue;

      final student =
      Map<String, dynamic>.from(studentSnap.value as Map);

      if (presentMap[id] == true) {
        tempPresent.add(student);
      } else {
        tempAbsent.add(student);
      }
    }

    setState(() {
      presentStudents = tempPresent;
      absentStudents = tempAbsent;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool hasAbsent = absentStudents.isNotEmpty;
    final int total =
        presentStudents.length + absentStudents.length;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F6FB),
        appBar: AppBar(
          title: Text(
            "تقرير الصف ${widget.classKey}",
            style: const TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor:
          hasAbsent ? Colors.red.shade700 : Colors.green.shade700,

          // 🔙 زر الرجوع
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
          children: [
            // الهيدر
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              color: hasAbsent
                  ? Colors.red.shade700
                  : Colors.green.shade700,
              child: Column(
                children: [
                  Icon(
                    hasAbsent
                        ? Icons.error
                        : Icons.verified,
                    color: Colors.white,
                    size: 60,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    hasAbsent
                        ? "لم يتم خروج جميع الطالبات"
                        : "تم إخلاء الصف بالكامل",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // الإحصائيات
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  _statCard("الإجمالي", total, Colors.blue),
                  _statCard("الحاضرات",
                      presentStudents.length, Colors.green),
                  _statCard("الغائبات",
                      absentStudents.length, Colors.red),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // قائمة الغائبات
            Expanded(
              child: hasAbsent
                  ? ListView(
                padding:
                const EdgeInsets.all(12),
                children: [
                  const Text(
                    "الطالبات الغائبات",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...absentStudents.map(
                        (s) => Card(
                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(14),
                      ),
                      child: ListTile(
                        leading: QrImageView(
                          data: s['qr'] ?? '',
                          size: 60,
                        ),
                        title: Text(
                          s['name'] ?? '',
                          style: const TextStyle(
                              fontWeight:
                              FontWeight.bold),
                        ),
                        subtitle: Text(
                            "الصف: ${s['grade']} - ${s['class']}"),
                        tileColor:
                        Colors.red.shade50,
                      ),
                    ),
                  ),
                ],
              )
                  : const Center(
                child: Text(
                  "جميع الطالبات حضرن وتم إخلاؤهن بأمان ✅",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String title, int value, Color color) {
    return Expanded(
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                "$value",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 6),
              Text(title),
            ],
          ),
        ),
      ),
    );
  }
}
