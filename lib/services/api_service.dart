import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/project_model.dart';
import '../models/client_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // عنوان السيرفر (يعمل الآن بنجاح عبر كابل الـ USB)
  static const String baseUrl = 'http://127.0.0.1:8000';

  // --- الدالة الأولى: جلب المشاريع من السيرفر (التي كانت موجودة) ---
  Future<List<ProjectModel>> fetchProjects() async {
    final response = await http.get(Uri.parse('$baseUrl/projects/'));

    if (response.statusCode == 200) {
      // استقبال البيانات وتحويلها إلى قائمة
      List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      return body.map((dynamic item) => ProjectModel.fromJson(item)).toList();
    } else {
      throw Exception('فشل في تحميل المشاريع من السيرفر');
    }
  }

  // --- الدالة الثانية (الجديدة): إضافة مشروع جديد إلى السيرفر ---
  Future<bool> createProject(Map<String, dynamic> projectData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/projects/'),
        headers: {
          'Content-Type': 'application/json'
        }, // نخبر السيرفر أننا نرسل JSON
        body: jsonEncode(projectData), // تحويل بيانات المشروع لنص يفهمه الباك إند
      );

      // إذا كان رد السيرفر 200 (نجاح)
      if (response.statusCode == 200) {
        return true;
      } else {
        print('خطأ من السيرفر: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('خطأ في الاتصال: $e');
      return false;
    }
  }
  // ------------------ قسم العملاء ------------------

  // دالة جلب قائمة العملاء
  Future<List<ClientModel>> fetchClients() async {
    final response = await http.get(Uri.parse('$baseUrl/clients/'));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      return body.map((dynamic item) => ClientModel.fromJson(item)).toList();
    } else {
      throw Exception('فشل في تحميل العملاء من السيرفر');
    }
  }

  // دالة إضافة عميل جديد
  Future<bool> createClient(Map<String, dynamic> clientData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/clients/'),
        headers: {
          'Content-Type': 'application/json'
        },
        body: jsonEncode(clientData),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('خطأ من السيرفر: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('خطأ في الاتصال: $e');
      return false;
    }
  }

  // دالة تسجيل الدخول
// دالة تسجيل الدخول المحسنة
  Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login/'),
        headers: {
          "Content-Type": "application/json"
        },
        body: jsonEncode({
          "email": email.trim(), // trim تزيل أي مسافة فارغة بالخطأ
          "password": password.trim()
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // حفظ التذكرة (Token)
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['access_token']);
        await prefs.setString('role', data['role'] ?? 'مهندس'); // حماية من القيم الفارغة
        await prefs.setString('name', data['name'] ?? 'مستخدم');

        return true;
      } else {
        print('Server Rejected: ${response.body}');
      }
    } catch (e) {
      // طباعة الخطأ الحقيقي في شاشة الكونسول لكي نعرف المشكلة
      print('Flutter Login Crash: $e');
    }
    return false;
  }
  // ------------------ قسم الإحصائيات (Dashboard) ------------------

  // دالة جلب المشاريع الخاصة بالصفحة الرئيسية
  Future<List<dynamic>> getProjects() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      final response = await http.get(
        Uri.parse('$baseUrl/projects/'),
        headers: {
          "Content-Type": "application/json",
          if (token != null) "Authorization": "Bearer $token"
        },
      );

      if (response.statusCode == 200) {
        // فك تشفير البيانات لدعم اللغة العربية
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else {
        print('فشل جلب المشاريع: ${response.statusCode}');
      }
    } catch (e) {
      print('خطأ في الاتصال: $e');
    }
    return []; // إرجاع قائمة فارغة في حال حدوث خطأ
  }
}
