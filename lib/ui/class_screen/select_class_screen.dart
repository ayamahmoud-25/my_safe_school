import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

import '../evacuation/evacuation_screen.dart';

class SelectClassScreen extends StatelessWidget {
  const SelectClassScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final classesRef = FirebaseDatabase.instance.ref("classes");
    final exitsRef = FirebaseDatabase.instance.ref("exits");

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F6FB),
        appBar: AppBar(
          title: const Text(
            "اختيار الصف",
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: Colors.indigo,
          leading: const Icon(Icons.school, color: Colors.white),
          actions: [
            IconButton(
              icon: const Icon(Icons.add, color: Colors.white),
              onPressed: () {
                _showAddNewClassDialog(context, classesRef, exitsRef);
              },
            ),
          ],
        ),
        body: StreamBuilder<DatabaseEvent>(
          stream: classesRef.onValue,
          builder: (context, classSnap) {
            if (!classSnap.hasData || classSnap.data!.snapshot.value == null) {
              return const Center(child: CircularProgressIndicator());
            }

            final classesMap = Map<String, dynamic>.from(
              classSnap.data!.snapshot.value as Map,
            );

            return StreamBuilder<DatabaseEvent>(
              stream: exitsRef.onValue,
              builder: (context, exitSnap) {
                if (!exitSnap.hasData ||
                    exitSnap.data!.snapshot.value == null) {
                  return const Center(child: CircularProgressIndicator());
                }

                final exitsMap = Map<String, dynamic>.from(
                  exitSnap.data!.snapshot.value as Map,
                );

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: classesMap.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.78,
                  ),
                  itemBuilder: (context, index) {
                    final classKey = classesMap.keys.elementAt(index);
                    final c = Map<String, dynamic>.from(classesMap[classKey]);

                    final students = (c["students"] as List<dynamic>?) ?? [];

                    final exitId = c["exitId"];
                    final exitName = exitsMap[exitId]?["name"] ?? "غير محدد";

                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EvacuationScreen(
                              classKey: classKey,
                              className: c["name"],
                              exitName: exitName,
                            ),
                          ),
                        );
                      },
                      child: Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.class_,
                                size: 40,
                                color: Colors.indigo,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                c["name"],
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "عدد الطالبات: ${students.length}",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  exitName,
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  InkWell(
                                    child: Icon(Icons.delete, color: Colors.red),
                                    onTap: () {
                                      _confirmDelete(
                                        context,
                                        classesRef,
                                        classKey,
                                        c["name"],
                                      );
                                    },
                                  ),
                                  InkWell(
                                    child: const Icon(Icons.edit, color: Colors.blue),
                                    onTap: () {
                                      _showEditClassDialog(
                                        context,
                                        classesRef,
                                        exitsRef,
                                        classKey,
                                        c,
                                      );
                                    },
                                  ),

                                ],
                              )

                            ],
                          ),
                        ),
                      ),
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

  // --- Dialog إضافة الصف ---
  void _showAddNewClassDialog(
    BuildContext context,
    DatabaseReference classesRef,
    DatabaseReference exitsRef,
  ) {
    final TextEditingController nameCtrl = TextEditingController();
    int? selectedClass;
    int? selectedGrade;
    String? selectedExitKey;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("إضافة صف جديد"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: "اسم الصف",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(
                    labelText: "Class",
                    border: OutlineInputBorder(),
                  ),
                  value: selectedClass,
                  items: List.generate(9, (index) => index + 1)
                      .map(
                        (num) => DropdownMenuItem(
                          value: num,
                          child: Text(num.toString()),
                        ),
                      )
                      .toList(),
                  onChanged: (val) => selectedClass = val,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(
                    labelText: "Grade",
                    border: OutlineInputBorder(),
                  ),
                  value: selectedGrade,
                  items: List.generate(12, (index) => index + 1)
                      .map(
                        (num) => DropdownMenuItem(
                          value: num,
                          child: Text(num.toString()),
                        ),
                      )
                      .toList(),
                  onChanged: (val) => selectedGrade = val,
                ),
                const SizedBox(height: 12),
                FutureBuilder<DataSnapshot>(
                  future: exitsRef.get(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data!.value == null) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final exitsMap = Map<String, dynamic>.from(
                      snapshot.data!.value as Map,
                    );
                    return DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: "اختر المخرج",
                        border: OutlineInputBorder(),
                      ),
                      items: exitsMap.keys
                          .map(
                            (key) => DropdownMenuItem<String>(
                              value: key,
                              child: Text(exitsMap[key]["name"] ?? key),
                            ),
                          )
                          .toList(),
                      onChanged: (val) => selectedExitKey = val,
                    );
                  },
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
              child: const Text("إضافة"),
              onPressed: () async {
                final name = nameCtrl.text.trim();
                if (name.isNotEmpty &&
                    selectedClass != null &&
                    selectedGrade != null &&
                    selectedExitKey != null) {
                  final newClassKey = "${selectedClass}_${selectedGrade}";
                  final existingSnapshot = await classesRef
                      .child(newClassKey)
                      .get();
                  if (existingSnapshot.exists) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("هذا الصف موجود بالفعل!")),
                    );
                    return;
                  }
                  final newClass = {
                    "name": name,
                    "class": selectedClass.toString(),
                    "grade": selectedGrade.toString(),
                    "exitId": selectedExitKey,
                    "students": [],
                    // <-- students فارغ تلقائي
                  };
                  await classesRef.child(newClassKey).set(newClass);
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "يرجى إدخال اسم الصف وClass وGrade والمخرج",
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  /// تأكيد الحذف
  void _confirmDelete(
    BuildContext context,
    DatabaseReference classesRef,
    String classKey,
    String className,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("تأكيد الحذف"),
        content: Text("هل تريد حذف الصف ($className) ؟"),
        actions: [
          TextButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
            child: const Text("إلغاء"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
            child: const Text("حذف"),
            onPressed: () async {
              await classesRef.child(classKey).remove();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showEditClassDialog(
      BuildContext context,
      DatabaseReference classesRef,
      DatabaseReference exitsRef,
      String classKey,
      Map<String, dynamic> classData,
      ) {
    final TextEditingController nameCtrl = TextEditingController();

    int? selectedClass = int.tryParse(classData["class"].toString());
    int? selectedGrade = int.tryParse(classData["grade"].toString());
    String? selectedExitKey = classData["exitId"];

    nameCtrl.text = classData["name"].toString();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("تعديل الصف"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: "اسم الصف",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),

                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(
                    labelText: "Class",
                    border: OutlineInputBorder(),
                  ),
                  value: selectedClass,
                  items: List.generate(9, (index) => index + 1)
                      .map(
                        (num) => DropdownMenuItem(
                      value: num,
                      child: Text(num.toString()),
                    ),
                  )
                      .toList(),
                  onChanged: (val) => selectedClass = val,
                ),

                const SizedBox(height: 12),

                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(
                    labelText: "Grade",
                    border: OutlineInputBorder(),
                  ),
                  value: selectedGrade,
                  items: List.generate(12, (index) => index + 1)
                      .map(
                        (num) => DropdownMenuItem(
                      value: num,
                      child: Text(num.toString()),
                    ),
                  )
                      .toList(),
                  onChanged: (val) => selectedGrade = val,
                ),

                const SizedBox(height: 12),

                FutureBuilder<DataSnapshot>(
                  future: exitsRef.get(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data!.value == null) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final exitsMap = Map<String, dynamic>.from(
                      snapshot.data!.value as Map,
                    );

                    return DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: "اختر المخرج",
                        border: OutlineInputBorder(),
                      ),
                      value: selectedExitKey,
                      items: exitsMap.keys
                          .map(
                            (key) => DropdownMenuItem<String>(
                          value: key,
                          child: Text(exitsMap[key]["name"] ?? key),
                        ),
                      )
                          .toList(),
                      onChanged: (val) => selectedExitKey = val,
                    );
                  },
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
              child: const Text("حفظ التعديل"),
              onPressed: () async {
                final name = nameCtrl.text.trim();

                if (name.isEmpty ||
                    selectedClass == null ||
                    selectedGrade == null ||
                    selectedExitKey == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("يرجى إدخال جميع البيانات"),
                    ),
                  );
                  return;
                }

                final newClassKey = "${selectedClass}_${selectedGrade}";

                // لو غير Class أو Grade نتحقق من التكرار
                if (newClassKey != classKey) {
                  final exists = await classesRef.child(newClassKey).get();
                  if (exists.exists) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("هذا الصف موجود بالفعل!"),
                      ),
                    );
                    return;
                  }
                }

                final updatedClass = {
                  "name": name,
                  "class": selectedClass.toString(),
                  "grade": selectedGrade.toString(),
                  "exitId": selectedExitKey,
                  "students": classData["students"] ?? [],
                };

                // لو المفتاح اتغير ننقل العقدة
                if (newClassKey != classKey) {
                  await classesRef.child(newClassKey).set(updatedClass);
                  await classesRef.child(classKey).remove();
                } else {
                  await classesRef.child(classKey).update(updatedClass);
                }

                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

}
