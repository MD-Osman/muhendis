import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/client_model.dart';
import 'add_client_screen.dart'; // استدعاء شاشتك الجاهزة

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  final ApiService apiService = ApiService();
  List<ClientModel> clients = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadClients();
  }

  // جلب العملاء من السيرفر
  Future<void> _loadClients() async {
    setState(() => isLoading = true);
    try {
      final data = await apiService.fetchClients();
      setState(() {
        clients = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في جلب العملاء: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('إدارة العملاء', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : clients.isEmpty
                ? const Center(child: Text('لا يوجد عملاء مضافين حالياً', style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: clients.length,
                    itemBuilder: (context, index) {
                      final client = clients[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Colors.indigo,
                            child: Icon(Icons.person, color: Colors.white),
                          ),
                          title: Text(client.name ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(client.phone ?? ''),
                          trailing: client.companyName != null && client.companyName!.isNotEmpty
                              ? Chip(
                                  label: Text(client.companyName!, style: const TextStyle(fontSize: 10, color: Colors.white)),
                                  backgroundColor: Colors.indigo.shade300,
                                )
                              : null,
                        ),
                      );
                    },
                  ),
        // زر الإضافة الذي يوجه لشاشتك الجاهزة
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddClientScreen()),
            ).then((_) {
              // هذه الدالة تعمل تلقائياً عند العودة من شاشة الإضافة لكي تقوم بتحديث القائمة
              _loadClients(); 
            });
          },
          backgroundColor: Colors.indigo,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}