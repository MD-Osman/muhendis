import 'package:flutter/material.dart';
import '../models/client_model.dart';

class ClientCard extends StatelessWidget {
  final ClientModel client;

  const ClientCard({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        // أيقونة دائرية بجانب الاسم
        leading: CircleAvatar(
          backgroundColor: Colors.indigo.shade50,
          radius: 25,
          child: const Icon(Icons.person, color: Colors.indigo, size: 30),
        ),
        title: Text(
          client.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 5),
            Row(
              children: [
                const Icon(Icons.phone, size: 16, color: Colors.grey),
                const SizedBox(width: 5),
                Text(client.phone, style: const TextStyle(fontSize: 15)),
              ],
            ),
            // إذا كان اسم الشركة موجوداً (غير فارغ)، نعرضه
            if (client.companyName != null && client.companyName!.isNotEmpty) ...[
              const SizedBox(height: 5),
              Row(
                children: [
                  const Icon(Icons.business, size: 16, color: Colors.grey),
                  const SizedBox(width: 5),
                  Text(client.companyName!, style: const TextStyle(color: Colors.indigo)),
                ],
              ),
            ]
          ],
        ),
        // زر اتصال سريع (سنبرمجه لاحقاً)
        trailing: IconButton(
          icon: const Icon(Icons.call, color: Colors.green),
          onPressed: () {
            // كود الاتصال بالرقم
          },
        ),
      ),
    );
  }
}
