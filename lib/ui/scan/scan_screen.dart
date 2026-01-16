import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter/services.dart';

import 'result_screen.dart';

class ScanScreen extends StatefulWidget {
  final String classKey;

  const ScanScreen({
    super.key,
    required this.classKey,
  });

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final db = FirebaseDatabase.instance.ref();

  // لاحقًا ممكن نخليها DateTime.now()
  final String today = "2026-01-12";

  final Set<String> scanned = {};

  final MobileScannerController cameraController =
  MobileScannerController(
    torchEnabled: false,
    detectionSpeed: DetectionSpeed.normal,
  );

  Future<void> markPresentFromQR(String studentId) async {
    // منع التكرار
    if (scanned.contains(studentId)) return;

    final studentSnap =
    await db.child("students/$studentId").get();

    if (!studentSnap.exists) return;

    final student =
    Map<String, dynamic>.from(studentSnap.value as Map);

    // تأكد إن الطالبة من نفس الصف
    if (student["classKey"] != widget.classKey) return;

    await db
        .child(
        "evacuations/$today/${widget.classKey}/present/$studentId")
        .set(true);

    await db
        .child(
        "evacuations/$today/${widget.classKey}/absent/$studentId")
        .remove();

    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 80);
    }
    SystemSound.play(SystemSoundType.click);

    setState(() {
      scanned.add(studentId);
    });
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text(
            "مسح بطاقات الطالبات",
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: Colors.red.shade700,

          // 🔙 زر الرجوع
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),

          actions: [
            IconButton(
              icon: const Icon(Icons.flash_on, color: Colors.white),
              onPressed: () {
                cameraController.toggleTorch();
              },
            ),
            IconButton(
              icon: const Icon(Icons.auto_delete_rounded, color: Colors.white),
              onPressed: () {
                deleteEvacuationsTable();
              },
            ),
          ],
        ),
        body: Stack(
          children: [
            MobileScanner(
              controller: cameraController,
              fit: BoxFit.cover,
              onDetect: (barcodeCapture) {
                final barcode = barcodeCapture.barcodes.first;
                final String? studentId = barcode.rawValue;

                if (studentId == null) return;

                markPresentFromQR(studentId);
              },
            ),

            // تعتيم
            Container(color: Colors.black.withOpacity(0.35)),

            // مربع المسح
            Center(
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.greenAccent,
                    width: 4,
                  ),
                ),
              ),
            ),

            // تعليمات
            const Positioned(
              top: 30,
              left: 0,
              right: 0,
              child: Text(
                "وجّهي الكاميرا إلى كود الطالبة",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),

            // لوحة سفلية
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.black87,
                  borderRadius:
                  BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "تم مسح بطاقة  ${scanned.length}  طالبة ",
                      style: const TextStyle(
                        color: Colors.greenAccent,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.assignment_turned_in,color: Colors.white,),
                        label: const Text(
                          "إنهاء الإخلاء وعرض التقرير",
                          style: TextStyle(fontSize: 18,color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ResultScreen(
                                classKey: widget.classKey,
                                date: today,/* grade: '', classNum: ''*/
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Future<void> deleteEvacuationsTable() async {
    final db = FirebaseDatabase.instance.ref();

    try {
      // 1️⃣ حذف جدول exits بالكامل
      await db.child("evacuations").remove();
      print("تم حذف جدول الإخلاء  بالكامل بنجاح!");
    } catch (e) {
      print("حدث خطأ أثناء حذف جدول الإخلاء: $e");
    }
  }
}
