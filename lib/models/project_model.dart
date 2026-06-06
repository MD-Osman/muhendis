class ProjectModel {
  final int id;
  final String projectCode; // كود المشروع (مثل PRD-001)
  final String taskTypeKey; // نوع المشروع (تصميم، تنفيذ، الخ)
  final String status;      // الحالة (waiting, in_progress, done)
  final int progress;       // نسبة الإنجاز 0 - 100

  ProjectModel({
    required this.id,
    required this.projectCode,
    required this.taskTypeKey,
    required this.status,
    required this.progress,
  });

  // دالة تحويل JSON من الباك إند إلى كائن في فلاتر
  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'] ?? 0,
      projectCode: json['project_code'] ?? 'غير محدد',
      taskTypeKey: json['task_type_key'] ?? 'عام',
      status: json['status'] ?? 'waiting',
      progress: json['progress'] ?? 0,
    );
  }
}