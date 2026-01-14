import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:my_safe_school/data/firebase_constant.dart';
import '../../util/Strings.dart';
import '../evacuation/evacuation_screen.dart';

class SelectClassScreen extends StatelessWidget {
  const SelectClassScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = FirebaseDatabase.instance.ref(FirebaseConstant.CLASSES_TABLE_NAME);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F6FB),
        appBar: AppBar(
          title: const Text(Strings.SELECT_CLASS,style: TextStyle(color: Colors.white),),
          centerTitle: true,
          backgroundColor: Colors.indigo,
          elevation: 0,
          leading: const Icon(Icons.school,color: Colors.white,),
        ),

        body: StreamBuilder(
          stream: db.onValue,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text(Strings.ERROR_DATA));
            }

            if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
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
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.1,
              ),
              itemBuilder: (context, index) {
                final key = dataMap.keys.elementAt(index);
                final c = dataMap[key] as Map<dynamic, dynamic>;

                final studentsIds = (c[Strings.STUDENT_KEY] as List<dynamic>?) ?? [];

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
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.indigo.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.class_,
                              size: 36,
                              color: Colors.indigo,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            c[Strings.NAME_KEY] ?? Strings.NO_NAME,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "${Strings.STUDENT_NUMBER} ${studentsIds.length}",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
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
}
