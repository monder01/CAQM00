import 'package:flutter/material.dart';
import 'package:prototype1/pages/addAppointmentPage.dart';
import 'package:prototype1/pages/formPage.dart';

class Appointmentpage extends StatefulWidget {
  const Appointmentpage({super.key});

  @override
  State<Appointmentpage> createState() => _AppointmentpageState();
}

class _AppointmentpageState extends State<Appointmentpage> {
  int i = 0;

  // الصفحات البسيطة
  final List<Widget> _pages = [
    AddAppointmentPage(),
    Formpage(),
    Center(child: Text('الملف الشخصي')),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Appointment Page"),
        backgroundColor: Colors.amberAccent[200], // عنوان شريط التطبيق
      ),
      body: _pages[i],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: i,
        onTap: (index) {
          setState(() {
            i = index; // تغيير الصفحة عند الضغط
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'مواعيدي',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'نماذجي',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'الملف الشخصي',
          ),
        ],
      ),
    );
  }
}
