import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/student.dart';
import '../../providers/school_provider.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../settings/change_password_screen.dart';
import '../students/student_detail_screen.dart';
import '../students/student_nametag_screen.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _nikCtrl;
  late TextEditingController _addressCtrl;

  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<SchoolProvider>(context, listen: false);
    final user = provider.currentUser;

    _nameCtrl = TextEditingController(text: user?['name']?.toString() ?? '');
    _emailCtrl = TextEditingController(text: user?['email']?.toString() ?? '');
    _phoneCtrl = TextEditingController(text: user?['phone']?.toString() ?? '');
    _nikCtrl = TextEditingController(text: user?['nik']?.toString() ?? '');
    _addressCtrl = TextEditingController(text: user?['address']?.toString() ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _nikCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final provider = Provider.of<SchoolProvider>(context, listen: false);

    final res = await provider.updateProfile(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      nik: _nikCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
    );

    setState(() {
      _isLoading = false;
      _isEditing = false;
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(res['message'] ?? 'Profil berhasil disimpan'),
        backgroundColor: res['success'] == true ? const Color(0xFF00B14F) : const Color(0xFFFF3B30),
      ),
    );
  }

  void _showResetOtherUserModal(BuildContext context, SchoolProvider provider) {
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
          padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
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
                  Icon(Icons.lock_reset_rounded, color: Color(0xFFD97706), size: 24),
                  SizedBox(width: 10),
                  Text(
                    'Reset Kata Sandi Akun',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1C1C1E)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Pilih pengguna untuk mengembalikan kata sandinya ke default: manbaul111.',
                style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 12),
              // Dynamic Users List
              FutureBuilder<List<Map<String, dynamic>>>(
                future: ApiService.getUsers(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final usersList = (snapshot.hasData && snapshot.data!.isNotEmpty)
                      ? snapshot.data!
                      : [
                          {'id': 1, 'name': 'Hermawan (Super Admin)', 'role': 'admin', 'email': 'admin@manbaulhikmah.sch.id'},
                          {'id': 2, 'name': 'KH. Ahmad Syafei, M.Pd.', 'role': 'kepsek', 'email': 'kepsek@manbaulhikmah.sch.id'},
                          {'id': 3, 'name': 'Hj. Maryam, S.E. (Staff TU)', 'role': 'staff', 'email': 'tu@manbaulhikmah.sch.id'},
                          {'id': 4, 'name': 'Ustadzah Fatimah, S.Pd.', 'role': 'wali_kelas', 'email': 'walikelas1a@manbaulhikmah.sch.id'},
                          {'id': 5, 'name': 'Ustadz Budi Santoso, S.Pd.', 'role': 'wali_kelas', 'email': 'walikelas7a@manbaulhikmah.sch.id'},
                          {'id': 7, 'name': 'Ustadz Hendra Pratama, S.Pd.', 'role': 'guru', 'email': 'guru@manbaulhikmah.sch.id'},
                          {'id': 8, 'name': 'Bpk. H. Rahmat (Wali Murid)', 'role': 'wali_murid', 'email': 'ortu.ahmad@gmail.com'},
                        ];

                  return ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(ctx).size.height * 0.45,
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      itemCount: usersList.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, i) {
                        final u = usersList[i];
                        final uId = int.tryParse(u['id']?.toString() ?? '0') ?? 0;
                        final uName = u['name']?.toString() ?? 'Pengguna';
                        final uEmail = u['email']?.toString() ?? u['username']?.toString() ?? '-';
                        final uRole = u['role']?.toString() ?? '-';

                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: const Color(0xFF007AFF).withOpacity(0.12),
                                child: Text(
                                  uName.isNotEmpty ? uName[0] : 'U',
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF007AFF), fontSize: 13),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      uName,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1C1C1E)),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      '$uEmail • ${_formatRoleName(uRole)}',
                                      style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () async {
                                  Navigator.pop(ctx);
                                  final res = await provider.resetUserPassword(targetUserId: uId);
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Password untuk $uName berhasil di-reset ke: manbaul111'),
                                      backgroundColor: const Color(0xFF00B14F),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFD97706),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  elevation: 0,
                                ),
                                child: const Text('Reset', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SchoolProvider>(context);
    final user = provider.currentUser;
    final isWaliMurid = provider.currentRole == 'wali_murid';
    final isAdminOrTu = provider.currentRole == 'admin' || provider.currentRole == 'staff';
    final myChildren = provider.myChildren;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF2F2F7),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.chevron_back, color: Color(0xFF007AFF), size: 28),
          tooltip: 'Kembali',
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Profil Akun',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            color: Color(0xFF1C1C1E),
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              if (_isEditing) {
                _saveProfile();
              } else {
                setState(() => _isEditing = true);
              }
            },
            icon: Icon(_isEditing ? Icons.check_rounded : Icons.edit_rounded, size: 18, color: const Color(0xFF007AFF)),
            label: Text(
              _isEditing ? 'Simpan' : 'Edit',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF007AFF), fontSize: 14),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==========================================
              // 1. TOP AVATAR & IDENTITY CARD
              // ==========================================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
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
                  children: [
                    // Big Circular Avatar
                    Container(
                      width: 76,
                      height: 76,
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
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        (_nameCtrl.text.isNotEmpty) ? _nameCtrl.text.substring(0, 1).toUpperCase() : 'M',
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _nameCtrl.text.isNotEmpty ? _nameCtrl.text : (user?['name'] ?? 'Pengguna Sekolah'),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1C1C1E)),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00B14F).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _formatRoleName(provider.currentRole),
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF008A3D)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.check_circle_rounded, size: 12, color: Color(0xFF007AFF)),
                              SizedBox(width: 4),
                              Text('Aktif', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF007AFF))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ==========================================
              // 2. DATA AKUN & IDENTITAS DIRI
              // ==========================================
              _buildSectionHeader('INFORMASI DATA DIRI & LOGIN'),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2)),
                  ],
                ),
                child: Column(
                  children: [
                    // Nama Lengkap
                    _buildFieldTile(
                      icon: Icons.person_rounded,
                      label: 'Nama Lengkap',
                      controller: _nameCtrl,
                      isEditing: _isEditing,
                    ),
                    _buildDivider(),

                    // Email Resmi (Login ID)
                    _buildFieldTile(
                      icon: Icons.alternate_email_rounded,
                      label: 'Email Akun Terdaftar (Login ID)',
                      controller: _emailCtrl,
                      isEditing: _isEditing,
                      keyboardType: TextInputType.emailAddress,
                      helperText: 'Digunakan sebagai username saat login',
                    ),
                    _buildDivider(),

                    // No. HP / WhatsApp
                    _buildFieldTile(
                      icon: Icons.phone_rounded,
                      label: 'No. HP / WhatsApp',
                      controller: _phoneCtrl,
                      isEditing: _isEditing,
                      keyboardType: TextInputType.phone,
                    ),
                    _buildDivider(),

                    // NIK (16 Digit)
                    _buildFieldTile(
                      icon: Icons.badge_rounded,
                      label: 'NIK (Nomor Induk Kependudukan)',
                      controller: _nikCtrl,
                      isEditing: _isEditing,
                      keyboardType: TextInputType.number,
                      helperText: isWaliMurid ? 'Kunci identitas keluarga untuk tautan anak' : null,
                    ),
                    _buildDivider(),

                    // Alamat Domisili
                    _buildFieldTile(
                      icon: Icons.location_on_rounded,
                      label: 'Alamat Tinggal / Domisili',
                      controller: _addressCtrl,
                      isEditing: _isEditing,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ==========================================
              // 3. KHUSUS WALI MURID: DAFTAR ANAK TERHUBUNG
              // ==========================================
              if (isWaliMurid) ...[
                _buildSectionHeader('DAFTAR ANAK TERHUBUNG (${myChildren.length} SISWA)'),
                if (myChildren.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text('Belum ada anak yang terhubung dengan akun ini.', style: TextStyle(color: Colors.grey)),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: myChildren.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, idx) {
                      final child = myChildren[idx];
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2)),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 22,
                                  backgroundColor: const Color(0xFF00B14F).withOpacity(0.12),
                                  child: Text(
                                    child.name.isNotEmpty ? child.name[0] : 'S',
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF008A3D), fontSize: 16),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        child.name,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1C1C1E)),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${child.className} • NISN: ${child.nisn}',
                                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                                      ),
                                      if (child.studentNik.isNotEmpty)
                                        Text(
                                          'NIK Siswa: ${child.studentNik}',
                                          style: const TextStyle(fontSize: 11, color: Color(0xFF007AFF), fontWeight: FontWeight.w600),
                                        ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF00B14F).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    child.status,
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF008A3D)),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            // Quick Action Buttons for Child
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => StudentNametagScreen(student: child),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.badge_rounded, size: 16, color: Color(0xFF00B14F)),
                                    label: const Text('Kartu Name Tag', style: TextStyle(fontSize: 12, color: Color(0xFF008A3D), fontWeight: FontWeight.bold)),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      side: BorderSide(color: const Color(0xFF00B14F).withOpacity(0.3)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => StudentDetailScreen(student: child),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFF007AFF)),
                                    label: const Text('Rincian Data', style: TextStyle(fontSize: 12, color: Color(0xFF007AFF), fontWeight: FontWeight.bold)),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      side: BorderSide(color: const Color(0xFF007AFF).withOpacity(0.3)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 24),
              ],

              // ==========================================
              // 4. KEAMANAN & KATA SANDI
              // ==========================================
              _buildSectionHeader('KEAMANAN & KATA SANDI'),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2)),
                  ],
                ),
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      leading: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: const Color(0xFF007AFF),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.key_rounded, size: 20, color: Colors.white),
                      ),
                      title: const Text('Ubah Kata Sandi', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1C1C1E))),
                      subtitle: const Text('Ganti password default manbaul111', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Color(0xFFC7C7CC)),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
                        );
                      },
                    ),

                    // Reset Password Khusus Admin & Staff TU
                    if (isAdminOrTu) ...[
                      _buildDivider(),
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        leading: Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD97706),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.lock_reset_rounded, size: 20, color: Colors.white),
                        ),
                        title: const Text('Reset Kata Sandi Akun Pengguna', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1C1C1E))),
                        subtitle: const Text('Kembalikan password pengguna ke default: manbaul111', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Color(0xFFC7C7CC)),
                        onTap: () => _showResetOtherUserModal(context, provider),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Symmetrical 2-Column Buttons if Editing
              if (_isEditing) ...[
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => setState(() => _isEditing = false),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                        child: Text(
                          'Batal',
                          style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00B14F),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text('Simpan Profil', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF6C6C70), letterSpacing: 0.4),
      ),
    );
  }

  static Widget _buildDivider() {
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
      case 'staff':
        return 'Staff Tata Usaha';
      case 'wali_murid':
        return 'Wali Murid';
      default:
        return role;
    }
  }

  Widget _buildFieldTile({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    required bool isEditing,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? helperText,
  }) {
    if (isEditing) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1C1C1E)),
          decoration: InputDecoration(
            icon: Icon(icon, size: 20, color: const Color(0xFF8E8E93)),
            labelText: label,
            helperText: helperText,
            border: InputBorder.none,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: const Color(0xFF8E8E93)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 11.5, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(
                  controller.text.isNotEmpty ? controller.text : '-',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1C1C1E)),
                ),
                if (helperText != null) ...[
                  const SizedBox(height: 2),
                  Text(helperText, style: const TextStyle(fontSize: 10.5, color: Color(0xFF00B14F))),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
