import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/school_provider.dart';
import '../../theme/app_theme.dart';
import '../students/student_list_screen.dart';
import '../students/student_nametag_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SchoolProvider>(context);
    final user = provider.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7), // iOS Grouped Background
      appBar: AppBar(
        backgroundColor: const Color(0xFFF2F2F7),
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Pengaturan',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            color: Color(0xFF1C1C1E),
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==========================================
            // 1. APPLE ID STYLE PROFILE CARD
            // ==========================================
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Avatar with Initials
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: provider.currentRole == 'admin'
                            ? [const Color(0xFFDC2626), const Color(0xFF991B1B)]
                            : provider.currentRole == 'kepsek'
                                ? [const Color(0xFFD97706), const Color(0xFFB45309)]
                                : provider.currentRole == 'wali_kelas'
                                    ? [const Color(0xFF00B14F), const Color(0xFF008A3D)]
                                    : [const Color(0xFF2563EB), const Color(0xFF1D4ED8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        (user?['name'] != null && user!['name'].toString().isNotEmpty)
                            ? user['name'].toString().substring(0, 1).toUpperCase()
                            : 'M',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Name & Role Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?['name'] ?? 'Pengguna Sekolah',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1C1C1E),
                            letterSpacing: -0.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00B14F).withOpacity(0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                _formatRoleName(provider.currentRole),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF008A3D),
                                ),
                              ),
                            ),
                            if (user?['assigned_class'] != null) ...[
                              const SizedBox(width: 6),
                              Text(
                                user!['assigned_class'],
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'HP: ${user?['phone'] ?? '-'}',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  ),

                  // Edit Button
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 20, color: Color(0xFF00B14F)),
                    onPressed: () => _showEditProfileDialog(context, provider),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ==========================================
            // 2. GROUP: PERAN & KELAS (ROLE SWITCHER)
            // ==========================================
            _buildSectionHeader('AKUN & PERAN AKTIF'),
            _buildIosCard([
              _buildIosTile(
                icon: Icons.switch_account_rounded,
                iconColor: const Color(0xFF5856D6),
                title: 'Ganti Peran Pengguna',
                subtitle: _formatRoleName(provider.currentRole),
                onTap: () => _showRoleSwitchDialog(context, provider),
              ),
              _buildIosDivider(),
              _buildIosTile(
                icon: Icons.class_rounded,
                iconColor: const Color(0xFFFF9500),
                title: 'Pilih Kelas Aktif',
                subtitle: provider.activeClass,
                onTap: () => _showClassSwitchDialog(context, provider),
              ),
            ]),

            const SizedBox(height: 24),

            // ==========================================
            // 3. GROUP: MANAJEMEN SISWA & REKAP EXCEL
            // ==========================================
            _buildSectionHeader('DATA SISWA & REKAP EXCEL'),
            _buildIosCard([
              _buildIosTile(
                icon: Icons.people_alt_rounded,
                iconColor: const Color(0xFF007AFF),
                title: 'Data Siswa & Santri',
                subtitle: '${provider.allStudents.length} Santri Terdaftar',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const StudentListScreen()),
                  );
                },
              ),
              _buildIosDivider(),
              _buildIosTile(
                icon: Icons.badge_rounded,
                iconColor: const Color(0xFFAF52DE),
                title: 'Cetak Kartu QR Name Tag',
                subtitle: 'Generator Kartu Digital Siap Cetak',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const StudentNameTagScreen()),
                  );
                },
              ),
              _buildIosDivider(),
              _buildIosTile(
                icon: Icons.table_chart_rounded,
                iconColor: const Color(0xFF34C759),
                title: 'Export Rekap Presensi (Excel/CSV)',
                subtitle: 'Unduh laporan presensi siswa',
                onTap: () => _exportAttendanceDialog(context, provider),
              ),
              _buildIosDivider(),
              _buildIosTile(
                icon: Icons.file_upload_rounded,
                iconColor: const Color(0xFF00C7BE),
                title: 'Import Data Siswa (Excel/CSV)',
                subtitle: 'Import massal dari template Excel',
                onTap: () => _importStudentsDialog(context, provider),
              ),
              _buildIosDivider(),
              _buildIosTile(
                icon: Icons.file_download_rounded,
                iconColor: const Color(0xFFFF2D55),
                title: 'Export Data Siswa (Excel/CSV)',
                subtitle: 'Salin seluruh data siswa format tabel',
                onTap: () => _exportStudentsDialog(context, provider),
              ),
            ]),

            const SizedBox(height: 24),

            // ==========================================
            // 4. GROUP: HAK AKSES & PRIVILEGE (SUPER ADMIN)
            // ==========================================
            _buildSectionHeader('HAK AKSES & PRIVILEGE (ADMIN PANEL)'),
            _buildIosCard([
              _buildIosSwitchTile(
                icon: Icons.person_add_rounded,
                iconColor: const Color(0xFF00B14F),
                title: 'Wali Kelas Tambah Murid',
                subtitle: 'Izin walas mendaftarkan santri baru',
                value: provider.privileges['walas_add_student'] ?? true,
                onChanged: (val) => provider.setPrivilege('walas_add_student', val),
              ),
              _buildIosDivider(),
              _buildIosSwitchTile(
                icon: Icons.verified_user_rounded,
                iconColor: const Color(0xFFD97706),
                title: 'Kepsek Tambah Murid',
                subtitle: 'Izin kepala sekolah kelola murid',
                value: provider.privileges['kepsek_add_student'] ?? true,
                onChanged: (val) => provider.setPrivilege('kepsek_add_student', val),
              ),
              _buildIosDivider(),
              _buildIosSwitchTile(
                icon: Icons.fact_check_rounded,
                iconColor: const Color(0xFF5856D6),
                title: 'Guru Input Presensi',
                subtitle: 'Izin guru umum mengisi kehadiran',
                value: provider.privileges['guru_input_attendance'] ?? true,
                onChanged: (val) => provider.setPrivilege('guru_input_attendance', val),
              ),
              _buildIosDivider(),
              _buildIosSwitchTile(
                icon: Icons.account_balance_wallet_rounded,
                iconColor: const Color(0xFFFF9500),
                title: 'Wali Kelas Kelola Tabungan',
                subtitle: 'Izin setor/tarik tabungan santri',
                value: provider.privileges['walas_manage_savings'] ?? true,
                onChanged: (val) => provider.setPrivilege('walas_manage_savings', val),
              ),
              _buildIosDivider(),
              _buildIosSwitchTile(
                icon: Icons.cloud_sync_rounded,
                iconColor: const Color(0xFF007AFF),
                title: 'Izin Import & Export Excel',
                subtitle: 'Buka akses ekspor/impor tabel CSV',
                value: provider.privileges['allow_export_import'] ?? true,
                onChanged: (val) => provider.setPrivilege('allow_export_import', val),
              ),
            ]),

            const SizedBox(height: 24),

            // ==========================================
            // 5. GROUP: PREFERENSI & TAMPILAN
            // ==========================================
            _buildSectionHeader('TAMPILAN & PREFERENSI'),
            _buildIosCard([
              _buildIosSwitchTile(
                icon: Icons.visibility_off_rounded,
                iconColor: const Color(0xFF8E8E93),
                title: 'Sensor Saldo EduPay',
                subtitle: 'Sembunyikan nominal saldo di beranda',
                value: !provider.isBalanceVisible,
                onChanged: (_) => provider.toggleBalanceVisibility(),
              ),
            ]),

            const SizedBox(height: 24),

            // ==========================================
            // 6. GROUP: TENTANG APLIKASI
            // ==========================================
            _buildSectionHeader('TENTANG APLIKASI & SERVER'),
            _buildIosCard([
              _buildIosInfoTile(
                icon: Icons.verified_rounded,
                iconColor: const Color(0xFF00B14F),
                title: 'Versi Aplikasi',
                value: 'v1.0.0 (Release APK)',
              ),
              _buildIosDivider(),
              _buildIosInfoTile(
                icon: Icons.dns_rounded,
                iconColor: const Color(0xFF007AFF),
                title: 'Server REST API',
                value: 'maoneart.my.id/manbaul/api',
              ),
              _buildIosDivider(),
              _buildIosInfoTile(
                icon: Icons.wifi_tethering_rounded,
                iconColor: const Color(0xFF34C759),
                title: 'Status Koneksi',
                value: 'Terhubung (Online)',
              ),
              _buildIosDivider(),
              _buildIosInfoTile(
                icon: Icons.code_rounded,
                iconColor: const Color(0xFFFF2D55),
                title: 'Pengembang',
                value: 'MaoneArt (Hermawan)',
              ),
            ]),

            const SizedBox(height: 24),

            // ==========================================
            // 7. KELUAR DARI AKUN (LOGOUT)
            // ==========================================
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _confirmLogout(context, provider),
                  borderRadius: BorderRadius.circular(14),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Center(
                      child: Text(
                        'Keluar dari Akun',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF3B30), // iOS Destructive Red
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 36),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // HELPER WIDGETS (iOS AESTHETIC)
  // ==========================================

  static Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  static Widget _buildIosCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  static Widget _buildIosDivider() {
    return Divider(height: 1, color: Colors.grey.shade200, indent: 56);
  }

  static Widget _buildIosTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: iconColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1C1C1E)),
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 1),
                      Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                    ],
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, size: 20, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildIosSwitchTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1C1C1E)),
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 1),
                  Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                ],
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            activeColor: const Color(0xFF00B14F),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  static Widget _buildIosInfoTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1C1C1E)),
            ),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  static String _formatRoleName(String role) {
    switch (role) {
      case 'admin':
        return 'Super Admin';
      case 'kepsek':
        return 'Kepala Sekolah';
      case 'wali_kelas':
        return 'Wali Kelas';
      case 'guru':
        return 'Guru Pengajar';
      case 'wali_murid':
        return 'Wali Murid';
      default:
        return role;
    }
  }

  // ==========================================
  // DIALOGS & ACTIONS
  // ==========================================

  static void _showEditProfileDialog(BuildContext context, SchoolProvider provider) {
    final nameCtrl = TextEditingController(text: provider.currentUser?['name'] ?? '');
    final phoneCtrl = TextEditingController(text: provider.currentUser?['phone'] ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Edit Profil Akun', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Nama Lengkap'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneCtrl,
              decoration: const InputDecoration(labelText: 'Nomor WhatsApp / HP'),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00B14F)),
            onPressed: () {
              provider.updateProfile(nameCtrl.text.trim(), phoneCtrl.text.trim());
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profil berhasil diperbarui')),
              );
            },
            child: const Text('Simpan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  static void _showRoleSwitchDialog(BuildContext context, SchoolProvider provider) {
    final roles = [
      {'role': 'kepsek', 'label': 'Kepala Sekolah (KH. Ahmad Syafei)'},
      {'role': 'wali_kelas', 'label': 'Wali Kelas (Ustadz Budi Santoso)'},
      {'role': 'guru', 'label': 'Guru Pengajar'},
      {'role': 'wali_murid', 'label': 'Wali Murid / Santri'},
      {'role': 'admin', 'label': 'Super Admin (Hermawan)'},
    ];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Pilih Peran Pengguna', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: roles.map((r) {
            final isCurrent = provider.currentRole == r['role'];
            return ListTile(
              title: Text(r['label']!, style: TextStyle(fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal)),
              trailing: isCurrent ? const Icon(Icons.check_circle, color: Color(0xFF00B14F)) : null,
              onTap: () {
                provider.switchRole(r['role']!);
                Navigator.pop(ctx);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  static void _showClassSwitchDialog(BuildContext context, SchoolProvider provider) {
    final classes = ['Semua', 'Kelas 7A', 'Kelas 7B', 'Kelas 8A', 'Kelas 9A'];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Pilih Kelas Aktif', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: classes.map((c) {
            final isCurrent = provider.activeClass == c;
            return ListTile(
              title: Text(c, style: TextStyle(fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal)),
              trailing: isCurrent ? const Icon(Icons.check_circle, color: Color(0xFF00B14F)) : null,
              onTap: () {
                provider.switchClass(c);
                Navigator.pop(ctx);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  static void _exportAttendanceDialog(BuildContext context, SchoolProvider provider) {
    final csv = provider.exportAttendanceToCsv();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.table_chart_rounded, color: Color(0xFF34C759)),
            SizedBox(width: 8),
            Text('Rekap Presensi (Excel/CSV)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Data rekap presensi seluruh siswa telah siap dalam format CSV kompatibel Excel / Google Sheets:',
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              height: 120,
              width: double.infinity,
              child: SingleChildScrollView(
                child: Text(csv, style: const TextStyle(fontSize: 11, fontFamily: 'monospace')),
              ),
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
                const SnackBar(content: Text('Data rekap CSV berhasil disalin ke clipboard! Siap dipaste ke Excel.')),
              );
            },
          ),
        ],
      ),
    );
  }

  static void _exportStudentsDialog(BuildContext context, SchoolProvider provider) {
    final csv = provider.exportStudentsToCsv();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Export Data Siswa (CSV)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total ${provider.allStudents.length} siswa siap diekspor ke Excel:', style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              height: 120,
              width: double.infinity,
              child: SingleChildScrollView(
                child: Text(csv, style: const TextStyle(fontSize: 11, fontFamily: 'monospace')),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Tutup')),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00B14F)),
            icon: const Icon(Icons.copy_rounded, size: 16, color: Colors.white),
            label: const Text('Salin Data', style: TextStyle(color: Colors.white)),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: csv));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Seluruh data siswa disalin ke clipboard!')),
              );
            },
          ),
        ],
      ),
    );
  }

  static void _importStudentsDialog(BuildContext context, SchoolProvider provider) {
    final template = provider.getStudentImportTemplateCsv();
    final inputCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.file_upload_rounded, color: Color(0xFF00B14F)),
            SizedBox(width: 8),
            Text('Import Data Siswa Excel', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '1. Gunakan format kolom di bawah ini:\n   nisn,nama,jenis_kelamin,kelas,nama_wali,no_hp_wali,saldo_awal',
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade200,
                  foregroundColor: const Color(0xFF1C1C1E),
                  elevation: 0,
                ),
                icon: const Icon(Icons.download_rounded, size: 16),
                label: const Text('Salin Template Excel/CSV', style: TextStyle(fontSize: 12)),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: template));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Template CSV disalin ke clipboard!')),
                  );
                },
              ),
              const SizedBox(height: 12),
              const Text('2. Tempelkan data CSV yang akan diimpor:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              TextField(
                controller: inputCtrl,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Tempelkan baris data CSV di sini...\nContoh:\n$template',
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
                SnackBar(
                  content: Text(res['message'] ?? 'Import selesai'),
                  backgroundColor: res['success'] == true ? const Color(0xFF00B14F) : Colors.red,
                ),
              );
            },
            child: const Text('Proses Import', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  static void _confirmLogout(BuildContext context, SchoolProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Konfirmasi Keluar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: const Text('Apakah Anda yakin ingin keluar dari akun ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF3B30)),
            onPressed: () {
              provider.logout();
              Navigator.pop(ctx);
            },
            child: const Text('Keluar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
