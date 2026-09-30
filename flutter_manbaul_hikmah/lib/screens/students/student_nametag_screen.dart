import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../models/student.dart';
import '../../providers/school_provider.dart';
import '../../theme/app_theme.dart';

class StudentNametagScreen extends StatefulWidget {
  final Student? student;

  const StudentNametagScreen({super.key, this.student});

  @override
  State<StudentNametagScreen> createState() => _StudentNametagScreenState();
}

class _StudentNametagScreenState extends State<StudentNametagScreen> {
  Student? _activeStudent;

  @override
  void initState() {
    super.initState();
    _activeStudent = widget.student;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SchoolProvider>(context);
    final isWaliMurid = provider.currentRole == 'wali_murid';
    final students = provider.allStudents;

    if (isWaliMurid) {
      _activeStudent = provider.myChildStudent;
    } else if (_activeStudent == null && students.isNotEmpty) {
      _activeStudent = students.first;
    }

    final currentStudent = _activeStudent;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        title: const Text('Kartu Name Tag Digital QR', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF00B14F),
        elevation: 0,
      ),
      body: currentStudent == null
          ? const Center(child: Text('Belum ada data siswa untuk dicetak.'))
          : Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Student Selector Dropdown (Hanya jika Guru / Staff / Admin)
                    if (!isWaliMurid)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
                          ],
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            isExpanded: true,
                            value: currentStudent.id,
                            items: students.map((s) {
                              return DropdownMenuItem<int>(
                                value: s.id,
                                child: Text('${s.name} (${s.className})', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                              );
                            }).toList(),
                            onChanged: (id) {
                              if (id != null) {
                                setState(() {
                                  _activeStudent = students.firstWhere((s) => s.id == id);
                                });
                              }
                            },
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2)),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.badge_rounded, color: Color(0xFF00B14F), size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Kartu Siswa: ${currentStudent.name} (${currentStudent.className})',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1C1C1E)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 20),

                    // Digital Card Preview
                    Container(
                      width: 290,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF064E3B), Color(0xFF042F2E), Color(0xFF111827)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.amber, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: Colors.amber,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                alignment: Alignment.center,
                                child: const Text('MH', style: TextStyle(color: Color(0xFF064E3B), fontWeight: FontWeight.w900, fontSize: 14)),
                              ),
                              const SizedBox(width: 8),
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('MANBAUL HIKMAH', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 0.5)),
                                  Text('Kartu Pelajar & Presensi Digital', style: TextStyle(color: Colors.white70, fontSize: 9)),
                                ],
                              ),
                            ],
                          ),
                          const Divider(color: Colors.white24, height: 24),
                          CircleAvatar(
                            radius: 36,
                            backgroundColor: Colors.amber,
                            child: CircleAvatar(
                              radius: 33,
                              backgroundColor: const Color(0xFF064E3B),
                              child: Text(
                                currentStudent.name.isNotEmpty ? currentStudent.name[0] : 'S',
                                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.amber),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            currentStudent.name,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            currentStudent.className,
                            style: const TextStyle(color: Colors.amberAccent, fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            'NISN: ${currentStudent.nisn}',
                            style: const TextStyle(color: Colors.white70, fontSize: 11),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.amber, width: 2),
                            ),
                            child: QrImageView(
                              data: currentStudent.qrCodeToken,
                              version: QrVersions.auto,
                              size: 140.0,
                              eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Color(0xFF064E3B)),
                              dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: Color(0xFF064E3B)),
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text('Scan untuk Presensi & Tabungan', style: TextStyle(color: Colors.white70, fontSize: 9)),
                          const Divider(color: Colors.white24, height: 20),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('T.A 2026/2027', style: TextStyle(color: Colors.white38, fontSize: 9)),
                              Text('Official Digital ID', style: TextStyle(color: Colors.white38, fontSize: 9)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Kartu Name Tag ${currentStudent.name} siap dicetak!')),
                        );
                      },
                      icon: const Icon(Icons.print_rounded, size: 18),
                      label: const Text('Cetak Name Tag Ini'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00B14F),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
