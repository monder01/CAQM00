import 'package:flutter/material.dart';
import 'package:prototype1/oop/appointments.dart';

class AddAppointmentPage extends StatefulWidget {
  const AddAppointmentPage({super.key});

  @override
  State<AddAppointmentPage> createState() => _AddAppointmentPageState();
}

class _AddAppointmentPageState extends State<AddAppointmentPage> {
  Appointment appointment = Appointment();
  String? selectedDoctorId;
  String? selectedDoctorName;
  String? selectedTime;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('إضافة موعد جديد'),
        backgroundColor: Colors.amberAccent[200],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: Size(300, 100),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: () async {
                final result = await appointment.showDoctorsDialog(context);
                if (result != null) {
                  setState(() {
                    selectedDoctorId = result['doctorId'];
                    selectedDoctorName = result['doctorName'];
                    selectedTime = result['time'];
                  });
                }
              },
              child: Text('اختر طبيب ووقت'),
            ),
            SizedBox(height: 20),
            Text('الطبيب المختار: ${selectedDoctorName ?? "لم يتم الاختيار"}'),
            SizedBox(height: 10),
            Text('الوقت المختار: ${selectedTime ?? "لم يتم الاختيار"}'),
            Divider(),
            ElevatedButton(
              onPressed: () async {
                if (selectedDoctorId != null &&
                    selectedDoctorName != null &&
                    selectedTime != null) {
                  await appointment.saveAppointment(
                    doctorId: selectedDoctorId!,
                    doctorName: selectedDoctorName!,
                    time: selectedTime!,
                  );

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('تم حفظ الموعد بنجاح')),
                  );

                  setState(() {
                    selectedDoctorId = null;
                    selectedDoctorName = null;
                    selectedTime = null;
                  });
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
