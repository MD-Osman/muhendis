import 'package:flutter/material.dart';
import '../models/project_model.dart';
import '../services/api_service.dart';
import '../widgets/project_card.dart';
import 'add_project_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService apiService = ApiService();
  late Future<List<ProjectModel>> futureProjects;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // عند فتح الشاشة، نقوم بطلب البيانات من السيرفر
    futureProjects = apiService.fetchProjects();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('ProjexID - المشاريع', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: _currentIndex == 0
          ? FutureBuilder<List<ProjectModel>>(
              future: futureProjects,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('خطأ: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('لا توجد مشاريع حالياً'));
                }

                // عرض المشاريع الحقيقية القادمة من الباك إند
                return ListView.builder(
                  padding: const EdgeInsets.only(top: 16, bottom: 80),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    return ProjectCard(project: snapshot.data![index]);
                  },
                );
              },
            )
          : Center(child: Text(_currentIndex == 1 ? '👥 العملاء' : '💰 المالية')),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'المشاريع'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'العملاء'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: 'المالية'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // ننتظر حتى تعود الشاشة، إذا عادت بـ true نقوم بتحديث القائمة
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddProjectScreen()),
          );

          if (result == true) {
            setState(() {
              // إعادة جلب المشاريع من السيرفر لتحديث الشاشة
              futureProjects = apiService.fetchProjects(); 
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('✅ تم إضافة المشروع بنجاح!')),
            );
          }
        },
        backgroundColor: Colors.indigo,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
