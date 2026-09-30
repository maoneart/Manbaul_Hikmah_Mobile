import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/school_provider.dart';
import '../theme/app_theme.dart';
import 'attendance/qr_scanner_screen.dart';
import 'attendance/attendance_screen.dart';
import 'students/student_list_screen.dart';
import 'students/student_nametag_screen.dart';
import 'payments/payment_screen.dart';
import 'schedule/schedule_screen.dart';

class DashboardScreen extends StatelessWidget {
  final Function(int) onNavigateTab;

  const DashboardScreen({super.key, required this.onNavigateTab});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SchoolProvider>(context);
    final user = provider.currentUser;
    final role = provider.currentRole;
    final isWaliKelas = role == 'wali_kelas';
    final isWaliMurid = role == 'wali_murid';
    final isKepsek = role == 'kepsek' || role == 'admin';
    final isStaff = role == 'staff';

    final myChild = provider.myChildStudent;
    final childId = myChild?.id ?? 1;
    final childBills = provider.bills.where((b) => b.studentId == childId).toList();
    final hasUnpaid = childBills.any((b) => b.status != 'Lunas');
    final displayName = isWaliMurid ? (myChild?.name ?? user?['name'] ?? 'Santri') : (user?['name'] ?? 'Ustadz / Ustadzah');
    final subtitleText = isWaliMurid
        ? 'Wali Murid • ${myChild?.className ?? user?['assigned_class'] ?? "Kelas 1A"}'
        : 'Pesantren Manbaul Hikmah';

    final students = provider.students;
    final totalStudents = students.length;
    final hadir = provider.hadirCount;
    final sakit = provider.sakitCount;
    final izin = provider.izinCount;
    final alfa = provider.alfaCount;

    final attendancePercent = totalStudents > 0 ? ((hadir / totalStudents) * 100).round() : 0;

