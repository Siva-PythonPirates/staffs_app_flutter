import 'package:flutter/material.dart';

import 'views/teacher_module/teacher_login_page.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyBmJcG6J4L_4RL2W_TTAQu0T_7pYQwohtQ",
      appId: "1:541005683433:android:678300beee8cdc3f9eae78",
      messagingSenderId: "541005683433",
      projectId: "staffs-app-f8b67",
    ),
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Teacher App',
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: TeacherLogin(),
    );
  }
}

