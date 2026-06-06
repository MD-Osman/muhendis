import 'package:flutter/material.dart';
// استدعاء الشاشة الجديدة
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // إخفاء شريط Debug المزعج
      title: 'ProjexID',
    
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        fontFamily: 'Cairo', 
      ),
      home: const HomeScreen(), // توجيه التطبيق للشاشة الرئيسية
    );
  }
  
}
