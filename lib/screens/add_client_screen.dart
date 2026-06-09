import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AddClientScreen extends StatefulWidget {
  const AddClientScreen({super.key});

  @override
  State<AddClientScreen> createState() => _AddClientScreenState();
}

class _AddClientScreenState extends State<AddClientScreen> {
  final ApiService apiService = ApiService();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController companyController = TextEditingController();

  bool isLoading = false;

  void saveClient() async {
    // التحقق من الحقول الإلزامية
    if (nameController.text.isEmpty || phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إدخال اسم العميل ورقم الهاتف على الأقل')),
      );
      return;
    }

    setState(() => isLoading = true);

    Map<String, dynamic> newClient = {
      "name": nameController.text,
      "phone": phoneController.text,
      "email": emailController.text.isEmpty ? null : emailController.text,
      "company_name": companyController.text.isEmpty ? null : companyController.text,
    };

    bool success = await apiService.createClient(newClient);

    setState(() => isLoading = false);

    if (success) {
      if (mounted) {
        Navigator.pop(context, true); // إغلاق الشاشة وإرسال إشارة نجاح
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('فشل في إضافة العميل!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة عميل جديد'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'اسم العميل (إلزامي)',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'رقم الهاتف (إلزامي)',
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'البريد الإلكتروني (اختياري)',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: companyController,
              decoration: const InputDecoration(
                labelText: 'اسم الشركة (اختياري)',
                prefixIcon: Icon(Icons.business),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading ? null : saveClient,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
                child: isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('حفظ العميل', style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
