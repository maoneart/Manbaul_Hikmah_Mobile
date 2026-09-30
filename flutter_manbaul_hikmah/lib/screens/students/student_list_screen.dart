import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/school_provider.dart';
import '../../theme/app_theme.dart';
import 'student_nametag_screen.dart';

class StudentListScreen extends StatelessWidget {
  const StudentListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SchoolProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Siswa & Name Tag', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.gojekGreen,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () => _showAddStudentDialog(context, provider),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: provider.students.length,
        itemBuilder: (context, idx) {
          final s = provider.students[idx];
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppTheme.gojekLightGreen,
                child: Text(s.name.isNotEmpty ? s.name[0] : 'S', style: const TextStyle(color: AppTheme.gojekDarkGreen, fontWeight: FontWeight.bold)),
              ),
              title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('NISN: ' + s.nisn + ' • ' + s.className, style: const TextStyle(fontSize: 11)),
                  Text('Wali: ' + s.parentName + ' (' + s.parentPhone + ')', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
              trailing: ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => StudentNametagScreen(student: s)));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple.shade50,
                  foregroundColor: Colors.purple.shade700,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.badge, size: 14),
                    SizedBox(width: 4),
                    Text('Name Tag', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showAddStudentDialog(BuildContext context, SchoolProvider provider) {
    final nisnCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final parentNameCtrl = TextEditingController();
    final parentPhoneCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tambah Siswa Baru', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nisnCtrl, decoration: const InputDecoration(labelText: 'NISN')),
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nama Lengkap')),
              TextField(controller: parentNameCtrl, decoration: const InputDecoration(labelText: 'Nama Wali Murid')),
              TextField(controller: parentPhoneCtrl, decoration: const InputDecoration(labelText: 'No. HP Wali')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              if (nisnCtrl.text.isNotEmpty && nameCtrl.text.isNotEmpty) {
                provider.addStudent(
                  nisnCtrl.text.trim(),
                  nameCtrl.text.trim(),
                  'L',
                  provider.activeClass,
                  parentNameCtrl.text.trim(),
                  parentPhoneCtrl.text.trim(),
                );
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Siswa baru berhasil ditambahkan!')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.gojekGreen),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}