    // Students absent today
    final absentStudents = students.where((s) {
      final att = provider.getStudentAttendance(s.id);
      final st = att?.status ?? 'Alfa';
      return st == 'Sakit' || st == 'Izin' || st == 'Alfa';
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7), // Elegant Institutional Light Grey
      body: SafeArea(
        child: RefreshIndicator(
          color: const Color(0xFF00B14F),
          onRefresh: () => provider.loadDataFromApi(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ==========================================
                // 1. INSTITUTIONAL HEADER & USER GREETING
                // ==========================================
                Container(
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
                  child: Row(
                    children: [
                      // School Emblem Avatar
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF008A3D), Color(0xFF00B14F)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00B14F).withOpacity(0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(Icons.school_rounded, color: Colors.white, size: 26),
                        ),
                      ),
                      const SizedBox(width: 14),

                      // User & Academic Year Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF00B14F).withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    _getRoleBadgeText(role, user?['assigned_class']),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF008A3D),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'TA 2026/2027',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              displayName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1C1C1E),
                                letterSpacing: -0.3,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              subtitleText,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Logout / Profile Icon
                      IconButton(
                        icon: const Icon(Icons.logout_rounded, color: Color(0xFFFF3B30), size: 22),
                        tooltip: 'Keluar Akun',
                        onPressed: () => _confirmLogout(context, provider),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // ==========================================
                // 2. HERO CARD (ROLE-CENTRIC FOCUSED)
                // ==========================================
                if (isWaliKelas)
                  _buildWaliKelasHeroCard(context, provider, totalStudents, hadir, sakit, izin, alfa, attendancePercent)
                else if (isWaliMurid)
                  _buildWaliMuridHeroCard(context, provider)
                else
                  _buildAdminKepsekHeroCard(context, provider, totalStudents, hadir, sakit, izin, alfa, attendancePercent),

                const SizedBox(height: 16),

                // ==========================================
                // 3. ALERT BOX: SISWA TIDAK MASUK HARI INI
                // ==========================================
                if (!isWaliMurid && absentStudents.isNotEmpty)
                  _buildAbsentAlertBox(context, provider, absentStudents),

                const SizedBox(height: 16),

                // ==========================================
                // 4. STRUCTURED SCHOOL MODULES (3 KATEGORI)
                // ==========================================
                _buildSectionTitle('Layanan Akademik & Siswa'),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _buildSchoolServiceTile(
                        title: isWaliMurid ? 'Presensi Santri' : 'Presensi Harian',
                        subtitle: isWaliMurid ? 'Kehadiran Anak' : 'QR & Manual',
                        icon: Icons.fact_check_rounded,
                        color: const Color(0xFF00B14F),
                        onTap: () => onNavigateTab(1),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildSchoolServiceTile(
                        title: isWaliMurid ? 'Biodata Santri' : 'Buku Induk Siswa',
                        subtitle: isWaliMurid ? (myChild?.name ?? 'Profil Anak') : '${provider.allStudents.length} Data Santri',
                        icon: isWaliMurid ? Icons.badge_rounded : Icons.people_alt_rounded,
                        color: const Color(0xFF007AFF),
                        onTap: () {
                          if (isWaliMurid) {
                            if (myChild != null) _showChildBiodataModal(context, myChild);
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const StudentListScreen()),
                            );
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildSchoolServiceTile(
                        title: role == 'guru' ? 'Jadwal Ngajar' : (isWaliMurid ? 'Jadwal Santri' : 'Jadwal Mapel'),
                        subtitle: isWaliMurid ? (myChild?.className ?? 'Pelajaran Kelas') : 'Pelajaran Kelas',
                        icon: Icons.calendar_month_rounded,
                        color: const Color(0xFF2563EB),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ScheduleScreen()),
                          );
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                _buildSectionTitle('Keuangan & Fasilitas Santri'),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _buildSchoolServiceTile(
                        title: isWaliMurid ? 'Kontrol SPP' : 'SPP & Biaya',
                        subtitle: isWaliMurid ? (hasUnpaid ? 'Ada Tunggakan' : 'Lunas Terbayar') : 'Tagihan Sekolah',
                        icon: Icons.payments_rounded,
                        color: const Color(0xFF059669),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const PaymentScreen()),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildSchoolServiceTile(
                        title: isWaliMurid ? 'Tabungan Anak' : 'Tabungan Santri',
                        subtitle: isWaliMurid ? 'Buku Tabungan' : 'Kas EduPay',
                        icon: Icons.account_balance_wallet_rounded,
                        color: const Color(0xFFFF9500),
                        onTap: () => onNavigateTab(2),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildSchoolServiceTile(
                        title: 'Kartu QR Pelajar',
                        subtitle: 'Name Tag Digital',
                        icon: Icons.badge_rounded,
                        color: const Color(0xFFAF52DE),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const StudentNametagScreen()),
                          );
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                _buildSectionTitle('Laporan & Komunikasi Resmi'),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _buildSchoolServiceTile(
                        title: 'Warta Pesantren',
                        subtitle: 'Pengumuman Resmi',
                        icon: Icons.campaign_rounded,
                        color: const Color(0xFFFF2D55),
                        onTap: () => onNavigateTab(3),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildSchoolServiceTile(
                        title: isWaliMurid ? 'Surat Izin' : 'Laporan Excel',
                        subtitle: isWaliMurid ? 'Izin Sakit / Keperluan' : 'Export Rekap .xlsx',
                        icon: isWaliMurid ? Icons.assignment_outlined : Icons.table_view_rounded,
                        color: const Color(0xFF34C759),
                        onTap: () {
                          if (isWaliMurid) {
                            onNavigateTab(1);
                          } else {
                            _exportAttendanceDialog(context, provider);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildSchoolServiceTile(
                        title: 'Pengaturan',
                        subtitle: 'Profil & Sistem',
                        icon: Icons.settings_rounded,
                        color: const Color(0xFF636366),
                        onTap: () => onNavigateTab(4),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // ==========================================
                // 5. WARTA RESMI PESANTREN (FEED TERBARU)
                // ==========================================
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSectionTitle('Warta Resmi Pesantren'),
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
                const SizedBox(height: 10),

                if (provider.announcements.isNotEmpty)
                  _buildAnnouncementPreviewCard(context, provider.announcements.first)
                else
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      'Belum ada pengumuman terbaru.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // HERO CARD: WALI KELAS
  Widget _buildWaliKelasHeroCard(
    BuildContext context,
    SchoolProvider provider,
    int total,
    int hadir,
    int sakit,
    int izin,
    int alfa,
    int percent,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D3B2E), Color(0xFF007A3D), Color(0xFF00B14F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00B14F).withOpacity(0.3),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'KELAS BINAAN: ${provider.activeClass.toUpperCase()}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                '$percent% Hadir',
                style: const TextStyle(
                  color: Color(0xFF30D158),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          const Text(
            'Presensi Hari Ini',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$hadir',
                style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800),
              ),
              Text(
                ' / $total Siswa Terdaftar',
                style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // 4 Bento Pills: Hadir, Sakit, Izin, Alfa
          Row(
            children: [
              _buildMiniBento('Hadir', '$hadir', const Color(0xFF30D158)),
              const SizedBox(width: 8),
              _buildMiniBento('Sakit', '$sakit', const Color(0xFF5AC8FA)),
              const SizedBox(width: 8),
              _buildMiniBento('Izin', '$izin', const Color(0xFFFFD60A)),
              const SizedBox(width: 8),
              _buildMiniBento('Alfa', '$alfa', const Color(0xFFFF453A)),
            ],
          ),

          const SizedBox(height: 16),

          // 2 Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => onNavigateTab(1),
                  icon: const Icon(Icons.checklist_rounded, size: 16),
                  label: const Text('Kelola Presensi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF008A3D),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const QrScannerScreen()));
                  },
                  icon: const Icon(Icons.qr_code_scanner_rounded, size: 16, color: Colors.white),
                  label: const Text('Scan QR Siswa', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white70),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // HERO CARD: WALI MURID
  Widget _buildWaliMuridHeroCard(BuildContext context, SchoolProvider provider) {
    final myChild = provider.myChildStudent;
    final childId = myChild?.id ?? 1;
    final childName = myChild?.name ?? 'Ahmad Fauzi';
    final childClass = myChild?.className ?? 'Kelas 1A';
    final childNisn = myChild?.nisn ?? '-';
    final childBalance = myChild?.balance ?? 0.0;

    // Kehadiran hari ini
    final todayAtt = myChild != null ? provider.getStudentAttendance(myChild.id) : null;
    final isHadirToday = todayAtt?.status == 'Hadir';
    final statusText = todayAtt?.status ?? 'Belum Presensi';
    final scanTime = todayAtt?.scanTime;

    // Status SPP / Tunggakan
    final childBills = provider.bills.where((b) => b.studentId == childId).toList();
    final unpaidBills = childBills.where((b) => b.status != 'Lunas').toList();
    final hasUnpaid = unpaidBills.isNotEmpty;
    final double unpaidTotal = unpaidBills.fold(0.0, (sum, b) => sum + b.amount);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E0854), Color(0xFF6B21A8), Color(0xFF9333EA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6B21A8).withOpacity(0.3),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'STATUS SANTRI SAYA',
                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: (isHadirToday ? const Color(0xFF34C759) : const Color(0xFFFF9500)).withOpacity(0.25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(
                      isHadirToday ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                      color: isHadirToday ? const Color(0xFF30D158) : const Color(0xFFFFD60A),
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isHadirToday ? (scanTime != null && scanTime != '-' ? 'HADIR ($scanTime)' : 'HADIR HARI INI') : statusText.toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text('Nama Santri:', style: TextStyle(color: Colors.white70, fontSize: 11)),
          Text(childName, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          Text('$childClass • NISN: $childNisn', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),

          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => onNavigateTab(2),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.account_balance_wallet_rounded, size: 12, color: Color(0xFFFFD60A)),
                            SizedBox(width: 4),
                            Text('Tabungan Anak', style: TextStyle(color: Colors.white70, fontSize: 10)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Rp ${childBalance.toStringAsFixed(0).replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]}.")}',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentScreen()));
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.payments_rounded, size: 12, color: hasUnpaid ? const Color(0xFFFF453A) : const Color(0xFF30D158)),
                            const SizedBox(width: 4),
                            const Text('Kontrol SPP', style: TextStyle(color: Colors.white70, fontSize: 10)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          hasUnpaid
                              ? 'Tunggakan Rp ${unpaidTotal.toStringAsFixed(0).replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]}.")}'
                              : 'Lunas Terbayar',
                          style: TextStyle(
                            color: hasUnpaid ? const Color(0xFFFF453A) : const Color(0xFF30D158),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // HERO CARD: KEPALA SEKOLAH / ADMIN
  Widget _buildAdminKepsekHeroCard(
    BuildContext context,
    SchoolProvider provider,
    int total,
    int hadir,
    int sakit,
    int izin,
    int alfa,
    int percent,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'PANTAU SUPERVISI SEKOLAH',
                  style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                '${provider.allStudents.length} Santri Aktif',
                style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text('Tingkat Kehadiran Sekolah Hari Ini:', style: TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('$percent%', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              Text('($hadir hadir, $sakit sakit, $izin izin, $alfa alfa)', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => onNavigateTab(1),
                  icon: const Icon(Icons.analytics_rounded, size: 16),
                  label: const Text('Rekap Presensi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00B14F),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => onNavigateTab(3),
                  icon: const Icon(Icons.campaign_rounded, size: 16, color: Colors.white),
                  label: const Text('Buat Pengumuman', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white60),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ALERT BOX: SISWA TIDAK MASUK HARI INI
  Widget _buildAbsentAlertBox(BuildContext context, SchoolProvider provider, List absentList) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFF9500).withOpacity(0.3)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2)),
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
                  Icon(Icons.info_outline_rounded, color: Color(0xFFFF9500), size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Siswa Tidak Masuk Hari Ini',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1C1C1E)),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF9500).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${absentList.length} Murid',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFC76F00)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Column(
            children: absentList.take(3).map((s) {
              final att = provider.getStudentAttendance(s.id);
              final status = att?.status ?? 'Alfa';
              final notes = att?.notes ?? '';

              Color stColor = const Color(0xFFFF3B30);
              if (status == 'Sakit') stColor = const Color(0xFF007AFF);
              if (status == 'Izin') stColor = const Color(0xFFFF9500);

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(color: stColor, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${s.name} (${s.className})',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1C1C1E)),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: stColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        notes.isNotEmpty ? '$status: $notes' : status,
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: stColor),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniBento(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(value, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1C1C1E),
        letterSpacing: -0.2,
      ),
    );
  }

  Widget _buildSchoolServiceTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1C1C1E),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnnouncementPreviewCard(BuildContext context, announcement) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF2D55).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  announcement.category,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFFF2D55)),
                ),
              ),
              Text(
                announcement.date,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            announcement.title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1C1C1E)),
          ),
          const SizedBox(height: 4),
          Text(
            announcement.content,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600, height: 1.4),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  void _exportAttendanceDialog(BuildContext context, SchoolProvider provider) {
    final csv = provider.exportAttendanceToCsv();
    Clipboard.setData(ClipboardData(text: csv));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Rekap presensi berhasil disalin format Excel (.xlsx / .csv)!'),
        backgroundColor: Color(0xFF00B14F),
      ),
    );
  }

  void _confirmLogout(BuildContext context, SchoolProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Konfirmasi Keluar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: const Text('Apakah Anda yakin ingin keluar dari akun aplikasi sekolah?'),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Batal'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    provider.logout();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF3B30),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Keluar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showChildBiodataModal(BuildContext context, Student child) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: const Color(0xFF00B14F).withOpacity(0.12),
                  child: Text(
                    child.name.isNotEmpty ? child.name[0] : 'S',
                    style: const TextStyle(color: Color(0xFF008A3D), fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(child.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1C1C1E))),
                      Text('${child.className} • NISN: ${child.nisn}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF34C759).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    child.status.toUpperCase(),
                    style: const TextStyle(color: Color(0xFF28A745), fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const Divider(height: 28),
            _buildBioItem('Tahun Masuk', child.entryYear),
            _buildBioItem('Tempat, Tanggal Lahir', child.birthPlaceDate),
            _buildBioItem('Alamat Domisili', child.address),
            _buildBioItem('Nama Orang Tua/Wali', child.parentName),
            _buildBioItem('No. HP / WA', child.parentPhone),
            _buildBioItem('Token QR Digital', child.qrCodeToken),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => StudentNametagScreen(student: child)));
                },
                icon: const Icon(Icons.qr_code_2_rounded, size: 18),
                label: const Text('Buka Kartu Name Tag QR'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00B14F),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBioItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          ),
          const Text(': ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(value.isNotEmpty ? value : '-', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1C1C1E))),
          ),
        ],
      ),
    );
  }

  static String _getRoleBadgeText(String role, String? assignedClass) {
    switch (role) {
      case 'admin':
        return 'SUPER ADMIN';
      case 'kepsek':
        return 'KEPALA SEKOLAH';
      case 'staff':
        return 'STAFF TATA USAHA';
      case 'wali_kelas':
        return assignedClass != null ? 'WALI KELAS ($assignedClass)' : 'WALI KELAS';
      case 'guru':
        return 'DEWAN GURU';
      case 'wali_murid':
        return 'AKUN SANTRI / WALI MURID';
      default:
        return 'PENGGUNA';
    }
  }
}
