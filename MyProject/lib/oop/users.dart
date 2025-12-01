import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:prototype1/pages/adminsPage.dart';

class UserC {
  String? fullname;
  String? email;
  String? phoneNumber;
  String? role;
  String? userId;
  String? password;

  UserC({
    this.fullname,
    this.email,
    this.phoneNumber,
    this.role,
    this.userId,
    this.password,
  });
  Future<void> signin(
    String emailcontroller,
    String passwordcontroller,
    BuildContext context,
  ) async {
    email = emailcontroller;
    password = passwordcontroller;
    try {
      UserCredential userAuth = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email!, password: password!);
      print("verified : ${userAuth.user!.emailVerified}");
      DocumentSnapshot userInfo = await FirebaseFirestore.instance
          .collection('users')
          .doc(userAuth.user!.uid)
          .get();
      fullname = userInfo['FullName'];
      role = userInfo['Role'];
      if (role == "Admin") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Adminspage()),
        );
      } else if (role == "Patient") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Adminspage()),
        );
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("مرحبا بك في عيادتنا 😝 $fullname"),
          showCloseIcon: true,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("حدث خطأ غير متوقع")));
      print("Error: $e");
    }
  }
}
