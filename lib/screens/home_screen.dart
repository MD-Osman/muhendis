import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'login_screen.dart';
import 'clients_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String userName = "جاري التحميل...";
  String userRole = "";

  // ------------------ العدادات والمتغيرات (سبب الخطأ السابق) ------------------
  int totalProjects = 0;
  int activeProjects = 0;
  int completedProjects = 0;
  int delayedProjects = 0;
  
  Map<String, Map<String, int>> projectStats = {
    'تصميم': {'total': 0, 'completed': 0},
    'رخصة بناء': {'total': 0, 'completed': 0},
    'إشراف': {'total': 0, 'completed': 0},
    'تنفيذ': {'total': 0, 'completed': 0},
    'إدارية': {'total': 0, 'completed': 0},
  };

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _fetchDashboardData(); // جلب البيانات فور فتح الشاشة
  }

  // جلب بيانات المستخدم (المدير عثمان)
  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('name') ?? "مستخدم غير معروف";
      userRole = prefs.getString('role') ?? "";
    });
  }

  // جلب إحصائيات المشاريع من السيرفر
  Future<void> _fetchDashboardData() async {
    final api = ApiService();
    List<dynamic> projects = await api.getProjects();

    int active = 0, completed = 0, delayed = 0;

    for (var key in projectStats.keys) {
      projectStats[key]!['total'] = 0;
      projectStats[key]!['completed'] = 0;
    }

    for (var p in projects) {
      String status = p['status'] ?? 'قيد الانتظار';
      String type = p['task_type_key'] ?? '';

      if (status == 'قيد الانتظار' || status == 'قيد التنفيذ') active++;
      if (status == 'مكتمل') completed++;
      if (status == 'متأخر') delayed++;

      if (projectStats.containsKey(type)) {
        projectStats[type]!['total'] = projectStats[type]!['total']! + 1;
        if (status == 'مكتمل') {
          projectStats[type]!['completed'] = projectStats[type]!['completed']! + 1;
        }
      }
    }

    if (mounted) {
      setState(() {
        totalProjects = projects.length;
        activeProjects = active;
        completedProjects = completed;
        delayedProjects = delayed;
      });
    }
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الصفحة الرئيسية', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        
        // ------------------ القائمة الجانبية (Drawer) ------------------
        drawer: Drawer(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 50, bottom: 20),
                color: Colors.indigo.shade900,
                child: const Column(
                  children: [
                    Icon(Icons.engineering, size: 50, color: Colors.white),
                    SizedBox(height: 10),
                    Text('ProjexID', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                    Text('Engineering PM', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _buildDrawerItem(Icons.dashboard, 'الصفحة الرئيسية', true, onTap: () {
                      Navigator.pop(context); // إغلاق الـ Drawer فقط لأننا في الرئيسية بالفعل
                    }),
                    const Divider(),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text('الإدارة', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ),
                    _buildDrawerItem(Icons.people, 'العملاء', false, onTap: () {
                      Navigator.pop(context); // إغلاق الـ Drawer
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ClientsScreen()),
                      ).then((_) => _fetchDashboardData()); // عند العودة للرئيسية، يتم تحديث الإحصائيات تلقائياً!
                    }),
                    _buildDrawerItem(Icons.business_center, 'المشاريع', false),
                    _buildDrawerItem(Icons.assignment_ind, 'مهام المهندسين', false),
                    _buildDrawerItem(Icons.monitor_heart, 'متابعة المشاريع', false),
                    const Divider(),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text('المالية والتقارير', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ),
                    _buildDrawerItem(Icons.account_balance_wallet, 'الشؤون المالية', false),
                    _buildDrawerItem(Icons.picture_as_pdf, 'التقارير', false),
                    const Divider(),
                    _buildDrawerItem(Icons.settings, 'الإعدادات', false),
                    ListTile(
                      leading: const Icon(Icons.exit_to_app, color: Colors.red),
                      title: const Text('تسجيل الخروج', style: TextStyle(color: Colors.red)),
                      onTap: _logout,
                    ),
                  ],
                ),
              ),
              Container(
                color: Colors.grey.shade200,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.indigo,
                    child: Text(userName.isNotEmpty ? userName[0] : "?", style: const TextStyle(color: Colors.white)),
                  ),
                  title: Text(userName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(userRole),
                ),
              )
            ],
          ),
        ),
        
        // ------------------ مساحة العمل والبطاقات ------------------
        body: Container(
          color: Colors.grey.shade100,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'نظرة عامة على المشاريع',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.indigo),
                ),
                const SizedBox(height: 16),

                // القسم الأول: الإحصائيات الإجمالية
                LayoutBuilder(
                  builder: (context, constraints) {
                    double cardWidth = constraints.maxWidth > 600 ? (constraints.maxWidth / 3) - 16 : constraints.maxWidth;
                    return Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        _buildSummaryCard('إجمالي المشاريع', 'Total Projects', '$totalProjects', '$activeProjects نشط', Colors.blue.shade100, Colors.blue.shade900, cardWidth),
                        _buildSummaryCard('مشاريع مكتملة', 'Completed Projects', '$completedProjects', totalProjects > 0 ? '${((completedProjects / totalProjects) * 100).toInt()}% من الإجمالي' : '0% من الإجمالي', Colors.orange.shade100, Colors.orange.shade900, cardWidth),
                        _buildSummaryCard('متأخرة التسليم', 'Delayed / Pending', '$delayedProjects', delayedProjects == 0 ? 'لا تأخيرات!' : 'تحتاج انتباه!', Colors.red.shade100, Colors.red.shade900, cardWidth),
                      ],
                    );
                  }
                ),
                
                const SizedBox(height: 32),
                const Text(
                  'المشاريع حسب النوع',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.indigo),
                ),
                const SizedBox(height: 16),

                // القسم الثاني: الإحصائيات حسب نوع المشروع
                LayoutBuilder(
                  builder: (context, constraints) {
                    double typeCardWidth = constraints.maxWidth > 800 ? (constraints.maxWidth / 5) - 16 : 
                                          constraints.maxWidth > 500 ? (constraints.maxWidth / 3) - 16 : (constraints.maxWidth / 2) - 16;
                    return Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        _buildTypeCard('تصميم', 'Design', '🎨', '${projectStats['تصميم']!['total']}', '${projectStats['تصميم']!['completed']}', '0', typeCardWidth),
                        _buildTypeCard('رخصة بناء', 'Building Permit', '📄', '${projectStats['رخصة بناء']!['total']}', '${projectStats['رخصة بناء']!['completed']}', '0', typeCardWidth),
                        _buildTypeCard('إشراف', 'Supervision', '👁️', '${projectStats['إشراف']!['total']}', '${projectStats['إشراف']!['completed']}', '0', typeCardWidth),
                        _buildTypeCard('تنفيذ', 'Implementation', '🔨', '${projectStats['تنفيذ']!['total']}', '${projectStats['تنفيذ']!['completed']}', '0', typeCardWidth),
                        _buildTypeCard('إدارية', 'Management', '📊', '${projectStats['إدارية']!['total']}', '${projectStats['إدارية']!['completed']}', '0', typeCardWidth),
                      ],
                    );
                  }
                ),

                const SizedBox(height: 32),
                
                // القسم الثالث: آخر النشاطات
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('آخر النشاطات', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      Divider(),
                      SizedBox(height: 40),
                      Center(child: Text('لا توجد نشاطات حالياً', style: TextStyle(color: Colors.grey))),
                      SizedBox(height: 40),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
                
                // القسم الرابع: آخر المشاريع المضافة
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('آخر المشاريع المضافة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          Text('عرض الكل', style: TextStyle(color: Colors.indigo, fontSize: 14, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Divider(),
                      SizedBox(height: 40),
                      Center(child: Text('لا توجد مشاريع مضافة بعد', style: TextStyle(color: Colors.grey))),
                      SizedBox(height: 40),
                    ],
                  ),
                ),
                
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ------------------ الدوال المساعدة لرسم العناصر ------------------

