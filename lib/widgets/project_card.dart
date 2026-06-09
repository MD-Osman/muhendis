import 'package:flutter/material.dart';
import '../models/project_model.dart';
import '../screens/project_details_screen.dart';

class ProjectCard extends StatelessWidget {
  final ProjectModel project;

  const ProjectCard({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3, // ظل خفيف للبطاقة
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        // لجعل البطاقة قابلة للضغط
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // فتح شاشة التفاصيل وتمرير بيانات المشروع الحالي لها
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProjectDetailsScreen(project: project),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // أيقونة دائرية
              CircleAvatar(
                radius: 25,
                backgroundColor: Colors.indigo.withOpacity(0.1),
                child: const Icon(Icons.apartment, color: Colors.indigo, size: 28),
              ),
              const SizedBox(width: 16),

              // تفاصيل المشروع
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.projectCode,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'النوع: ${project.taskTypeKey} | الحالة: ${project.status}',
                      style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                    ),
                    const SizedBox(height: 12),

                    // شريط الإنجاز (Progress Bar)
                    Row(
                      children: [
                        Expanded(
                          child: LinearProgressIndicator(
                            value: project.progress / 100, // يأخذ قيمة من 0.0 إلى 1.0
                            backgroundColor: Colors.grey.shade200,
                            color: project.progress == 100 ? Colors.green : Colors.indigo,
                            minHeight: 6,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text('${project.progress}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // سهم صغير في النهاية
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
