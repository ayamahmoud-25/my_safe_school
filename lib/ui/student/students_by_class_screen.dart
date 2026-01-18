import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:qr_flutter/qr_flutter.dart';

class StudentsByClassScreen extends StatefulWidget {
  final String classKey;
  final String className;
  final String grade;
  final String classNum;

  const StudentsByClassScreen({
    super.key,
    required this.classKey,
    required this.className,
    required this.grade,
    required this.classNum,
  });

  @override
  State<StudentsByClassScreen> createState() => _StudentsByClassScreenState();
}

class _StudentsByClassScreenState extends State<StudentsByClassScreen> {
  final db = FirebaseDatabase.instance.ref();

  final nameCtrl = TextEditingController();
  String qrCode = ""; // هنعرضه على طول
  bool loading = true;
  List<Map<String, dynamic>> students = [];

  @override
  void initState() {
    super.initState();
    loadStudents();
  }

  Future<void> loadStudents() async {
    final classSnap = await db.child("classes/${widget.classKey}/students").get();

    if (!classSnap.exists) {
      setState(() {
        students = [];
        loading = false;
      });
      return;
    }

    List<String> ids = List<String>.from(classSnap.value as List);

    List<Map<String, dynamic>> temp = [];

    for (var id in ids) {
      final studentSnap = await db.child("students/$id").get();
      if (studentSnap.exists) {
        temp.add(Map<String, dynamic>.from(studentSnap.value as Map)..["id"] = id);
      }
    }

    setState(() {
      students = temp;
      loading = false;
    });
  }

  /// ➕ توليد QR code متسلسل
  Future<String> generateStudentId() async {
    final snap = await db.child("students").get();
    if (!snap.exists) return "s001";

    Map data = Map<String, dynamic>.from(snap.value as Map);
    // استخراج آخر رقم
    List<int> numbers = [];
    for (var key in data.keys) {
      String qr = data[key]["qr"] ?? "";
      if (qr.startsWith("s")) {
        int? num = int.tryParse(qr.substring(1));
        if (num != null) numbers.add(num);
      }
    }
    numbers.sort();
    int next = numbers.isEmpty ? 1 : numbers.last + 1;
    return "s${next.toString().padLeft(3, "0")}";
  }

  Future<void> addStudent() async {
    if (nameCtrl.text.isEmpty || qrCode.isEmpty) return;

    final newId = qrCode; // نستخدم QR code كـ unique id

    // 1️⃣ إضافة الطالب
    await db.child("students/$newId").set({
      "name": nameCtrl.text,
      "qr": newId,
      "grade": widget.grade,
      "class": widget.classNum,
      "classKey": widget.classKey,
    });

    // 2️⃣ تحديث قائمة الطلاب داخل الصف
    final classStudentsRef = db.child("classes/${widget.classKey}/students");
    final snap = await classStudentsRef.get();

    List<dynamic> updatedList = [];
    if (snap.exists) {
      updatedList = List<dynamic>.from(snap.value as List);
    }

    updatedList.add(newId);
    await classStudentsRef.set(updatedList);

    nameCtrl.clear();
    qrCode = "";
    loadStudents();
    Navigator.pop(context);
  }

  void showAddDialog() async {
    // توليد QR code جديد عند فتح الديالوج
    qrCode = await generateStudentId();
    setState(() {}); // تحديث العرض

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("إضافة طالبة"),
        content: SingleChildScrollView(
          child: SizedBox(
            width: 300, // عرض ثابت لتجنب مشاكل intrinsic
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // TextField لاسم الطالبة
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: "اسم الطالبة",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),

                // عرض QR code إذا متولد
                if (qrCode.isNotEmpty)
                  Column(
                    children: [
                      Text("كود QR: $qrCode"),
                      const SizedBox(height: 8),
                      Container(
                        color: Colors.white,
                        child:  QrImageView(
                          data: qrCode,
                          version: QrVersions.auto,
                          size: 150, // لازم يكون محدد
                          gapless: false,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            child: const Text("إلغاء"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text("إضافة"),
            onPressed: addStudent,
          ),
        ],
      ),
    );
  }


  /// 🗑️ حذف طالبة
  void confirmDeleteStudent(String studentId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("تأكيد الحذف"),
        content: const Text("هل أنت متأكدة من حذف الطالبة؟"),
        actions: [
          TextButton(
            child: const Text("إلغاء"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text("حذف"),
            onPressed: () async {
              await deleteStudent(studentId);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Future<void> deleteStudent(String studentId) async {
    // 1️⃣ حذف من students
    await db.child("students/$studentId").remove();

    // 2️⃣ حذف من قائمة الصف
    final classStudentsRef = db.child("classes/${widget.classKey}/students");
    final snap = await classStudentsRef.get();
    if (snap.exists) {
      List<dynamic> list = List<dynamic>.from(snap.value as List);
      list.remove(studentId);
      await classStudentsRef.set(list);
    }

    // 3️⃣ تحديث الـ UI
    loadStudents();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text("طالبات ${widget.className}",style: TextStyle(color: Colors.white),),
          backgroundColor: Colors.indigo,
          iconTheme: IconThemeData(
            color: Colors.white, // هنا لون زر الرجوع
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add_photo_alternate_outlined,color: Colors.white,),
              onPressed: showAddDialog,
            ),
          ],
        ),
        body: loading
            ? const Center(child: CircularProgressIndicator())
            : students.isEmpty
            ? const Center(
          child: Text(
            "لا يوجد طالبات",
            style: TextStyle(fontSize: 18),
          ),
        )
            : ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: students.length,
          itemBuilder: (context, index) {
            final s = students[index];
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.person),
                title: Text(
                  s["name"],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text("الصف: ${s["grade"]} - ${s["class"]}"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    QrImageView(
                      data: s["qr"],
                      version: QrVersions.auto,
                      size: 50,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => confirmDeleteStudent(s["id"]),
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
