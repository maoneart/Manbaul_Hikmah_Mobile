import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/school_provider.dart';
import '../../theme/app_theme.dart';
import 'qr_scanner_screen.dart';

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SchoolProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Presensi Siswa QR & Manual', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: AppTheme.gojekGreen,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Scanner Action Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppTheme.gojekDarkGreen, AppTheme.gojekGreen]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Row(
                    children: [
                      Icon(Icons.qr_code_scanner, color: Colors.white, size: 28),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Scan Name Tag Siswa',
                          style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Arahkan kamera ke QR Code Name Tag murid untuk menandai kehadiran instan.',
                    style: TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const QrScannerScreen()));
                          },
                          icon: const Icon(Icons.camera_alt, size: 16),
                          label: const Text('Buka Kamera Scan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppTheme.gojekDarkGreen,
                            elevation: 0,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => _showSimulateScanDialog(context, provider),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple.shade700,
                          foregroundColor: Colors.white,
                          elevation: 0,
                        ),
                        child: const Text('Tes Scan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Class Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Daftar Kehadiran ${provider.activeClass}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textDark),
                ),
                Text(
                  '${provider.students.length} Siswa',
                  style: const TextStyle(fontSize: 12, color: AppTheme.textGrey),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Student Attendance List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: provider.students.length,
              itemBuilder: (context, idx) {
                final student = provider.students[idx];
                final att = provider.getStudentAttendance(student.id);
                final status = att?.status ?? 'Belum Absen';

                Color statusColor = Colors.grey;
                if (status == 'Hadir') statusColor = Colors.green;
                if (status == 'Sakit') statusColor = Colors.blue;
                if (status == 'Izin') statusColor = Colors.amber.shade800;
                if (status == 'Alfa') statusColor = Colors.rose;

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppTheme.gojekLightGreen,
                          child: Text(student.name[0], style: const TextStyle(color: AppTheme.gojekDarkGreen, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(student.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              Text('NISN: ${student.nisn}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                              const SizedBox(height: 2),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  status == 'Hadir' && att?.scanTime != null ? 'Hadir (${att!.scanTime})' : status,
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Quick H, S, I, A buttons
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildStatusBtn(context, provider, student.id, 'Hadir', 'H', Colors.green, status == 'Hadir'),
                            _buildStatusBtn(context, provider, student.id, 'Sakit', 'S', Colors.blue, status == 'Sakit'),
                            _buildStatusBtn(context, provider, student.id, 'Izin', 'I', Colors.amber.shade700, status == 'Izin'),
                            _buildStatusBtn(context, provider, student.id, 'Alfa', 'A', Colors.rose, status == 'Alfa'),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBtn(BuildContext context, SchoolProvider provider, int studentId, String status, String label, Color color, bool isSelected) {
    return GestureDetector(
      onTap: () {
        provider.markAttendance(studentId, status);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(6),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _showSimulateScanDialog(BuildContext context, SchoolProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Simulasi Scan Siswa', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: provider.students.length,
            itemBuilder: (c, i) {
              final s = provider.students[i];
              return ListTile(
                title: Text(s.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                subtitle: Text('NISN: ${s.nisn}', style: const TextStyle(fontSize: 10)),
                trailing: const Icon(Icons.qr_code, color: AppTheme.gojekGreen, size: 20),
                onTap: () {
                  final res = provider.scanQrCode(s.qrCodeToken);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(res), backgroundColor: AppTheme.gojekDarkGreen),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
