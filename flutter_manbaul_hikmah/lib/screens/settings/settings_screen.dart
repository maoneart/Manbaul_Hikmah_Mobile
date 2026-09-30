import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/school_provider.dart';
import '../auth/login_screen.dart';
import 'privilege_info_screen.dart';

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
                  // Avatar with Role Gradient
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
                    icon: const Icon(Icons.edit_rounded, size: 20, color: Color(0xFF00B14F)),
                    onPressed: () => _showEditProfileDialog(context, provider),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ==========================================
            // 2. GROUP: KEAMANAN & TAMPILAN
            // ==========================================
            _buildSectionHeader('KEAMANAN & TAMPILAN'),
            _buildIosCard([
              // Hak Akses & Privilege
              _buildIosTile(
                icon: Icons.shield_rounded,
                iconColor: const Color(0xFF6366F1),
                title: 'Hak Akses & Privilege',
                subtitle: 'Wewenang akun & modul sistem (${_formatRoleName(provider.currentRole)})',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PrivilegeInfoScreen(initialTabIndex: 0)),
                  );
                },
              ),
              _buildIosDivider(),
              // Sensor Saldo EduPay
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
            // 3. GROUP: KONFIGURASI SUPER ADMIN & ROLE
            // ==========================================
            if (provider.currentRole == 'admin' || provider.currentRole == 'kepsek') ...[
              _buildSectionHeader('KONFIGURASI SUPER ADMIN & ROLE'),
              _buildIosCard([
                _buildIosTile(
                  icon: Icons.tune_rounded,
                  iconColor: const Color(0xFF00B14F),
                  title: 'Matriks Hak Akses & Privilege Role',
                  subtitle: 'Konfigurasi wewenang dinamis untuk 5 role pengguna',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PrivilegeInfoScreen(initialTabIndex: 1)),
                    );
                  },
                ),
                _buildIosDivider(),
                _buildIosTile(
                  icon: Icons.switch_account_rounded,
                  iconColor: const Color(0xFF5856D6),
                  title: 'Ganti Peran Pengguna (Role Switcher)',
                  subtitle: 'Saat ini: ${_formatRoleName(provider.currentRole)}',
                  onTap: () => _showRoleSwitchDialog(context, provider),
                ),
                _buildIosDivider(),
                _buildIosTile(
                  icon: Icons.class_rounded,
                  iconColor: const Color(0xFFFF9500),
                  title: 'Pilih Kelas Aktif (Class Switcher)',
                  subtitle: provider.activeClass,
                  onTap: () => _showClassSwitchDialog(context, provider),
                ),
              ]),
              const SizedBox(height: 24),
            ],

            // ==========================================
            // 4. GROUP: TENTANG APLIKASI & SERVER
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
                icon: Icons.cloud_done_rounded,
                iconColor: const Color(0xFF007AFF),
                title: 'Server REST API',
                value: 'maoneart.my.id/manbaul/api',
              ),
              _buildIosDivider(),
              _buildIosInfoTile(
                icon: Icons.security_rounded,
                iconColor: const Color(0xFF34C759),
                title: 'Keamanan Backend',
                value: 'Stealth 404 & App-Key Protected',
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
            // 5. KELUAR DARI AKUN (LOGOUT)
            // ==========================================
            _buildIosCard([
              InkWell(
                onTap: () => _showLogoutDialog(context, provider),
                borderRadius: BorderRadius.circular(16),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout_rounded, color: Color(0xFFFF3B30), size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Keluar dari Akun',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF3B30),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ]),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // UI BUILDER HELPERS
  // ==========================================
  static Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF6C6C70),
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  static Widget _buildIosCard(List<Widget> children) {
    return Container(
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
      child: Column(children: children),
    );
  }

  static Widget _buildIosTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: iconColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 20, color: Colors.white),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1C1C1E),
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            )
          : null,
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Color(0xFFC7C7CC)),
      onTap: onTap,
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
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: iconColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 20, color: Colors.white),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1C1C1E),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
      ),
      trailing: CupertinoSwitch(
        value: value,
        activeColor: const Color(0xFF00B14F),
        onChanged: onChanged,
      ),
    );
  }

  static Widget _buildIosInfoTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: iconColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 20, color: Colors.white),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1C1C1E),
        ),
      ),
      trailing: Text(
        value,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: Color(0xFF8E8E93),
        ),
      ),
    );
  }

  static Widget _buildIosDivider() {
    return Divider(height: 1, indent: 56, color: Colors.grey.shade200);
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
        return 'Dewan Guru';
      case 'wali_murid':
        return 'Wali Murid';
      default:
        return role;
    }
  }

  // ==========================================
  // DIALOGS & MODALS
  // ==========================================
  static void _showEditProfileDialog(BuildContext context, SchoolProvider provider) {
    final nameCtrl = TextEditingController(text: provider.currentUser?['name'] ?? '');
    final phoneCtrl = TextEditingController(text: provider.currentUser?['phone'] ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        title: const Text('Edit Profil Pengguna', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nama Lengkap')),
            const SizedBox(height: 10),
            TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'No. HP / WhatsApp')),
          ],
        ),
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        actions: [
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
                    provider.updateProfile(nameCtrl.text.trim(), phoneCtrl.text.trim());
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Profil berhasil diperbarui'), backgroundColor: Color(0xFF00B14F)),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00B14F),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text('Simpan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static void _showRoleSwitchDialog(BuildContext context, SchoolProvider provider) {
    final roles = [
      {'role': 'admin', 'label': 'Super Admin (Akses Penuh)'},
      {'role': 'kepsek', 'label': 'Kepala Sekolah'},
      {'role': 'wali_kelas', 'label': 'Wali Kelas'},
      {'role': 'guru', 'label': 'Dewan Guru'},
      {'role': 'wali_murid', 'label': 'Wali Murid / Santri'},
    ];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        title: const Text('Ganti Peran Pengguna', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: roles
              .map(
                (r) => ListTile(
                  title: Text(r['label']!, style: const TextStyle(fontSize: 14)),
                  leading: Radio<String>(
                    value: r['role']!,
                    groupValue: provider.currentRole,
                    activeColor: const Color(0xFF00B14F),
                    onChanged: (val) {
                      if (val != null) {
                        provider.switchRole(val);
                        Navigator.pop(ctx);
                      }
                    },
                  ),
                  onTap: () {
                    provider.switchRole(r['role']!);
                    Navigator.pop(ctx);
                  },
                ),
              )
              .toList(),
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
        contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        title: const Text('Pilih Kelas Aktif', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: classes
              .map(
                (c) => ListTile(
                  title: Text(c, style: const TextStyle(fontSize: 14)),
                  leading: Radio<String>(
                    value: c,
                    groupValue: provider.activeClass,
                    activeColor: const Color(0xFF00B14F),
                    onChanged: (val) {
                      if (val != null) {
                        provider.switchClass(val);
                        Navigator.pop(ctx);
                      }
                    },
                  ),
                  onTap: () {
                    provider.switchClass(c);
                    Navigator.pop(ctx);
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  // MaoneArt Glassmorphism Confirmation Modal for Logout
  static void _showLogoutDialog(BuildContext context, SchoolProvider provider) {
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
                color: const Color(0xFFFF3B30).withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.logout_rounded, color: Color(0xFFFF3B30), size: 28),
            ),
            const SizedBox(height: 16),
            const Text(
              'Keluar dari Akun?',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1C1C1E)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Apakah Anda yakin ingin keluar dari sistem Manbaul Hikmah Mobile?',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600, height: 1.4),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            // MaoneArt Strict 100% Symmetrical 2-Column Buttons
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
                      provider.logout();
                      Navigator.pop(ctx);
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF3B30),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text('Ya, Keluar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
