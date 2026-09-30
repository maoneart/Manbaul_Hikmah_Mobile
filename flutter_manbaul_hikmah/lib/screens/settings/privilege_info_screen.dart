import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/school_provider.dart';

class PrivilegeInfoScreen extends StatefulWidget {
  final int initialTabIndex;
  const PrivilegeInfoScreen({super.key, this.initialTabIndex = 0});

  @override
  State<PrivilegeInfoScreen> createState() => _PrivilegeInfoScreenState();
}

class _PrivilegeInfoScreenState extends State<PrivilegeInfoScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedRole = 'wali_kelas';

  final List<Map<String, String>> _rolesList = [
    {
      'key': 'admin',
      'label': 'Super Admin',
      'desc': 'Akses penuh tanpa batas ke seluruh modul & konfigurasi sistem.',
      'level': 'Level 5 (Tertinggi)',
    },
    {
      'key': 'kepsek',
      'label': 'Kepala Sekolah',
      'desc': 'Pengelola manajerial, kebijakan madrasah, persetujuan & monitoring data.',
      'level': 'Level 4',
    },
    {
      'key': 'wali_kelas',
      'label': 'Wali Kelas',
      'desc': 'Pengelola absensi harian kelas bimbingan, tabungan, dan input murid.',
      'level': 'Level 3',
    },
    {
      'key': 'guru',
      'label': 'Dewan Guru',
      'desc': 'Presensi pengajaran, monitoring siswa, dan pencetakan name tag.',
      'level': 'Level 2',
    },
    {
      'key': 'wali_murid',
      'label': 'Wali Murid / Siswa',
      'desc': 'Akses monitoring presensi anak, saldo tabungan, dan pengumuman sekolah.',
      'level': 'Level 1',
    },
  ];

  final List<Map<String, dynamic>> _modules = [
    {
      'module': 'MODUL KESISWAAN & SISWA',
      'items': [
        {
          'key': 'add_student',
          'name': 'Pendaftaran Siswa Baru',
          'desc': 'Menambahkan data siswa baru ke database sekolah & server hosting.',
          'icon': Icons.person_add_alt_1_rounded,
          'color': Color(0xFF007AFF),
        },
        {
          'key': 'edit_student',
          'name': 'Edit Profil & Data Siswa',
          'desc': 'Memperbarui nama, kelas, NISN, wali murid, dan kontak telepon.',
          'icon': Icons.edit_note_rounded,
          'color': Color(0xFFFF9500),
        },
        {
          'key': 'delete_student',
          'name': 'Penghapusan Data Siswa',
          'desc': 'Menghapus data siswa dan catatan riwayat terkait secara permanen.',
          'icon': Icons.delete_forever_rounded,
          'color': Color(0xFFFF2D55),
        },
        {
          'key': 'print_nametag',
          'name': 'Cetak Kartu QR Name Tag',
          'desc': 'Membuat & mencetak kartu pengenal ber-QR Code untuk siswa.',
          'icon': Icons.badge_rounded,
          'color': Color(0xFFAF52DE),
        },
      ],
    },
    {
      'module': 'MODUL PRESENSI & QR CODE',
      'items': [
        {
          'key': 'scan_qr',
          'name': 'Scan Kamera QR Code',
          'desc': 'Memindai kartu siswa untuk presensi otomatis masuk / pulang.',
          'icon': Icons.qr_code_scanner_rounded,
          'color': Color(0xFF00B14F),
        },
        {
          'key': 'manual_attendance',
          'name': 'Input & Ubah Status Kehadiran',
          'desc': 'Mengatur status Hadir, Sakit, Izin, atau Alfa secara manual.',
          'icon': Icons.fact_check_rounded,
          'color': Color(0xFF34C759),
        },
        {
          'key': 'rekap_attendance',
          'name': 'Rekapitulasi Presensi Kelas',
          'desc': 'Melihat rekap statistik dan laporan kehadiran harian / bulanan.',
          'icon': Icons.analytics_rounded,
          'color': Color(0xFF5856D6),
        },
      ],
    },
    {
      'module': 'MODUL TABUNGAN SISWA (EDUPAY)',
      'items': [
        {
          'key': 'deposit_savings',
          'name': 'Transaksi Setoran Tabungan',
          'desc': 'Menerima dan mencatat setoran uang saku / tabungan siswa.',
          'icon': Icons.savings_rounded,
          'color': Color(0xFF00B14F),
        },
        {
          'key': 'withdraw_savings',
          'name': 'Transaksi Penarikan Saldo',
          'desc': 'Melayani penarikan dana tabungan siswa sesuai izin wali.',
          'icon': Icons.payments_rounded,
          'color': Color(0xFFFF9500),
        },
        {
          'key': 'view_all_savings',
          'name': 'Monitoring Kas Tabungan',
          'desc': 'Melihat total akumulasi saldo seluruh siswa dan buku mutasi.',
          'icon': Icons.account_balance_rounded,
          'color': Color(0xFF007AFF),
        },
      ],
    },
    {
      'module': 'MODUL WARTA & INFORMASI',
      'items': [
        {
          'key': 'create_announcement',
          'name': 'Publikasi Warta Sekolah',
          'desc': 'Menerbitkan pengumuman resmi akademik, libur, dan kegiatan siswa.',
          'icon': Icons.campaign_rounded,
          'color': Color(0xFFFF2D55),
        },
        {
          'key': 'broadcast_parent',
          'name': 'Broadcast WhatsApp Wali',
          'desc': 'Kirim notifikasi rekap presensi langsung ke WhatsApp wali murid.',
          'icon': Icons.chat_rounded,
          'color': Color(0xFF34C759),
        },
      ],
    },
    {
      'module': 'MODUL DATA & LAPORAN EXCEL',
      'items': [
        {
          'key': 'download_template',
          'name': 'Unduh Template Excel Import',
          'desc': 'Menyimpan berkas template Excel (.xlsx / .csv) ke folder Download.',
          'icon': Icons.file_download_rounded,
          'color': Color(0xFF007AFF),
        },
        {
          'key': 'export_data',
          'name': 'Export Seluruh Data (Excel / CSV)',
          'desc': 'Mengekspor seluruh tabel data siswa dan presensi ke berkas spreadsheet.',
          'icon': Icons.ios_share_rounded,
          'color': Color(0xFF34C759),
        },
        {
          'key': 'import_data',
          'name': 'Import Massal Data Siswa',
          'desc': 'Memasukkan ratusan data siswa sekaligus dari berkas Excel/CSV.',
          'icon': Icons.upload_file_rounded,
          'color': Color(0xFF00C7BE),
        },
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      initialIndex: widget.initialTabIndex.clamp(0, 1),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SchoolProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        title: const Text(
          'Hak Akses & Privilege',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1C1C1E),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1C1C1E), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.restart_alt_rounded, color: Color(0xFF007AFF)),
            tooltip: 'Reset Hak Akses ke Default',
            onPressed: () => _showResetModal(context, provider),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF00B14F),
          unselectedLabelColor: const Color(0xFF8E8E93),
          indicatorColor: const Color(0xFF00B14F),
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          tabs: const [
            Tab(icon: Icon(Icons.shield_rounded, size: 20), text: 'Wewenang Peran Saya'),
            Tab(icon: Icon(Icons.tune_rounded, size: 20), text: 'Matriks Hak Akses'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMyPermissionsTab(provider),
          _buildMatrixSettingTab(provider),
        ],
      ),
    );
  }

  /// ==========================================
  /// TAB 1: WEWENANG PERAN SAYA
  /// ==========================================
  Widget _buildMyPermissionsTab(SchoolProvider provider) {
    final user = provider.currentUser;
    final role = provider.currentRole;
    final roleColor = _getRoleColor(role);

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      children: [
        // Role Profile Header Card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF1E293B),
                roleColor.withOpacity(0.85),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
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
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.stars_rounded, size: 14, color: Colors.white),
                        const SizedBox(width: 5),
                        Text(
                          _getRoleLabel(role).toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF34C759).withOpacity(0.9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Hak Akses Aktif',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                user?['name'] ?? 'Pengguna Sekolah',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Username: @${user?['username'] ?? '-'} • ${user?['assigned_class'] ?? 'Seluruh Madrasah'}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Module Groups
        for (final group in _modules) ...[
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              group['module'],
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF64748B),
                letterSpacing: 0.5,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 20),
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
              children: [
                for (int i = 0; i < (group['items'] as List).length; i++) ...[
                  () {
                    final item = group['items'][i];
                    final bool isGranted = provider.hasPermission(item['key']);
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: (item['color'] as Color).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(item['icon'], size: 22, color: item['color']),
                      ),
                      title: Text(
                        item['name'],
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1C1C1E),
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          item['desc'],
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                        ),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: isGranted
                              ? const Color(0xFF34C759).withOpacity(0.12)
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isGranted ? 'Diizinkan' : 'Terkunci',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isGranted ? const Color(0xFF28A745) : Colors.grey.shade600,
                          ),
                        ),
                      ),
                    );
                  }(),
                  if (i < (group['items'] as List).length - 1)
                    Divider(height: 1, indent: 56, color: Colors.grey.shade100),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }

  /// ==========================================
  /// TAB 2: MATRIKS HAK AKSES (SUPER ADMIN)
  /// ==========================================
  Widget _buildMatrixSettingTab(SchoolProvider provider) {
    final selectedRoleInfo = _rolesList.firstWhere(
      (r) => r['key'] == _selectedRole,
      orElse: () => _rolesList.first,
    );
    final isSuperAdminRole = _selectedRole == 'admin';

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      children: [
        // Role Selector Pills
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'PILIH ROLE UNTUK DIKONFIGURASI',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF64748B),
              letterSpacing: 0.5,
            ),
          ),
        ),
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _rolesList.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, idx) {
              final r = _rolesList[idx];
              final isSelected = r['key'] == _selectedRole;
              return InkWell(
                onTap: () => setState(() => _selectedRole = r['key']!),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF00B14F) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF00B14F) : Colors.grey.shade300,
                    ),
                    boxShadow: [
                      if (isSelected)
                        BoxShadow(
                          color: const Color(0xFF00B14F).withOpacity(0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    r['label']!,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : const Color(0xFF1C1C1E),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 16),

        // Role Info Banner
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _getRoleColor(_selectedRole).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.tune_rounded,
                  color: _getRoleColor(_selectedRole),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${selectedRoleInfo['label']} (${selectedRoleInfo['level']})',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      selectedRoleInfo['desc']!,
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        if (isSuperAdminRole) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: const Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Color(0xFFD97706), size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Wewenang Super Admin aktif permanen dan tidak dapat dinonaktifkan demi stabilitas sistem madrasah.',
                    style: TextStyle(fontSize: 11, color: Color(0xFF92400E), fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 20),

        // Module Switch Tiles
        for (final group in _modules) ...[
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              group['module'],
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF64748B),
                letterSpacing: 0.5,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 20),
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
              children: [
                for (int i = 0; i < (group['items'] as List).length; i++) ...[
                  () {
                    final item = group['items'][i];
                    final bool isGranted = provider.checkRolePermission(_selectedRole, item['key']);
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: (item['color'] as Color).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(item['icon'], size: 22, color: item['color']),
                      ),
                      title: Text(
                        item['name'],
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          item['desc'],
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                        ),
                      ),
                      trailing: CupertinoSwitch(
                        value: isSuperAdminRole ? true : isGranted,
                        activeColor: const Color(0xFF00B14F),
                        onChanged: isSuperAdminRole
                            ? null
                            : (val) {
                                provider.updateRolePermission(_selectedRole, item['key'], val);
                                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Akses "${item['name']}" untuk ${selectedRoleInfo['label']} diperbarui: ${val ? "Diizinkan" : "Dinonaktifkan"}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    duration: const Duration(seconds: 1),
                                    backgroundColor: val ? const Color(0xFF00B14F) : const Color(0xFF1E293B),
                                  ),
                                );
                              },
                      ),
                    );
                  }(),
                  if (i < (group['items'] as List).length - 1)
                    Divider(height: 1, indent: 56, color: Colors.grey.shade100),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }

  /// MaoneArt Glassmorphism Confirmation Modal for Resetting Permissions
  void _showResetModal(BuildContext context, SchoolProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFF007AFF).withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.restart_alt_rounded, color: Color(0xFF007AFF), size: 28),
            ),
            const SizedBox(height: 16),
            const Text(
              'Reset Matriks Hak Akses?',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1C1C1E)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Seluruh pengaturan wewenang role Kepala Sekolah, Wali Kelas, Guru, dan Wali Murid akan dikembalikan ke setelan standar madrasah.',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600, height: 1.4),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            // MaoneArt 100% Symmetrical 2-Column Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    child: Text('Batal', style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      provider.resetPermissionsToDefault();
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Matriks hak akses berhasil dikembalikan ke standar awal.'),
                          backgroundColor: Color(0xFF00B14F),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF007AFF),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text('Ya, Reset', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'admin':
        return const Color(0xFFDC2626);
      case 'kepsek':
        return const Color(0xFFD97706);
      case 'wali_kelas':
        return const Color(0xFF00B14F);
      case 'guru':
        return const Color(0xFF2563EB);
      case 'wali_murid':
        return const Color(0xFF7C3AED);
      default:
        return const Color(0xFF4B5563);
    }
  }

  String _getRoleLabel(String role) {
    switch (role) {
      case 'admin':
        return 'Super Admin';
      case 'kepsek':
        return 'Kepala Sekolah';
      case 'wali_kelas':
        return 'Wali Kelas';
      case 'guru':
        return 'Dewan Guru';
      case 'wali_murid':
        return 'Wali Murid';
      default:
        return role;
    }
  }
}
