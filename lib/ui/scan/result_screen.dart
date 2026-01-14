import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ResultScreen extends StatefulWidget {
  final String grade;
  final String classNum;

  const ResultScreen({
    super.key,
    required this.grade,
    required this.classNum,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final db = FirebaseDatabase.instance.ref();
  final String today = "2026-01-12";

  List<Map<String, dynamic>> presentStudents = [];
  List<Map<String, dynamic>> absentStudents = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadAttendance();
  }

  Future<void> loadAttendance() async {
    String classKey = "${widget.grade}_${widget.classNum}";

    final classSnap = await db.child("classes/$classKey/students").get();
    if (!classSnap.exists) return;

    List<String> allStudentIds =
    List<String>.from(classSnap.value as List);

    final presentSnap =
    await db.child("evacuations/$today/$classKey/present").get();

    Map<String, dynamic> presentMap = {};
    if (presentSnap.exists) {
      presentMap = Map<String, dynamic>.from(presentSnap.value as Map);
    }

    List<Map<String, dynamic>> tempPresent = [];
    List<Map<String, dynamic>> tempAbsent = [];

    for (var id in allStudentIds) {
      final studentSnap = await db.child("students/$id").get();
      if (!studentSnap.exists) continue;

      var student = Map<String, dynamic>.from(studentSnap.value as Map);
      bool isPresent = presentMap[id] == true;

      if (isPresent) {
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
    bool hasAbsent = absentStudents.isNotEmpty;
    int total = presentStudents.length + absentStudents.length;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F6FB),
        appBar: AppBar(
          title: Text("تقرير الصف ${widget.grade}-${widget.classNum}",style: TextStyle(color: Colors.white),),
          centerTitle: true,
          backgroundColor:
          hasAbsent ? Colors.red.shade700 : Colors.green.shade700,
        ),
        body: loading
            ? const Center(child: CircularProgressIndicator())
            : StreamBuilder<DatabaseEvent>(
      stream: db
          .child("evacuations/$today/${widget.grade}_${widget.classNum}/present")
          .onValue,
      builder: (context, snapshot) {

        // كل ما يحصل تغيير → نعيد تحميل البيانات
        if (snapshot.connectionState == ConnectionState.active) {
          loadAttendance();
        }

        if (loading) {
          return const Center(child: CircularProgressIndicator());
        }

        bool hasAbsent = absentStudents.isNotEmpty;
        int total = presentStudents.length + absentStudents.length;

        return Column(
          children: [
            // Header حالة الصف
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              color: hasAbsent
                  ? Colors.red.shade700
                  : Colors.green.shade700,
              child: Column(
                children: [
                  Icon(
                    hasAbsent ? Icons.error : Icons.verified,
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
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  _statCard("الإجمالي", total, Colors.blue),
                  _statCard(
                      "الحاضرات", presentStudents.length, Colors.green),
                  _statCard(
                      "الغائبات", absentStudents.length, Colors.red),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // قائمة الغائبات
            Expanded(
              child: hasAbsent
                  ? ListView(
                padding: const EdgeInsets.all(12),
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: ListTile(
                        leading: QrImageView(
                          data: s['qr'],
                          size: 60,
                        ),
                        title: Text(
                          s['name'],
                          style: const TextStyle(
                              fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                            "الصف: ${s['grade']} - ${s['class']}"),
                        tileColor: Colors.red.shade50,
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
        );
      },
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
