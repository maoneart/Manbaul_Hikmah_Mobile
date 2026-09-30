import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../models/student.dart';
import '../../theme/app_theme.dart';

class StudentNametagScreen extends StatelessWidget {
  final Student student;

  const StudentNametagScreen({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kartu Name Tag Digital', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.gojekGreen,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
                    )
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
                          student.name.isNotEmpty ? student.name[0] : 'S',
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.amber),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      student.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      student.className,
                      style: const TextStyle(color: Colors.amberAccent, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      'NISN: ' + student.nisn,
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
                        data: student.qrCodeToken,
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
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Kartu siap dicetak atau disimpan sebagai PDF!')),
                  );
                },
                icon: const Icon(Icons.print, size: 18),
                label: const Text('Cetak Name Tag Ini'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.gojekGreen,
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