Widget _buildDrawerItem(IconData icon, String title, bool isSelected, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: isSelected ? Colors.indigo : Colors.grey.shade700),
      title: Text(title, style: TextStyle(
        color: isSelected ? Colors.indigo : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      )),
      tileColor: isSelected ? Colors.indigo.withOpacity(0.1) : null,
      onTap: onTap, // تفعيل التفاعل هنا
    );
  }

  Widget _buildSummaryCard(String title, String engTitle, String count, String subtitle, Color bgColor, Color textColor, double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(top: BorderSide(color: textColor, width: 4)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(count, style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
          Text(title, style: TextStyle(fontSize: 16, color: Colors.grey.shade800, fontWeight: FontWeight.bold)),
          Text(engTitle, style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
          const SizedBox(height: 8),
          Text(subtitle, style: TextStyle(color: textColor, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildTypeCard(String title, String engTitle, String icon, String total, String completed, String finished, double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(icon, style: const TextStyle(fontSize: 24)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(engTitle, style: TextStyle(fontSize: 10, color: Colors.grey.shade400)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 15),
          const Center(child: Text('لا توجد مشاريع', style: TextStyle(color: Colors.grey, fontSize: 10))),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('المشاريع', style: TextStyle(fontSize: 10, color: Colors.grey)),
                  Text('مكتملة', style: TextStyle(fontSize: 10, color: Colors.grey)),
                  Text('منتهية', style: TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(total, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  Text(completed, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  Text(finished, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }
}