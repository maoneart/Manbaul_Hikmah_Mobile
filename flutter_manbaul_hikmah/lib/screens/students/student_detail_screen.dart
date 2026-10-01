import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/student.dart';
import '../../providers/school_provider.dart';
import 'student_nametag_screen.dart';
import 'student_form_screen.dart';

class StudentDetailScreen extends StatefulWidget {
  final Student student;

  const StudentDetailScreen({super.key, required this.student});

  @override
  State<StudentDetailScreen> createState() => _StudentDetailScreenState();
}

class _StudentDetailScreenState extends State<StudentDetailScreen> {
  late Student _currentStudent;

  @override
  void initState() {
    super.initState();
    _currentStudent = widget.student;
  }

  void _refreshStudentData(SchoolProvider provider) {
    final updated = provider.allStudents.firstWhere(
      (s) => s.id == _currentStudent.id,
      orElse: () => _currentStudent,
    );
    setState(() => _currentStudent = updated);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SchoolProvider>(context);
    final s = provider.allStudents.firstWhere(
      (st) => st.id == _currentStudent.id,
      orElse: () => _currentStudent,
    );

    final att = provider.getStudentAttendance(s.id);
    final isLaki = s.gender == 'L';

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7), // iOS Grouped Background
      appBar: AppBar(
        title: const Text(
          'Detail Buku Induk Siswa',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1C1C1E),
          ),
        ),
        leading: IconButton(
          icon: const Icon(CupertinoIcons.chevron_back, color: Color(0xFF007AFF), size: 28),
          tooltip: 'Kembali',
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        actions: [
          if (provider.canEditStudent)
            IconButton(
              icon: const Icon(Icons.edit_rounded, color: Color(0xFFD97706)),
              tooltip: 'Edit Data Siswa (SOP)',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => StudentFormScreen(student: s)),
                );
              },
            ),
          IconButton(
            icon: const Icon(Icons.qr_code_rounded, color: Color(0xFFAF52DE)),
            tooltip: 'Kartu Pelajar & QR',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => StudentNametagScreen(student: s)),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==========================================
            // 1. HERO PROFILE CARD
            // ==========================================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Avatar
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isLaki
                            ? [const Color(0xFF007AFF), const Color(0xFF0051A8)]
                            : [const Color(0xFFFF2D55), const Color(0xFFCC1F40)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (isLaki ? const Color(0xFF007AFF) : const Color(0xFFFF2D55)).withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        s.name.isNotEmpty ? s.name[0].toUpperCase() : 'S',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Name
                  Text(
                    s.name,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1C1C1E),
                      letterSpacing: -0.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),

                  // NISN & Badges
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00B14F).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          s.className,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF008A3D),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: (s.status == 'Lulus'
                                  ? const Color(0xFF007AFF)
                                  : (s.status == 'Pindah' ? const Color(0xFFFF9500) : const Color(0xFF34C759)))
                              .withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          s.status,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: s.status == 'Lulus'
                                ? const Color(0xFF007AFF)
                                : (s.status == 'Pindah' ? const Color(0xFFD97706) : const Color(0xFF248A3D)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'NISN: ${s.nisn} • Token QR: ${s.qrCodeToken}',
                    style: TextStyle(fontSize: 11.5, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ==========================================
            // 2. FINANCIAL & ATTENDANCE SUMMARY PILLS
            // ==========================================
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(14),
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
                    child: Builder(
                      builder: (_) {
                        final isStaffOrKepsek = provider.currentRole == 'staff' || provider.currentRole == 'kepsek';
                        if (isStaffOrKepsek) {
                          final unpaidCount = provider.bills.where((b) => b.studentId == s.id && b.status == 'Belum Lunas').length;
                          final isAllPaid = unpaidCount == 0;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.payments_rounded, size: 14, color: isAllPaid ? const Color(0xFF008A3D) : const Color(0xFFD70015)),
                                  const SizedBox(width: 4),
                                  const Text('Status Tagihan SPP', style: TextStyle(fontSize: 11, color: Color(0xFF6C6C70), fontWeight: FontWeight.w600)),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                isAllPaid ? 'Lunas Bebas SPP' : '$unpaidCount Tagihan SPP',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: isAllPaid ? const Color(0xFF008A3D) : const Color(0xFFD70015),
                                ),
                              ),
                            ],
                          );
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.account_balance_wallet_rounded, size: 14, color: Color(0xFFD97706)),
                                SizedBox(width: 4),
                                Text('Saldo Tabungan', style: TextStyle(fontSize: 11, color: Color(0xFF6C6C70), fontWeight: FontWeight.w600)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Rp ${s.balance.toStringAsFixed(0).replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]}.")}',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFFB45309)),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(14),
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
                        const Row(
                          children: [
                            Icon(Icons.fact_check_rounded, size: 14, color: Color(0xFF008A3D)),
                            SizedBox(width: 4),
                            Text('Presensi Hari Ini', style: TextStyle(fontSize: 11, color: Color(0xFF6C6C70), fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          att?.status ?? 'Belum Presensi',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: att?.status == 'Hadir'
                                ? const Color(0xFF008A3D)
                                : (att?.status == 'Sakit' ? const Color(0xFF007AFF) : const Color(0xFFFF9500)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ==========================================
            // 3. SECTION: IDENTITAS SISWA LENGKAP
            // ==========================================
            _buildSectionHeader('IDENTITAS SISWA SESUAI BUKU INDUK'),
            _buildGroupedCard([
              _buildDataTile(
                icon: Icons.tag_rounded,
                label: 'NISN (Nomor Induk Siswa Nasional)',
                value: s.nisn,
              ),
              _buildDivider(),
              _buildDataTile(
                icon: Icons.credit_card_rounded,
                label: 'NIK Siswa (Nomor Induk Kependudukan)',
                value: s.studentNik.isNotEmpty ? s.studentNik : '-',
              ),
              _buildDivider(),
              _buildDataTile(
                icon: Icons.person_outline_rounded,
                label: 'Nama Lengkap Siswa',
                value: s.name,
              ),
              _buildDivider(),
              _buildDataTile(
                icon: isLaki ? Icons.male_rounded : Icons.female_rounded,
                label: 'Jenis Kelamin',
                value: isLaki ? 'Laki-laki (Ikhwan)' : 'Perempuan (Akhwat)',
              ),
              _buildDivider(),
              _buildDataTile(
                icon: Icons.cake_outlined,
                label: 'Tempat, Tanggal Lahir',
                value: s.birthPlaceDate.isNotEmpty && s.birthPlaceDate != '-' ? s.birthPlaceDate : 'Bekasi, 15 Januari 2017',
              ),
              _buildDivider(),
              _buildDataTile(
                icon: Icons.mosque_outlined,
                label: 'Agama & Kewarganegaraan',
                value: 'Islam • Warga Negara Indonesia (WNI)',
              ),
            ]),

            const SizedBox(height: 20),

            // ==========================================
            // 4. SECTION: ADMINISTRASI SEKOLAH
            // ==========================================
            _buildSectionHeader('ADMINISTRASI SEKOLAH & KELAS'),
            _buildGroupedCard([
              _buildDataTile(
                icon: Icons.class_outlined,
                label: 'Rombel / Kelas Aktif',
                value: s.className,
                trailing: provider.canEditStudent
                    ? TextButton(
                        onPressed: () => _showPromoteClassDialog(context, provider, s),
                        child: const Text('Pindah Kelas', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF007AFF))),
                      )
                    : null,
              ),
              _buildDivider(),
              _buildDataTile(
                icon: Icons.event_available_rounded,
                label: 'Tanggal Masuk Sekolah (SOP)',
                value: s.admissionDate.isNotEmpty ? s.admissionDate : 'Tahun ${s.entryYear}',
              ),
              _buildDivider(),
              _buildDataTile(
                icon: Icons.school_outlined,
                label: 'Tahun Ajaran Aktif',
                value: 'TA 2026/2027 • Semester Ganjil',
              ),
              _buildDivider(),
              _buildDataTile(
                icon: Icons.verified_user_outlined,
                label: 'Status Siswa',
                value: s.status,
              ),
              if (s.status == 'Lulus') ...[
                _buildDivider(),
                _buildDataTile(
                  icon: Icons.workspace_premium_rounded,
                  label: 'Tanggal Kelulusan Resmi (SOP)',
                  value: s.graduationDate.isNotEmpty ? s.graduationDate : '-',
                ),
              ],
            ]),

            const SizedBox(height: 20),

            // ==========================================
            // 5. SECTION: ORANG TUA / WALI
            // ==========================================
            _buildSectionHeader('DATA ORANG TUA & WALI MURID'),
            _buildGroupedCard([
              _buildDataTile(
                icon: Icons.fingerprint_rounded,
                label: 'NIK Orang Tua / Wali (Kunci Multi-Anak)',
                value: s.parentNik.isNotEmpty ? s.parentNik : '-',
              ),
              _buildDivider(),
              _buildDataTile(
                icon: Icons.people_alt_outlined,
                label: 'Nama Orang Tua / Wali Utama',
                value: s.parentName.isNotEmpty ? s.parentName : '-',
              ),
              _buildDivider(),
              _buildDataTile(
                icon: Icons.phone_outlined,
                label: 'No. Handphone / WhatsApp Ortu',
                value: s.parentPhone.isNotEmpty ? s.parentPhone : '-',
              ),
              _buildDivider(),
              _buildDataTile(
                icon: Icons.family_restroom_outlined,
                label: 'Hubungan Keluarga',
                value: 'Orang Tua Kandung / Wali Sah',
              ),
            ]),

            const SizedBox(height: 20),

            // ==========================================
            // 6. SECTION: ALAMAT & KONTAK
            // ==========================================
            _buildSectionHeader('ALAMAT DOMISILI TEMPAT TINGGAL'),
            _buildGroupedCard([
              _buildDataTile(
                icon: Icons.home_outlined,
                label: 'Alamat Lengkap',
                value: s.address.isNotEmpty && s.address != '-' ? s.address : 'Jl. KH. Noer Ali No. 12, RT 02/03',
              ),
              _buildDivider(),
              _buildDataTile(
                icon: Icons.location_city_outlined,
                label: 'Wilayah Domisili',
                value: 'Desa Karang Satria, Kec. Tambun Utara, Kab. Bekasi',
              ),
            ]),

            const SizedBox(height: 30),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Pindah Kelas CTA
            if (provider.canEditStudent) ...[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showPromoteClassDialog(context, provider, s),
                  icon: const Icon(Icons.swap_horiz_rounded, size: 18),
                  label: const Text('Pindah Kelas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF007AFF),
                    side: const BorderSide(color: Color(0xFF007AFF)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
            ],

            // Cetak QR Name Tag CTA
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => StudentNametagScreen(student: s)),
                  );
                },
                icon: const Icon(Icons.qr_code_rounded, size: 18, color: Colors.white),
                label: const Text('Name Tag QR', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00B14F),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // MODAL PINDAH / KENAIKAN KELAS
  // ==========================================
  void _showPromoteClassDialog(BuildContext context, SchoolProvider provider, Student s) {
    String targetClass = s.className;
    final List<String> availableClasses = [
      'Kelas 1A', 'Kelas 1B', 'Kelas 1C',
      'Kelas 2A', 'Kelas 2B', 'Kelas 2C',
      'Kelas 3A', 'Kelas 3B', 'Kelas 3C',
      'Kelas 4A', 'Kelas 4B', 'Kelas 4C',
      'Kelas 5A', 'Kelas 5B', 'Kelas 5C',
      'Kelas 6A', 'Kelas 6B', 'Kelas 6C',
      'Kelas 7A', 'Kelas 7B', 'Kelas 8A', 'Kelas 9A',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Pindah / Kenaikan Kelas Siswa',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1C1C1E)),
              ),
              const SizedBox(height: 4),
              Text(
                'Pilih rombongan belajar baru untuk ${s.name} dari Master Kelas resmi.',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF007AFF).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, color: Color(0xFF007AFF), size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Kelas Sebelumnya: ${s.className}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF007AFF)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              const Text('Target Kelas Baru:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF3C3C43))),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F2F7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: targetClass,
                    isExpanded: true,
                    items: availableClasses.map((cls) => DropdownMenuItem(value: cls, child: Text(cls))).toList(),
                    onChanged: (val) {
                      if (val != null) setModalState(() => targetClass = val);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Batal', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(ctx);
                        final success = await provider.transferStudentClass(s.id, targetClass);
                        if (mounted) {
                          _refreshStudentData(provider);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(success
                                  ? 'Kelas ${s.name} berhasil diperbarui ke $targetClass'
                                  : 'Gagal memperbarui kelas siswa'),
                              backgroundColor: success ? const Color(0xFF00B14F) : const Color(0xFFFF3B30),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF007AFF),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Simpan Perubahan', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // HELPERS
  // ==========================================
  static Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Color(0xFF8E8E93),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  static Widget _buildGroupedCard(List<Widget> children) {
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

  static Widget _buildDataTile({
    required IconData icon,
    required String label,
    required String value,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F2F7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: const Color(0xFF007AFF)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Color(0xFF1C1C1E)),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  static Widget _buildDivider() {
    return Divider(height: 1, indent: 52, color: Colors.grey.shade100);
  }
}
