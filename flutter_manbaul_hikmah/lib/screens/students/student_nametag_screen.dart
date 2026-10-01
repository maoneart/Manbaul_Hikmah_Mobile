import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../models/student.dart';
import '../../providers/school_provider.dart';

class StudentNametagScreen extends StatefulWidget {
  final Student? student;

  const StudentNametagScreen({super.key, this.student});

  @override
  State<StudentNametagScreen> createState() => _StudentNametagScreenState();
}

class _StudentNametagScreenState extends State<StudentNametagScreen> {
  Student? _activeStudent;
  bool _showBackSide = false;

  @override
  void initState() {
    super.initState();
    _activeStudent = widget.student;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SchoolProvider>(context);
    final isWaliMurid = provider.currentRole == 'wali_murid';
    final students = provider.allStudents;
    final myChildren = provider.myChildren;

    if (isWaliMurid) {
      if (_activeStudent == null && myChildren.isNotEmpty) {
        _activeStudent = myChildren.first;
      } else if (_activeStudent == null) {
        _activeStudent = provider.myChildStudent;
      }
    } else if (_activeStudent == null && students.isNotEmpty) {
      _activeStudent = students.first;
    }

    final currentStudent = _activeStudent;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(CupertinoIcons.chevron_back, color: Color(0xFF007AFF), size: 28),
          tooltip: 'Kembali',
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Kartu Pelajar Smart ID',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
            color: Color(0xFF1C1C1E),
          ),
        ),
        backgroundColor: const Color(0xFFF2F2F7),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _showBackSide ? Icons.flip_to_front_rounded : Icons.flip_to_back_rounded,
              color: const Color(0xFF007AFF),
            ),
            tooltip: _showBackSide ? 'Lihat Sisi Depan' : 'Lihat Sisi Belakang',
            onPressed: () => setState(() => _showBackSide = !_showBackSide),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: currentStudent == null
          ? const Center(child: Text('Belum ada data siswa untuk dicetak.'))
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                children: [
                  // Selector Siswa (Jika Ortu punya multi anak atau Staf/Guru)
                  if (isWaliMurid && myChildren.length > 1)
                    Container(
                      margin: const EdgeInsets.bottom: 16,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2)),
                        ],
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          isExpanded: true,
                          value: currentStudent.id,
                          items: myChildren.map((s) {
                            return DropdownMenuItem<int>(
                              value: s.id,
                              child: Row(
                                children: [
                                  const Icon(Icons.face_rounded, size: 18, color: Color(0xFF00B14F)),
                                  const SizedBox(width: 8),
                                  Text('${s.name} (${s.className})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (id) {
                            if (id != null) {
                              setState(() => _activeStudent = myChildren.firstWhere((s) => s.id == id));
                            }
                          },
                        ),
                      ),
                    )
                  else if (!isWaliMurid)
                    Container(
                      margin: const EdgeInsets.bottom: 16,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2)),
                        ],
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          isExpanded: true,
                          value: currentStudent.id,
                          items: students.map((s) {
                            return DropdownMenuItem<int>(
                              value: s.id,
                              child: Text('${s.name} (${s.className})', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                            );
                          }).toList(),
                          onChanged: (id) {
                            if (id != null) {
                              setState(() => _activeStudent = students.firstWhere((s) => s.id == id));
                            }
                          },
                        ),
                      ),
                    ),

                  // Flip Toggle Segment
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(3),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _showBackSide = false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: !_showBackSide ? Colors.white : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: !_showBackSide
                                    ? [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 4, offset: const Offset(0, 2))]
                                    : null,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Sisi Depan (Identitas)',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: !_showBackSide ? FontWeight.bold : FontWeight.w500,
                                  color: !_showBackSide ? const Color(0xFF007AFF) : Colors.grey.shade600,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _showBackSide = true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: _showBackSide ? Colors.white : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: _showBackSide
                                    ? [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 4, offset: const Offset(0, 2))]
                                    : null,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Sisi Belakang (Ketentuan)',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: _showBackSide ? FontWeight.bold : FontWeight.w500,
                                  color: _showBackSide ? const Color(0xFF007AFF) : Colors.grey.shade600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ==========================================
                  // DIGITAL SMART ID CARD
                  // ==========================================
                  Center(
                    child: AnimatedCrossFade(
                      duration: const Duration(milliseconds: 350),
                      crossFadeState: !_showBackSide ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                      firstChild: _buildFrontCard(currentStudent),
                      secondChild: _buildBackCard(currentStudent),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Card Action Buttons (MaoneArt Symmetrical 2-Column Buttons)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => setState(() => _showBackSide = !_showBackSide),
                          icon: Icon(_showBackSide ? Icons.flip_to_front_rounded : Icons.flip_to_back_rounded, size: 18),
                          label: Text(_showBackSide ? 'Sisi Depan' : 'Sisi Balik'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            foregroundColor: const Color(0xFF007AFF),
                            side: const BorderSide(color: Color(0xFF007AFF)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Kartu Smart ID ${currentStudent.name} siap dicetak (PDF Standar CR-80)'),
                                backgroundColor: const Color(0xFF00B14F),
                              ),
                            );
                          },
                          icon: const Icon(Icons.print_rounded, size: 18),
                          label: const Text('Cetak Kartu PDF'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: const Color(0xFF00B14F),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  // ==========================================
  // FRONT CARD WIDGET
  // ==========================================
  Widget _buildFrontCard(Student student) {
    return Container(
      width: 320,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF064E3B), // Emerald Dark
            Color(0xFF065F46),
            Color(0xFF042F2E),
            Color(0xFF0F172A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFD97706).withOpacity(0.7), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF064E3B).withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background Decorative Islamic Motif Geometric Watermark
          Positioned(
            right: -30,
            top: -30,
            child: Opacity(
              opacity: 0.05,
              child: Transform.rotate(
                angle: math.pi / 4,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 20),
                  ),
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                // Header Madrasah
                Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: const Text('MH', style: TextStyle(color: Color(0xFF064E3B), fontWeight: FontWeight.w900, fontSize: 16)),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SDIT MANBAUL HIKMAH',
                            style: TextStyle(
                              color: Color(0xFFFDE68A),
                              fontWeight: FontWeight.w900,
                              fontSize: 12.5,
                              letterSpacing: 0.6,
                            ),
                          ),
                          Text(
                            'KARTU PELAJAR & SMART PRESENSI',
                            style: TextStyle(color: Colors.white70, fontSize: 8.5, letterSpacing: 0.4),
                          ),
                        ],
                      ),
                    ),
                    // Chip Smart Card Emblem
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.nfc_rounded, size: 12, color: Color(0xFFFDE68A)),
                          SizedBox(width: 3),
                          Text('SMART', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Color(0xFFFDE68A))),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                Divider(color: Colors.white.withOpacity(0.15), height: 1),
                const SizedBox(height: 14),

                // Student Photo & Bio
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Photo Frame with Gold Border
                    Container(
                      width: 72,
                      height: 88,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF065F46), Color(0xFF042F2E)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFF59E0B), width: 1.5),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 6),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        student.name.isNotEmpty ? student.name[0] : 'S',
                        style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFFFDE68A)),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Bio Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            student.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF59E0B).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              student.className,
                              style: const TextStyle(color: Color(0xFFFDE68A), fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 6),
                          _buildBioRow('NISN', student.nisn),
                          if (student.studentNik.isNotEmpty)
                            _buildBioRow('NIK Siswa', student.studentNik),
                          _buildBioRow('Status', student.status),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // QR Code Container with High Precision
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8),
                    ],
                  ),
                  child: Row(
                    children: [
                      QrImageView(
                        data: student.qrCodeToken,
                        version: QrVersions.auto,
                        size: 80.0,
                        eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Color(0xFF064E3B)),
                        dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: Color(0xFF064E3B)),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'QR KODE OTENTIKASI',
                              style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF064E3B), letterSpacing: 0.4),
                            ),
                            SizedBox(height: 3),
                            Text(
                              'Digunakan untuk presensi kedatangan & transaksi tabungan siswa.',
                              style: TextStyle(fontSize: 9.5, color: Color(0xFF4B5563), height: 1.25),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),
                Divider(color: Colors.white.withOpacity(0.15), height: 1),
                const SizedBox(height: 10),

                // Footer Info
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('T.A 2026/2027 • BEKASI', style: TextStyle(color: Colors.white54, fontSize: 9, fontWeight: FontWeight.w600)),
                    Text('OFFICIAL SMART CARD', style: TextStyle(color: Color(0xFFFDE68A), fontSize: 9, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // BACK CARD WIDGET
  // ==========================================
  Widget _buildBackCard(Student student) {
    return Container(
      width: 320,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF064E3B),
            Color(0xFF065F46),
            Color(0xFF042F2E),
            Color(0xFF0F172A),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFD97706).withOpacity(0.7), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF064E3B).withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Ketentuan
            const Row(
              children: [
                Icon(Icons.rule_folder_rounded, color: Color(0xFFFDE68A), size: 18),
                SizedBox(width: 8),
                Text(
                  'TATA TERTIB & KETENTUAN KARTU',
                  style: TextStyle(
                    color: Color(0xFFFDE68A),
                    fontWeight: FontWeight.bold,
                    fontSize: 11.5,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Divider(color: Colors.white.withOpacity(0.15), height: 1),
            const SizedBox(height: 12),

            // Terms List
            _buildTermItem('1', 'Kartu wajib dibawa setiap hari sekolah & saat berkegiatan di lingkungan madrasah.'),
            _buildTermItem('2', 'Digunakan untuk presensi otomatis QR dan pencatatan transaksi tabungan siswa.'),
            _buildTermItem('3', 'Dilarang memindahtangankan, merusak, atau menggandakan QR kode pada kartu ini.'),
            _buildTermItem('4', 'Apabila kartu hilang, segera lapor ke bagian Tata Usaha SDIT Manbaul Hikmah.'),

            const SizedBox(height: 14),
            Divider(color: Colors.white.withOpacity(0.15), height: 1),
            const SizedBox(height: 12),

            // Kepala Sekolah Signature & Digital Stamp
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Alamat Lembaga:', style: TextStyle(color: Colors.white54, fontSize: 8.5)),
                    Text('Karang Satria, Tambun Utara', style: TextStyle(color: Colors.white70, fontSize: 9)),
                    Text('WA TU: 0812-9876-5432', style: TextStyle(color: Color(0xFFFDE68A), fontSize: 9, fontWeight: FontWeight.w600)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text('Bekasi, 15 Juli 2026', style: TextStyle(color: Colors.white70, fontSize: 8.5)),
                    const Text('Kepala Sekolah,', style: TextStyle(color: Colors.white70, fontSize: 8.5)),
                    const SizedBox(height: 6),
                    // Stempel Digital Emblem
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFF59E0B), width: 1.2),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white.withOpacity(0.08),
                      ),
                      child: const Column(
                        children: [
                          Text('TERVERIFIKASI', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Color(0xFFFDE68A))),
                          Text('SDIT MANBAUL HIKMAH', style: TextStyle(fontSize: 6.5, color: Colors.white70)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'KH. Ahmad Syafei, M.Pd.',
                      style: TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBioRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          SizedBox(
            width: 58,
            child: Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
          ),
          const Text(': ', style: TextStyle(color: Colors.white54, fontSize: 10)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermItem(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: const BoxDecoration(
              color: Color(0xFFF59E0B),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(number, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF064E3B))),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white70, fontSize: 9.5, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }
}
