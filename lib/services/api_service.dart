import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/project_model.dart'; // تأكد أن المسار صحيح لمكان ملف project_model

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
        headers: {'Content-Type': 'application/json'}, // نخبر السيرفر أننا نرسل JSON
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
}