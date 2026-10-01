import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/school_provider.dart';
import '../auth/login_screen.dart';
import '../profile/user_profile_screen.dart';
import 'about_screen.dart';
import 'change_password_screen.dart';
import 'privilege_info_screen.dart';

class SettingsScreen extends StatelessWidget {
  final VoidCallback? onNavigateHome;
  const SettingsScreen({super.key, this.onNavigateHome});

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
        leading: (Navigator.canPop(context) || onNavigateHome != null)
            ? IconButton(
                icon: const Icon(CupertinoIcons.chevron_back, color: Color(0xFF007AFF), size: 28),
                tooltip: 'Kembali',
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  } else if (onNavigateHome != null) {
                    onNavigateHome!();
                  }
                },
              )
            : null,
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

                  // View / Edit Profile Button
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Color(0xFFC7C7CC)),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const UserProfileScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ==========================================
            // AKUN & KEAMANAN (PROFIL & UBAH PASSWORD)
            // ==========================================
            _buildSectionHeader('AKUN & KEAMANAN'),
            _buildIosCard([
              _buildIosTile(
                icon: Icons.person_outline_rounded,
                iconColor: const Color(0xFF00B14F),
                title: 'Profil Lengkap Akun',
                subtitle: 'Data diri, NIK, dan daftar anak terhubung',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const UserProfileScreen()),
                  );
                },
              ),
              _buildIosDivider(),
              _buildIosTile(
                icon: Icons.lock_outline_rounded,
                iconColor: const Color(0xFF007AFF),
                title: 'Ubah Kata Sandi',
                subtitle: 'Ganti password akun (default: manbaul111)',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
                  );
                },
              ),
            ]),

            const SizedBox(height: 24),

            // ==========================================
            // 2. GROUP: PENGATURAN SISTEM & HAK AKSES (Single Clean Entry)
            // ==========================================
            _buildSectionHeader('PENGATURAN SISTEM'),
            _buildIosCard([
              // Single Unified Hak Akses & Privilege
              _buildIosTile(
                icon: Icons.shield_rounded,
                iconColor: const Color(0xFF6366F1),
                title: provider.currentRole == 'admin' ? 'Hak Akses & Privilege' : 'Wewenang Peran',
                subtitle: provider.currentRole == 'admin'
                    ? 'Kelola Matriks Hak Akses Seluruh Peran (Super Admin)'
                    : 'Informasi Wewenang Peran (${_formatRoleName(provider.currentRole)})',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PrivilegeInfoScreen(
                        initialTabIndex: provider.currentRole == 'admin' ? 1 : 0,
                      ),
                    ),
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
            // 3. GROUP: INFORMASI APLIKASI (About Modal)
            // ==========================================
            _buildSectionHeader('INFORMASI APLIKASI'),
            _buildIosCard([
              _buildIosTile(
                icon: Icons.info_outline_rounded,
                iconColor: const Color(0xFF007AFF),
                title: 'Tentang Aplikasi (About)',
                subtitle: 'Informasi versi, developer, & lisensi aplikasi',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AboutScreen()),
                  );
                },
              ),
            ]),

            const SizedBox(height: 24),

            // ==========================================
            // 4. KELUAR DARI AKUN (LOGOUT)
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
  // DIALOG: EDIT PROFILE
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
                    provider.updateProfile(
                      name: nameCtrl.text.trim(),
                      phone: phoneCtrl.text.trim(),
                    );
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

  // ==========================================
  // DIALOG: LOGOUT MODAL
  // ==========================================
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
