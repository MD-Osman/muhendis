import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AddProjectScreen extends StatefulWidget {
  const AddProjectScreen({super.key});

  @override
  State<AddProjectScreen> createState() => _AddProjectScreenState();
}

class _AddProjectScreenState extends State<AddProjectScreen> {
  final ApiService apiService = ApiService();

  // وحدات التحكم لقراءة النص من الحقول
  final TextEditingController codeController = TextEditingController();
  final TextEditingController typeController = TextEditingController();

  bool isLoading = false;

  void saveProject() async {
    if (codeController.text.isEmpty || typeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إدخال كود ونوع المشروع')),
      );
      return;
    }

    setState(() => isLoading = true);

    // تجهيز البيانات لإرسالها
    Map<String, dynamic> newProject = {
      "project_code": codeController.text,
      "task_type_key": typeController.text,
      "status": "قيد الانتظار", // قيمة افتراضية
      "progress": 0 // قيمة افتراضية للتقدم
    };

    bool success = await apiService.createProject(newProject);

    setState(() => isLoading = false);

    if (success) {
      if (mounted) {
        Navigator.pop(context, true); // إغلاق الشاشة وإرسال إشارة نجاح للشاشة السابقة
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('فشل في إضافة المشروع! قد يكون الكود مكرراً.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة مشروع جديد'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: codeController,
              decoration: const InputDecoration(
                labelText: 'كود المشروع (مثال: PRD-006)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: typeController,
              decoration: const InputDecoration(
                labelText: 'نوع المشروع (تصميم، تنفيذ، إشراف...)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading ? null : saveProject,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
                child: isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('حفظ المشروع', style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
