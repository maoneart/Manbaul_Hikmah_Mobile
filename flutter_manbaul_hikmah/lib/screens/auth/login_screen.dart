import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/school_provider.dart';
import '../../theme/app_theme.dart';
import '../main_navigation_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String _selectedDemoUser = '';

  final List<Map<String, String>> _demoAccounts = [
    {
      'roleTitle': 'Kepala Sekolah',
      'name': 'KH. Ahmad Syafei, M.Pd.',
      'email': 'kepsek@manbaulhikmah.sch.id',
      'username': 'kepsek',
      'password': 'manbaul111',
      'role': 'kepsek',
      'icon': 'crown',
      'badgeColor': '0xFFD97706',
    },
    {
      'roleTitle': 'Staff Tata Usaha',
      'name': 'Hj. Maryam, S.E. (Staff TU)',
      'email': 'tu@manbaulhikmah.sch.id',
      'username': 'staff',
      'password': 'manbaul111',
      'role': 'staff',
      'icon': 'school',
      'badgeColor': '0xFF0284C7',
    },
    {
      'roleTitle': 'Wali Kelas 1A',
      'name': 'Ustadzah Fatimah, S.Pd.',
      'email': 'walikelas1a@manbaulhikmah.sch.id',
      'username': 'walikelas1a',
      'password': 'manbaul111',
      'role': 'wali_kelas',
      'icon': 'school',
      'badgeColor': '0xFF059669',
    },
    {
      'roleTitle': 'Wali Kelas 7A',
      'name': 'Ustadz Budi Santoso, S.Pd.',
      'email': 'walikelas7a@manbaulhikmah.sch.id',
      'username': 'walikelas7a',
      'password': 'manbaul111',
      'role': 'wali_kelas',
      'icon': 'school',
      'badgeColor': '0xFF0D9488',
    },
    {
      'roleTitle': 'Guru Pengajar',
      'name': 'Ustadz Hendra Pratama, S.Pd.',
      'email': 'guru@manbaulhikmah.sch.id',
      'username': 'guru',
      'password': 'manbaul111',
      'role': 'guru',
      'icon': 'book',
      'badgeColor': '0xFF2563EB',
    },
    {
      'roleTitle': 'Akun Wali Murid',
      'name': 'Bpk. H. Rahmat (Wali Ahmad & Rahma)',
      'email': 'ortu.ahmad@gmail.com',
      'username': 'ortu_ahmad',
      'password': 'manbaul111',
      'role': 'wali_murid',
      'icon': 'people',
      'badgeColor': '0xFF7C3AED',
    },
    {
      'roleTitle': 'Super Admin',
      'name': 'Hermawan (Super Admin)',
      'email': 'admin@manbaulhikmah.sch.id',
      'username': 'admin',
      'password': 'manbaul111',
      'role': 'admin',
      'icon': 'shield',
      'badgeColor': '0xFFDC2626',
    },
  ];

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _fillAccount(Map<String, String> acc) {
    setState(() {
      _usernameController.text = acc['email'] ?? acc['username']!;
      _passwordController.text = acc['password']!;
      _selectedDemoUser = acc['email'] ?? acc['username']!;
    });
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Akun ${acc['roleTitle']} dipilih (${acc['email']})'),
        duration: const Duration(seconds: 2),
        backgroundColor: Color(int.parse(acc['badgeColor']!)),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _handleLogin() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Silakan masukkan username dan password'),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    final provider = Provider.of<SchoolProvider>(context, listen: false);
    final res = await provider.login(username, password);
    setState(() => _isLoading = false);

    if (res['success'] == true) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res['message'] ?? 'Selamat datang!'),
            backgroundColor: AppTheme.gojekGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
          (route) => false,
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res['message'] ?? 'Login gagal. Coba lagi.'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  void _showForgotPasswordModal(BuildContext context) {
    final provider = Provider.of<SchoolProvider>(context, listen: false);
    final tuWhatsapp = provider.schoolProfile?.tuWhatsapp.isNotEmpty == true
        ? provider.schoolProfile!.tuWhatsapp
        : '6281298765432';

    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController(
      text: _usernameController.text.contains('@') ? _usernameController.text.trim() : '',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Row(
                children: [
                  Icon(Icons.help_center_rounded, color: Color(0xFF007AFF), size: 24),
                  SizedBox(width: 10),
                  Text(
                    'Bantuan Lupa Kata Sandi',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1C1C1E),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Kirimkan nama lengkap dan email akun Anda ke Tata Usaha (TU) via WhatsApp. Petugas TU akan me-reset password akun Anda ke default: manbaul111.',
                style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600, height: 1.3),
              ),
              const SizedBox(height: 16),

              // Nama Field
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: 'Nama Lengkap Anda',
                  hintText: 'Contoh: Bpk. H. Rahmat / Ustadzah Fatimah',
                  prefixIcon: const Icon(Icons.person_rounded, size: 20, color: Color(0xFF8E8E93)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
              const SizedBox(height: 12),

              // Email Field
              TextField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email Akun Terdaftar',
                  hintText: 'Contoh: ortu.ahmad@gmail.com',
                  prefixIcon: const Icon(Icons.alternate_email_rounded, size: 20, color: Color(0xFF8E8E93)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
              const SizedBox(height: 20),

              // Symmetrical 2-Column Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        'Batal',
                        style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final name = nameCtrl.text.trim();
                        final email = emailCtrl.text.trim();

                        if (name.isEmpty || email.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Nama dan email wajib diisi'),
                              backgroundColor: Color(0xFFFF3B30),
                            ),
                          );
                          return;
                        }

                        Navigator.pop(ctx);

                        final cleanPhone = tuWhatsapp.replaceAll(RegExp(r'[^0-9]'), '');
                        final targetPhone = cleanPhone.startsWith('0')
                            ? '62${cleanPhone.substring(1)}'
                            : cleanPhone;

                        final message = "Assalamu'alaikum Staff TU SDIT Manbaul Hikmah,\n\n"
                            "Saya mengajukan permohonan reset kata sandi akun karena lupa password, dengan data:\n"
                            "• Nama Lengkap: *$name*\n"
                            "• Email Terdaftar: *$email*\n\n"
                            "Mohon bantuannya untuk me-reset kata sandi akun saya ke password default (manbaul111). Terima kasih. Jazakumullah khairan.";

                        final waUri = Uri.parse('https://wa.me/$targetPhone?text=${Uri.encodeComponent(message)}');

                        try {
                          await launchUrl(waUri, mode: LaunchMode.externalApplication);
                        } catch (_) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Tidak dapat membuka WhatsApp. Silakan hubungi TU secara langsung.'),
                                backgroundColor: Color(0xFFFF3B30),
                              ),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.chat_rounded, size: 18),
                      label: const Text('Kirim ke WA TU'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00B14F),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7), // iOS grouped background
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // iOS App Icon Badge
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00B14F), Color(0xFF008A3D)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00B14F).withOpacity(0.35),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.school_rounded,
                    size: 44,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),

                // App Title & Tagline
                const Text(
                  'Manbaul Hikmah',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    color: Color(0xFF1C1C1E),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Smart SDIT & School Management',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 28),

                // iOS Styled Card Container for Form
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Email / Username Field
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: TextField(
                          controller: _usernameController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            icon: Icon(Icons.alternate_email_rounded, color: Colors.grey.shade600, size: 22),
                            hintText: 'Email Akun Terdaftar',
                            hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade400),
                            border: InputBorder.none,
                          ),
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                        ),
                      ),
                      Divider(height: 1, color: Colors.grey.shade200, indent: 48),

                      // Password Field
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            icon: Icon(Icons.lock_outline_rounded, color: Colors.grey.shade600, size: 22),
                            hintText: 'Password',
                            hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade400),
                            border: InputBorder.none,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                color: Colors.grey.shade500,
                                size: 20,
                              ),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // iOS Primary Action Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00B14F),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      shadowColor: const Color(0xFF00B14F).withOpacity(0.4),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Masuk ke Aplikasi',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: -0.3),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward_rounded, size: 20),
                            ],
                          ),
                  ),
                ),

                const SizedBox(height: 12),

                // Lupa Kata Sandi Button
                Align(
                  alignment: Alignment.center,
                  child: TextButton.icon(
                    onPressed: () => _showForgotPasswordModal(context),
                    icon: const Icon(Icons.help_outline_rounded, size: 16, color: Color(0xFF007AFF)),
                    label: const Text(
                      'Lupa Kata Sandi? Hubungi TU via WA',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF007AFF),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Dummy Accounts Title Divider
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey.shade300)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'PILIH AKUN CEPAT (1-TAP AUTOFILL)',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade500,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey.shade300)),
                  ],
                ),
                const SizedBox(height: 10),

                // Password Default Info Banner
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00B14F).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF00B14F).withOpacity(0.2)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline_rounded, size: 18, color: Color(0xFF008A3D)),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Akses login menggunakan Email resmi. Password default: manbaul111 (Dapat diubah di menu Pengaturan).',
                          style: TextStyle(fontSize: 11.5, color: Color(0xFF008A3D), fontWeight: FontWeight.w600, height: 1.3),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Dummy Accounts Interactive List
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _demoAccounts.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final acc = _demoAccounts[index];
                    final isSelected = _selectedDemoUser == acc['email'] || _selectedDemoUser == acc['username'];
                    final color = Color(int.parse(acc['badgeColor']!));

                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _fillAccount(acc),
                        borderRadius: BorderRadius.circular(14),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                          decoration: BoxDecoration(
                            color: isSelected ? color.withOpacity(0.08) : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected ? color : Colors.grey.shade200,
                              width: isSelected ? 1.8 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              // Avatar Badge
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  acc['icon'] == 'crown'
                                      ? Icons.military_tech_rounded
                                      : acc['icon'] == 'school'
                                          ? Icons.badge_rounded
                                          : acc['icon'] == 'shield'
                                              ? Icons.admin_panel_settings_rounded
                                              : Icons.family_restroom_rounded,
                                  color: color,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Account details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          acc['roleTitle']!,
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: color,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      acc['email'] ?? acc['username']!,
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 1),
                                    Text(
                                      acc['name']!,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF2C2C2E),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),

                              // Quick Fill Chip
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      isSelected ? 'Terpilih' : 'Pilih',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: color,
                                      ),
                                    ),
                                    const SizedBox(width: 3),
                                    Icon(
                                      isSelected ? Icons.check_circle : Icons.touch_app_outlined,
                                      size: 13,
                                      color: color,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),
                // Dedicated API Server Footnote
                Text(
                  'Connected to Dedicated API: maoneart.my.id/manbaul/api',
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
