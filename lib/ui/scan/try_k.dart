import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:qr_flutter/qr_flutter.dart';
class ResultScreen extends StatelessWidget {
  final String grade;
  final String classNum;

  const ResultScreen({
    super.key,
    required this.grade,
    required this.classNum,
  });

  @override
  Widget build(BuildContext context) {
    final db = FirebaseDatabase.instance.ref();
    final String today = "2026-01-12";
    final String classKey = "${grade}_${classNum}";

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F6FB),
        appBar: AppBar(
          title: Text("تقرير الصف $grade-$classNum"),
          centerTitle: true,

        ),

        body: StreamBuilder<DatabaseEvent>(
          stream: db
              .child("evacuations/$today/$classKey/present")
              .onValue,
          builder: (context, presentSnap) {
            if (!presentSnap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final presentMap = presentSnap.data!.snapshot.value == null
                ? <String, dynamic>{}
                : Map<String, dynamic>.from(
              presentSnap.data!.snapshot.value as Map,
            );

            return FutureBuilder<DatabaseEvent>(
              future: db.child("classes/$classKey/students").once(),
              builder: (context, classSnap) {
                if (!classSnap.hasData ||
                    classSnap.data!.snapshot.value == null) {
                  return const Center(child: CircularProgressIndicator());
                }

                final studentIds =
                List<String>.from(classSnap.data!.snapshot.value as List);

                return FutureBuilder<List<Map<String, dynamic>>>(
                  future: Future.wait(
                    studentIds.map((id) async {
                      final snap = await db.child("students/$id").get();
                      if (!snap.exists) return {};

                      final student =
                      Map<String, dynamic>.from(snap.value as Map);
                      student['id'] = id;
                      return student;
                    }),
                  ),
                  builder: (context, studentsSnap) {
                    if (!studentsSnap.hasData) {
                      return const Center(
                          child: CircularProgressIndicator());
                    }

                    final students =
                    studentsSnap.data!.where((e) => e.isNotEmpty);

                    final presentStudents = students
                        .where((s) => presentMap[s['id']] == true)
                        .toList();

                    final absentStudents = students
                        .where((s) => presentMap[s['id']] != true)
                        .toList();

                    final bool hasAbsent = absentStudents.isNotEmpty;
                    final int total =
                        presentStudents.length + absentStudents.length;

                    return Column(
                      children: [
                        // Header
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

                        // Stats
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
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

                        // Absent list
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
                                  child: ListTile(
                                    leading: QrImageView(
                                      data: s['qr'],
                                      size: 60,
                                    ),
                                    title: Text(s['name']),
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
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  static Widget _statCard(String title, int value, Color color) {
    return Expanded(
      child: Card(
        elevation: 3,
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

