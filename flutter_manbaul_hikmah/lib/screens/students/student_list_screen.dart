import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        title: const Text(
          'Data Siswa & Name Tag',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF00B14F),
        elevation: 0,
        actions: [
          // Export CSV Shortcut
          IconButton(
            icon: const Icon(Icons.file_download_rounded, color: Colors.white),
            tooltip: 'Export CSV',
            onPressed: () {
              final csv = provider.exportStudentsToCsv();
              Clipboard.setData(ClipboardData(text: csv));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Data siswa disalin ke clipboard format CSV!')),
              );
            },
          ),
          // Add Student Button (Visible for Walas & Kepsek based on privilege)
          if (provider.canAddStudent)
            IconButton(
              icon: const Icon(Icons.person_add_rounded, color: Colors.white),
              tooltip: 'Tambah Siswa',
              onPressed: () => _showAddStudentDialog(context, provider),
            ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        physics: const BouncingScrollPhysics(),
        itemCount: provider.students.length,
        itemBuilder: (context, idx) {
          final s = provider.students[idx];
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: s.gender == 'L'
                        ? [const Color(0xFF007AFF), const Color(0xFF0051A8)]
                        : [const Color(0xFFFF2D55), const Color(0xFFCC1F40)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    s.name.isNotEmpty ? s.name[0].toUpperCase() : 'S',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              title: Text(
                s.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF1C1C1E),
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 2),
                  Text(
                    'NISN: ${s.nisn} • ${s.className}',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    'Wali: ${s.parentName} (${s.parentPhone})',
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                  ),
                ],
              ),
              trailing: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => StudentNametagScreen(student: s)),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFAF52DE).withOpacity(0.12),
                  foregroundColor: const Color(0xFFAF52DE),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                ),
                icon: const Icon(Icons.badge_rounded, size: 14),
                label: const Text('Name Tag', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
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
    String selectedGender = 'L';
    String selectedClass = provider.activeClass == 'Semua' ? 'Kelas 7A' : provider.activeClass;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Tambah Santri / Siswa',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nisnCtrl,
                  decoration: const InputDecoration(labelText: 'NISN / ID Siswa', hintText: '008xxxxxxx'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Nama Lengkap Siswa'),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Jenis Kelamin: ', style: TextStyle(fontSize: 13)),
                    Radio<String>(
                      value: 'L',
                      groupValue: selectedGender,
                      onChanged: (val) => setState(() => selectedGender = val!),
                    ),
                    const Text('L', style: TextStyle(fontSize: 13)),
                    Radio<String>(
                      value: 'P',
                      groupValue: selectedGender,
                      onChanged: (val) => setState(() => selectedGender = val!),
                    ),
                    const Text('P', style: TextStyle(fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedClass,
                  decoration: const InputDecoration(labelText: 'Kelas'),
                  items: ['Kelas 7A', 'Kelas 7B', 'Kelas 8A', 'Kelas 9A']
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (val) => setState(() => selectedClass = val!),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: parentNameCtrl,
                  decoration: const InputDecoration(labelText: 'Nama Wali Murid'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: parentPhoneCtrl,
                  decoration: const InputDecoration(labelText: 'No. HP / WhatsApp Wali'),
                  keyboardType: TextInputType.phone,
                ),
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
                    selectedGender,
                    selectedClass,
                    parentNameCtrl.text.trim(),
                    parentPhoneCtrl.text.trim(),
                  );
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Siswa baru berhasil didaftarkan dan disinkronkan ke server!')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00B14F)),
              child: const Text('Simpan', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
