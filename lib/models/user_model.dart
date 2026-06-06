class UserModel {
  final int id;
  final String username;
  final String fullName;
  final String role;

  UserModel({
    required this.id,
    required this.username,
    required this.fullName,
    required this.role,
  });

  // هذه الدالة السحرية تأخذ الرد القادم من بايثون (JSON) وتحوله لكائن في فلاتر
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      username: json['username'],
      // لاحظ أننا نستخدم نفس الاسم بالضبط كما كتبناه في بايثون (full_name)
      fullName: json['full_name'], 
      role: json['role'],
    );
  }

  // هذه الدالة عكسية: تأخذ بيانات فلاتر وتحولها لـ JSON لإرسالها للباك إند
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'full_name': fullName,
      'role': role,
    };
  }
}