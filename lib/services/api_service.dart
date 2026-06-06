import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/project_model.dart'; // تأكد أن المسار صحيح لمكان ملف project_model

class ApiService {
  // ملاحظة: 10.0.2.2 هو العنوان المخصص للمحاكي للوصول للكمبيوتر
  static const String baseUrl = 'http://10.0.2.2:8000'; 

  // دالة جلب المشاريع من السيرفر
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
}