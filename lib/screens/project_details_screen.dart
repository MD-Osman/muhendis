import 'package:flutter/material.dart';
import '../models/project_model.dart';

class ProjectDetailsScreen extends StatelessWidget {
  // الشاشة تطلب تمرير بيانات المشروع كشرط أساسي عند فتحها
  final ProjectModel project;

  const ProjectDetailsScreen({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(project.projectCode), // نضع كود المشروع في شريط العنوان
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // بطاقة علوية تعرض الحالة ونسبة الإنجاز
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('حالة المشروع:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Chip(
                          label: Text(project.status, style: const TextStyle(color: Colors.white)),
                          backgroundColor: project.progress == 100 ? Colors.green : Colors.orange,
                        ),
                      ],
                    ),
                    const Divider(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('نسبة الإنجاز:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('${project.progress}%', style: const TextStyle(fontSize: 18, color: Colors.indigo, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    LinearProgressIndicator(
                      value: project.progress / 100,
                      backgroundColor: Colors.grey.shade200,
                      color: project.progress == 100 ? Colors.green : Colors.indigo,
                      minHeight: 10,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 30),
            
            // تفاصيل إضافية
            const Text('المعلومات الأساسية:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.indigo)),
            const SizedBox(height: 15),
            ListTile(
              leading: const Icon(Icons.category, color: Colors.indigo),
              title: const Text('نوع المشروع'),
              subtitle: Text(project.taskTypeKey, style: const TextStyle(fontSize: 16)),
            ),
            
            // لاحقاً سنضيف هنا أزرار مثل (تعديل الحالة، إضافة مهام، ربط بعميل، الخ...)
          ],
        ),
      ),
    );
  }
}