import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddAppointmentPage extends StatefulWidget {
  const AddAppointmentPage({super.key});

  @override
  State<AddAppointmentPage> createState() => _AddAppointmentPageState();
}

class _AddAppointmentPageState extends State<AddAppointmentPage> {
  String? selectedDoctorId;
  String? selectedDoctorName;
  String? selectedTime;

  /// 1️⃣ عرض Dialog لاختيار الطبيب
  void _showDoctorsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('اختر طبيب'),
          content: SizedBox(
            width: double.maxFinite,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Doctors')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final doctorId = data['DoctorID'] ?? docs[index].id;
                    final doctorName = data['FullName'] ?? 'No Name';
                    final workingHours = List<String>.from(
                      data['WorkingHours'] ?? [],
                    );

                    return Card(
                      child: ListTile(
                        title: Text(doctorName),
                        subtitle: Text(
                          data['Specialization'] ?? 'لا يوجد تخصص',
                        ),
                        onTap: () {
                          setState(() {
                            selectedDoctorId = doctorId;
                            selectedDoctorName = doctorName;
                            selectedTime =
                                null; // إعادة تعيين الوقت عند تغيير الطبيب
                          });
                          Navigator.of(context).pop();
                          _showTimesDialog(doctorName, workingHours);
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  /// 2️⃣ التحقق إذا الوقت متاح
  Future<bool> isTimeAvailable(
    String doctorId,
    String time,
    DateTime date,
  ) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('Appointments')
        .where('doctorId', isEqualTo: doctorId)
        .where('time', isEqualTo: time)
        .where('date', isEqualTo: date.toIso8601String().substring(0, 10))
        .get();

    return snapshot.docs.isEmpty;
  }

  /// 3️⃣ عرض Dialog لاختيار الوقت
  void _showTimesDialog(String doctorName, List<String> times) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('الأوقات المتاحة لـ $doctorName'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: times.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    title: Text(times[index]),
                    onTap: () async {
                      // تحقق من توفر الوقت
                      bool available = await isTimeAvailable(
                        selectedDoctorId!,
                        times[index],
                        DateTime.now(),
                      );

                      if (!available) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('هذا الوقت محجوز بالفعل')),
                        );
                        return;
                      }

                      setState(() {
                        selectedTime = times[index];
                      });

                      Navigator.of(context).pop();
                      print('تم اختيار الوقت: $selectedTime');
                    },
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  /// 4️⃣ حفظ الموعد في Firestore
  Future<void> saveAppointment({
    required String doctorId,
    required String doctorName,
    required String time,
  }) async {
    final collection = FirebaseFirestore.instance.collection('Appointments');
    final thisUser = FirebaseAuth.instance.currentUser;

    if (thisUser == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('يجب تسجيل الدخول أولاً')));
      return;
    }

    final patientId = thisUser.uid;
    final date = DateTime.now().toIso8601String().substring(0, 10);

    await collection.add({
      'doctorId': doctorId,
      'doctorName': doctorName,
      'patientId': patientId,
      'time': time,
      'date': date,
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('تم حفظ الموعد بنجاح')));
    print('تم حفظ الموعد بنجاح');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('إضافة موعد')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('الطبيب المختار: ${selectedDoctorName ?? "لم يتم الاختيار"}'),
            SizedBox(height: 10),
            Text('الوقت المختار: ${selectedTime ?? "لم يتم الاختيار"}'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _showDoctorsDialog,
              child: Text('اختر طبيب ووقت'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (selectedDoctorId != null &&
                    selectedDoctorName != null &&
                    selectedTime != null) {
                  // تحقق من توفر الوقت قبل الحجز
                  bool available = await isTimeAvailable(
                    selectedDoctorId!,
                    selectedTime!,
                    DateTime.now(),
                  );

                  if (available) {
                    await saveAppointment(
                      doctorId: selectedDoctorId!,
                      doctorName: selectedDoctorName!,
                      time: selectedTime!,
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('هذا الوقت محجوز بالفعل')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('يرجى اختيار طبيب ووقت قبل الحجز')),
                  );
                }
              },
              child: Text('حجز'),
            ),
          ],
        ),
      ),
    );
  }
}
