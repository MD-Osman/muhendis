class ClientModel {
  final int id;
  final String name;
  final String phone;
  final String? email; // علامة الاستفهام تعني أن الإيميل اختياري (قد يكون فارغاً)
  final String? companyName; // اسم الشركة اختياري

  ClientModel({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.companyName,
  });

  // دالة تحويل البيانات القادمة من السيرفر (JSON) إلى كائن في فلاتر
  factory ClientModel.fromJson(Map<String, dynamic> json) {
    return ClientModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'غير محدد',
      phone: json['phone'] ?? 'غير محدد',
      email: json['email'],
      companyName: json['company_name'],
    );
  }

  // دالة إرسال البيانات من فلاتر إلى السيرفر
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'company_name': companyName,
    };
  }
}