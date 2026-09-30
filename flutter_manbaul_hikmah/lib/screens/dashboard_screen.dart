import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/school_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/gojek_widgets.dart';
import 'attendance/qr_scanner_screen.dart';
import 'students/student_list_screen.dart';
import 'students/student_nametag_screen.dart';

class DashboardScreen extends StatelessWidget {
  final Function(int) onNavigateTab;

  const DashboardScreen({super.key, required this.onNavigateTab});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SchoolProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7), // iOS Grouped Background
      body: SafeArea(
        child: RefreshIndicator(
          color: const Color(0xFF00B14F),
          onRefresh: () => provider.loadDataFromApi(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Dynamic Island, Greeting & Apple Card
                const GojekHeader(),

                const SizedBox(height: 12),

                // ==========================================
                // 2. BENTO-BOX: REKAP KEHADIRAN HARI INI
                // ==========================================
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.analytics_rounded, size: 18, color: Color(0xFF00B14F)),
                                SizedBox(width: 8),
                                Text(
                                  'Statistik Presensi',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1C1C1E),
                                    letterSpacing: -0.2,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFF34C759).withOpacity(0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${provider.students.isNotEmpty ? (provider.hadirCount / provider.students.length * 100).round() : 0}% Terisi',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF28A745),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // 4 Bento Stats Cards
                        Row(
                          children: [
                            _buildBentoStat(
                              label: 'Hadir',
                              value: provider.hadirCount.toString(),
                              color: const Color(0xFF34C759), // iOS Emerald
                              icon: Icons.check_circle_rounded,
                            ),
                            const SizedBox(width: 8),
                            _buildBentoStat(
                              label: 'Sakit',
                              value: provider.sakitCount.toString(),
                              color: const Color(0xFF007AFF), // iOS Blue
                              icon: Icons.medical_services_rounded,
                            ),
                            const SizedBox(width: 8),
                            _buildBentoStat(
                              label: 'Izin',
                              value: provider.izinCount.toString(),
                              color: const Color(0xFFFF9500), // iOS Orange
                              icon: Icons.event_note_rounded,
                            ),
                            const SizedBox(width: 8),
                            _buildBentoStat(
                              label: 'Alfa',
                              value: provider.alfaCount.toString(),
                              color: const Color(0xFFFF2D55), // iOS Rose Red
                              icon: Icons.cancel_rounded,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ==========================================
                // 3. 8-GRID MENU LAYANAN SEKOLAH (iOS SQUIRCLES)
                // ==========================================
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Layanan Manbaul Hikmah',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1C1C1E),
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      GridView.count(
                        crossAxisCount: 4,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 10,
                        children: [
                          _buildIosMenuItem(
                            icon: Icons.qr_code_scanner_rounded,
                            label: 'Presensi QR',
                            gradientColors: [const Color(0xFF00B14F), const Color(0xFF008A3D)],
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const QrScannerScreen()),
                              );
                            },
                          ),
                          _buildIosMenuItem(
                            icon: Icons.people_alt_rounded,
                            label: 'Data Siswa',
                            gradientColors: [const Color(0xFF007AFF), const Color(0xFF0051A8)],
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const StudentListScreen()),
                              );
                            },
                          ),
                          _buildIosMenuItem(
                            icon: Icons.badge_rounded,
                            label: 'Kartu QR',
                            gradientColors: [const Color(0xFFAF52DE), const Color(0xFF7A25A8)],
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const StudentNametagScreen()),
                              );
                            },
                          ),
                          _buildIosMenuItem(
                            icon: Icons.account_balance_wallet_rounded,
                            label: 'Tabungan',
                            gradientColors: [const Color(0xFFFF9500), const Color(0xFFC76F00)],
                            onTap: () => onNavigateTab(2),
                          ),
                          _buildIosMenuItem(
                            icon: Icons.campaign_rounded,
                            label: 'Warta',
                            gradientColors: [const Color(0xFFFF2D55), const Color(0xFFCC1F40)],
                            onTap: () => onNavigateTab(3),
                          ),
                          _buildIosMenuItem(
                            icon: Icons.table_chart_rounded,
                            label: 'Rekap Excel',
                            gradientColors: [const Color(0xFF34C759), const Color(0xFF1F9E3F)],
                            onTap: () => _exportAttendanceDialog(context, provider),
                          ),
                          _buildIosMenuItem(
                            icon: Icons.file_upload_rounded,
                            label: 'Import CSV',
                            gradientColors: [const Color(0xFF00C7BE), const Color(0xFF008E88)],
                            onTap: () => _importStudentsDialog(context, provider),
                          ),
                          _buildIosMenuItem(
                            icon: Icons.settings_rounded,
                            label: 'Pengaturan',
                            gradientColors: [const Color(0xFF8E8E93), const Color(0xFF636366)],
                            onTap: () => onNavigateTab(4),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                // ==========================================
                // 4. WARTA & PENGUMUMAN SEKOLAH (APPLE NEWS STYLE)
                // ==========================================
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Warta Resmi Pesantren',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1C1C1E),
                              letterSpacing: -0.2,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => onNavigateTab(3),
                            child: const Text(
                              'Lihat Semua',
                              style: TextStyle(
                                color: Color(0xFF00B14F),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 120,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemCount: provider.announcements.length,
                          itemBuilder: (context, idx) {
                            final a = provider.announcements[idx];
                            return Container(
                              width: 270,
                              margin: const EdgeInsets.only(right: 12),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.03),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: a.isUrgent
                                              ? const Color(0xFFFF2D55).withOpacity(0.12)
                                              : const Color(0xFF007AFF).withOpacity(0.12),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          a.isUrgent ? 'PENTING' : a.category.toUpperCase(),
                                          style: TextStyle(
                                            color: a.isUrgent ? const Color(0xFFFF2D55) : const Color(0xFF007AFF),
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        a.date,
                                        style: TextStyle(color: Colors.grey.shade500, fontSize: 10),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    a.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: Color(0xFF1C1C1E),
                                      letterSpacing: -0.2,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    a.content,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade600,
                                      height: 1.3,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // HELPER WIDGETS
  // ==========================================

  Widget _buildBentoStat({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: color,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color.withOpacity(0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIosMenuItem({
    required IconData icon,
    required String label,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(17), // iOS Squircle
              boxShadow: [
                BoxShadow(
                  color: gradientColors.first.withOpacity(0.28),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 26),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1C1C1E),
              letterSpacing: -0.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  void _exportAttendanceDialog(BuildContext context, SchoolProvider provider) {
    final csv = provider.exportAttendanceToCsv();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Export Rekap Excel', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Data rekap presensi seluruh siswa kompatibel Excel:', style: TextStyle(fontSize: 12)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
              height: 110,
              width: double.infinity,
              child: SingleChildScrollView(child: Text(csv, style: const TextStyle(fontSize: 11, fontFamily: 'monospace'))),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Tutup')),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00B14F)),
            icon: const Icon(Icons.copy_rounded, size: 16, color: Colors.white),
            label: const Text('Salin CSV', style: TextStyle(color: Colors.white)),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: csv));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Rekap presensi disalin ke clipboard!')),
              );
            },
          ),
        ],
      ),
    );
  }

  void _importStudentsDialog(BuildContext context, SchoolProvider provider) {
    final template = provider.getStudentImportTemplateCsv();
    final inputCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Import Siswa Excel/CSV', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade200, foregroundColor: Colors.black87),
                icon: const Icon(Icons.download_rounded, size: 16),
                label: const Text('Salin Template Excel/CSV', style: TextStyle(fontSize: 12)),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: template));
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Template CSV disalin!')));
                },
              ),
              const SizedBox(height: 10),
              TextField(
                controller: inputCtrl,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Tempelkan data CSV di sini...\n$template',
                  hintStyle: const TextStyle(fontSize: 11),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00B14F)),
            onPressed: () async {
              final text = inputCtrl.text.trim();
              if (text.isEmpty) return;
              final res = await provider.importStudentsFromCsv(text);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(res['message'] ?? 'Import selesai')),
              );
            },
            child: const Text('Import', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
