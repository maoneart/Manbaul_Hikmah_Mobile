import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/student.dart';
import '../../providers/school_provider.dart';
import 'student_nametag_screen.dart';
import 'student_detail_screen.dart';

class StudentListScreen extends StatefulWidget {
  const StudentListScreen({super.key});

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _selectedClassFilter = 'Semua';
  String _selectedStatusFilter = 'Semua';

  final List<String> _classList = [
    'Semua',
    'Kelas 1A',
    'Kelas 1B',
    'Kelas 1C',
    'Kelas 2A',
    'Kelas 2B',
    'Kelas 2C',
    'Kelas 3A',
    'Kelas 3B',
    'Kelas 3C',
    'Kelas 4A',
    'Kelas 4B',
    'Kelas 4C',
    'Kelas 5A',
    'Kelas 5B',
    'Kelas 5C',
    'Kelas 6A',
    'Kelas 6B',
    'Kelas 6C',
    'Kelas 7A',
    'Kelas 7B',
    'Kelas 8A',
    'Kelas 9A',
  ];

  final List<String> _statusList = [
    'Semua',
    'Aktif',
    'Lulus',
    'Pindah',
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SchoolProvider>(context);

    // Apply Real-time Search, Class Filter, and Status Filter
    final query = _searchCtrl.text.toLowerCase().trim();
    final filteredStudents = provider.allStudents.where((s) {
      final matchClass = (_selectedClassFilter == 'Semua') || (s.className == _selectedClassFilter);
      final matchStatus = (_selectedStatusFilter == 'Semua') || (s.status == _selectedStatusFilter);
      final matchQuery = query.isEmpty ||
          s.name.toLowerCase().contains(query) ||
          s.nisn.toLowerCase().contains(query) ||
          s.parentName.toLowerCase().contains(query) ||
          s.address.toLowerCase().contains(query);
      return matchClass && matchStatus && matchQuery;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        title: const Text(
          'Data Master Siswa',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1C1C1E),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.chevron_back, color: Color(0xFF1C1C1E), size: 28),
          tooltip: 'Kembali',
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync_rounded, color: Color(0xFF00B14F)),
            tooltip: 'Segarkan Data dari Server',
            onPressed: () {
              provider.loadDataFromApi();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Menyinkronkan data siswa dengan server...'),
                  duration: Duration(seconds: 1),
                  backgroundColor: Color(0xFF00B14F),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // ==========================================
          // 1. TOP ACTION TOOLBAR (EXCEL & CRUD)
          // ==========================================
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            color: Colors.white,
            child: Column(
              children: [
                // 4 Action Buttons Row
                Row(
                  children: [
                    // Download Template
                    Expanded(
                      child: _buildActionPill(
                        icon: Icons.file_download_rounded,
                        label: 'Template',
                        color: const Color(0xFF007AFF),
                        onTap: () => _handleDownloadTemplate(context, provider),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Export Excel
                    Expanded(
                      child: _buildActionPill(
                        icon: Icons.ios_share_rounded,
                        label: 'Export',
                        color: const Color(0xFF34C759),
                        onTap: () => _handleExportData(context, provider),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Import Excel
                    Expanded(
                      child: _buildActionPill(
                        icon: Icons.upload_file_rounded,
                        label: 'Import',
                        color: const Color(0xFF00C7BE),
                        onTap: () => _handleImportData(context, provider),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Add Student (if permitted)
                    if (provider.canAddStudent)
                      Expanded(
                        child: _buildActionPill(
                          icon: Icons.person_add_alt_1_rounded,
                          label: 'Tambah',
                          color: const Color(0xFF00B14F),
                          onTap: () => _showAddStudentModal(context, provider),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 12),

                // Search Bar
                Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F2F7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Cari nama, NISN, atau wali...',
                      hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                      prefixIcon: const Icon(Icons.search_rounded, size: 20, color: Color(0xFF8E8E93)),
                      suffixIcon: _searchCtrl.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.cancel_rounded, size: 18, color: Color(0xFF8E8E93)),
                              onPressed: () {
                                _searchCtrl.clear();
                                setState(() {});
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Horizontal Class Chips
                SizedBox(
                  height: 32,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: _classList.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 6),
                    itemBuilder: (context, idx) {
                      final c = _classList[idx];
                      final isSelected = c == _selectedClassFilter;
                      return InkWell(
                        onTap: () => setState(() => _selectedClassFilter = c),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF00B14F) : const Color(0xFFF2F2F7),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            c,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected ? Colors.white : const Color(0xFF3C3C43),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 8),

                // Horizontal Status Filter Chips (Semua, Aktif, Lulus, Pindah)
                SizedBox(
                  height: 28,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: _statusList.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 6),
                    itemBuilder: (context, idx) {
                      final st = _statusList[idx];
                      final isSelected = st == _selectedStatusFilter;
                      return InkWell(
                        onTap: () => setState(() => _selectedStatusFilter = st),
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF007AFF) : const Color(0xFFF2F2F7),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            st == 'Semua' ? 'Semua Status' : 'Status: $st',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected ? Colors.white : const Color(0xFF3C3C43),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Total Count Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'DAFTAR SISWA (${filteredStudents.length} SISWA)',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8E8E93),
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  _selectedClassFilter,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00B14F),
                  ),
                ),
              ],
            ),
          ),

          // ==========================================
          // 2. STUDENT LIST CARDS (FULL CRUD READY)
          // ==========================================
          Expanded(
            child: filteredStudents.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_outline_rounded, size: 54, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text(
                          'Tidak ada data siswa ditemukan',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Coba ganti filter kelas atau kata kunci pencarian.',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    physics: const BouncingScrollPhysics(),
                    itemCount: filteredStudents.length,
                    itemBuilder: (context, idx) {
                      final s = filteredStudents[idx];
                      return _buildStudentCard(context, provider, s);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionPill({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentCard(BuildContext context, SchoolProvider provider, Student s) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            // Student Profile Row (Tap to open full Detail)
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => StudentDetailScreen(student: s)),
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gender Avatar
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: s.gender == 'L'
                          ? [const Color(0xFF007AFF), const Color(0xFF0051A8)]
                          : [const Color(0xFFFF2D55), const Color(0xFFCC1F40)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      s.name.isNotEmpty ? s.name[0].toUpperCase() : 'S',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Name & Metadata
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              s.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Color(0xFF1C1C1E),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          // Class Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00B14F).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              s.className,
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF008A3D),
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          // Status Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: (s.status == 'Lulus'
                                      ? const Color(0xFF007AFF)
                                      : (s.status == 'Pindah'
                                          ? const Color(0xFFFF9500)
                                          : const Color(0xFF34C759)))
                                  .withOpacity(0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              s.status,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: s.status == 'Lulus'
                                    ? const Color(0xFF007AFF)
                                    : (s.status == 'Pindah'
                                        ? const Color(0xFFD97706)
                                        : const Color(0xFF248A3D)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'NISN: ${s.nisn} • ${s.gender == "L" ? "Laki-laki" : "Perempuan"} • Masuk: ${s.entryYear}',
                        style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined, size: 13, color: Colors.grey.shade500),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              s.address,
                              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.people_outline_rounded, size: 13, color: Colors.grey.shade500),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${s.parentName} (${s.parentPhone})',
                              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

            const SizedBox(height: 12),
            Divider(height: 1, color: Colors.grey.shade100),
            const SizedBox(height: 10),

            // Bottom Actions: Balance, Name Tag, Edit, Delete
            Row(
              children: [
                // Saldo Tabungan Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF9500).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.account_balance_wallet_rounded, size: 14, color: Color(0xFFD97706)),
                      const SizedBox(width: 4),
                      Text(
                        'Rp ${s.balance.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFB45309),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // 1. Detail Buku Induk
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => StudentDetailScreen(student: s)),
                    );
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF007AFF).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.badge_outlined, size: 14, color: Color(0xFF007AFF)),
                        SizedBox(width: 4),
                        Text('Detail', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF007AFF))),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 5),

                // 2. Pindah Kelas (Promosi)
                if (provider.canEditStudent) ...[
                  InkWell(
                    onTap: () => _showPromoteClassModal(context, provider, s),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00B14F).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.swap_horiz_rounded, size: 14, color: Color(0xFF008A3D)),
                          SizedBox(width: 4),
                          Text('Pindah', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF008A3D))),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                ],

                // 3. Cetak Name Tag (Purple)
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => StudentNametagScreen(student: s)),
                    );
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFAF52DE).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.qr_code_rounded, size: 14, color: Color(0xFFAF52DE)),
                        SizedBox(width: 4),
                        Text(
                          'QR',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFAF52DE)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 5),

                // 4. Edit Siswa (Amber/Blue)
                if (provider.canEditStudent) ...[
                  InkWell(
                    onTap: () => _showEditStudentModal(context, provider, s),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF9500).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.edit_rounded, size: 14, color: Color(0xFFD97706)),
                          SizedBox(width: 4),
                          Text(
                            'Edit',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFD97706)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                ],

                // 5. Delete Siswa (Red) - With MaoneArt Glassmorphism Confirmation Modal
                if (provider.canDeleteStudent)
                  InkWell(
                    onTap: () => _showDeleteStudentModal(context, provider, s),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF2D55).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.delete_outline_rounded, size: 14, color: Color(0xFFFF2D55)),
                          SizedBox(width: 4),
                          Text(
                            'Hapus',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFFF2D55)),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // MODAL: DOWNLOAD TEMPLATE EXCEL (.xlsx)
  // ==========================================
  Future<void> _handleDownloadTemplate(BuildContext context, SchoolProvider provider) async {
    final res = await provider.saveStudentTemplateToDownloads();
    final filePath = res['path'] ?? '/sdcard/Download/Template_Import_Siswa_Manbaul_Hikmah.xlsx';

    if (!context.mounted) return;

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
                color: const Color(0xFF107C41).withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.file_download_done_rounded, color: Color(0xFF107C41), size: 28),
            ),
            const SizedBox(height: 16),
            const Text(
              'Unduh Template Excel (.xlsx)',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1C1C1E)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Berkas template Excel telah berhasil diunduh dan tersimpan ke memori perangkat:',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600, height: 1.4),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.table_chart_rounded, size: 16, color: Color(0xFF107C41)),
                      const SizedBox(width: 6),
                      Text(
                        'Format: Microsoft Excel (.xlsx)',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '📂 $filePath',
                    style: const TextStyle(fontSize: 11, fontFamily: 'monospace', color: Color(0xFF007AFF)),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Buka dan isi dengan Excel atau WPS Office, kemudian impor kembali pada menu Impor.',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                ],
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
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    child: Text('Tutup', style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await provider.saveStudentTemplateToDownloads();
                      if (!ctx.mounted) return;
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Template .xlsx berhasil diunduh ulang ke /sdcard/Download'),
                          backgroundColor: Color(0xFF00B14F),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF107C41),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text('Unduh Ulang', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // MODAL: EXPORT DATA SISWA (EXCEL .xlsx)
  // ==========================================
  Future<void> _handleExportData(BuildContext context, SchoolProvider provider) async {
    final res = await provider.saveStudentsExportToDownloads();
    final filePath = res['path'] ?? '/sdcard/Download/Data_Siswa_Manbaul_Hikmah.xlsx';

    if (!context.mounted) return;

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
                color: const Color(0xFF34C759).withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.table_view_rounded, color: Color(0xFF34C759), size: 28),
            ),
            const SizedBox(height: 16),
            const Text(
              'Export Berkas Excel (.xlsx)',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1C1C1E)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Sebanyak ${provider.allStudents.length} data siswa berhasil diekspor ke berkas Excel (.xlsx) di folder Download:',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600, height: 1.4),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.check_circle_rounded, size: 16, color: Color(0xFF34C759)),
                      const SizedBox(width: 6),
                      Text(
                        'Total Data: ${provider.allStudents.length} Siswa',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '📂 $filePath',
                    style: const TextStyle(fontSize: 11, fontFamily: 'monospace', color: Color(0xFF007AFF)),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Berkas dapat langsung dibuka di Microsoft Excel, WPS Office, atau Google Drive.',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                ],
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
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    child: Text('Tutup', style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await provider.saveStudentsExportToDownloads();
                      if (!ctx.mounted) return;
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Data siswa diekspor ulang ke /sdcard/Download'),
                          backgroundColor: Color(0xFF00B14F),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF34C759),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text('Export Lagi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // MODAL: IMPORT DATA SISWA DARI FILE EXCEL (.xlsx)
  // ==========================================
  void _handleImportData(BuildContext context, SchoolProvider provider) {
    final fileCtrl = TextEditingController(text: '/sdcard/Download/Template_Import_Siswa_Manbaul_Hikmah.xlsx');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF00C7BE).withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.file_upload_rounded, color: Color(0xFF00C7BE), size: 22),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Import Berkas Excel (.xlsx)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Masukkan lokasi berkas Excel (.xlsx) di perangkat untuk diimpor secara otomatis:',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600, height: 1.4),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F2F7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lokasi File Excel:',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: fileCtrl,
                        style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          hintText: '/sdcard/Download/Template_Import_Siswa_Manbaul_Hikmah.xlsx',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          InkWell(
                            onTap: () {
                              setModalState(() {
                                fileCtrl.text = '/sdcard/Download/Template_Import_Siswa_Manbaul_Hikmah.xlsx';
                              });
                            },
                            child: const Text(
                              'Gunakan File Template',
                              style: TextStyle(fontSize: 11, color: Color(0xFF007AFF), fontWeight: FontWeight.w600),
                            ),
                          ),
                          const SizedBox(width: 12),
                          InkWell(
                            onTap: () {
                              setModalState(() {
                                fileCtrl.text = '/sdcard/Download/Data_Siswa_Manbaul_Hikmah.xlsx';
                              });
                            },
                            child: const Text(
                              'Gunakan File Export',
                              style: TextStyle(fontSize: 11, color: Color(0xFF007AFF), fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '💡 Sistem membaca baris kolom: nisn, nama, jenis_kelamin, kelas, nama_wali, no_hp_wali, saldo_awal.',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600, height: 1.3),
                ),
              ],
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          actions: [
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
                    onPressed: () async {
                      final path = fileCtrl.text.trim();
                      if (path.isEmpty) return;
                      Navigator.pop(ctx);
                      
                      final result = await provider.importStudentsFromFile(path);
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(result['message'] ?? 'Proses impor selesai'),
                          backgroundColor: result['success'] == true ? const Color(0xFF00B14F) : const Color(0xFFFF2D55),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00C7BE),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text('Impor Excel', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // MODAL: CREATE STUDENT (TAMBAH SISWA)
  // ==========================================
  void _showAddStudentModal(BuildContext context, SchoolProvider provider) {
    final nisnCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    final entryYearCtrl = TextEditingController(text: '2024');
    final parentNameCtrl = TextEditingController();
    final parentPhoneCtrl = TextEditingController();
    String selectedGender = 'L';
    String selectedStatus = 'Aktif';
    final availableClasses = _classList.where((c) => c != 'Semua').toList();
    String selectedClass = availableClasses.contains(provider.activeClass) ? provider.activeClass : 'Kelas 1A';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          title: const Text(
            'Tambah Siswa / Siswa',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nisnCtrl,
                  decoration: const InputDecoration(
                    labelText: 'NISN / Nomor Induk Siswa',
                    hintText: 'Contoh: 0081234569',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Nama Lengkap Siswa'),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Jenis Kelamin: ', style: TextStyle(fontSize: 13)),
                    Radio<String>(
                      value: 'L',
                      groupValue: selectedGender,
                      activeColor: const Color(0xFF007AFF),
                      onChanged: (val) => setModalState(() => selectedGender = val!),
                    ),
                    const Text('L', style: TextStyle(fontSize: 13)),
                    Radio<String>(
                      value: 'P',
                      groupValue: selectedGender,
                      activeColor: const Color(0xFFFF2D55),
                      onChanged: (val) => setModalState(() => selectedGender = val!),
                    ),
                    const Text('P', style: TextStyle(fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: availableClasses.contains(selectedClass) ? selectedClass : availableClasses.first,
                  decoration: const InputDecoration(labelText: 'Kelas Saat Ini'),
                  items: availableClasses
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (val) => setModalState(() => selectedClass = val!),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: entryYearCtrl,
                        decoration: const InputDecoration(labelText: 'Tahun Masuk / Angkatan'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedStatus,
                        decoration: const InputDecoration(labelText: 'Status'),
                        items: ['Aktif', 'Lulus', 'Pindah']
                            .map((st) => DropdownMenuItem(value: st, child: Text(st)))
                            .toList(),
                        onChanged: (val) => setModalState(() => selectedStatus = val!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: addressCtrl,
                  decoration: const InputDecoration(labelText: 'Alamat Tinggal Siswa'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: parentNameCtrl,
                  decoration: const InputDecoration(labelText: 'Nama Wali Murid'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: parentPhoneCtrl,
                  decoration: const InputDecoration(labelText: 'No. HP / WhatsApp Wali'),
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          actions: [
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
                      if (nisnCtrl.text.isNotEmpty && nameCtrl.text.isNotEmpty) {
                        provider.addStudent(
                          nisnCtrl.text.trim(),
                          nameCtrl.text.trim(),
                          selectedGender,
                          selectedClass,
                          parentNameCtrl.text.trim(),
                          parentPhoneCtrl.text.trim(),
                          address: addressCtrl.text.trim(),
                          entryYear: entryYearCtrl.text.trim(),
                          status: selectedStatus,
                        );
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Siswa baru berhasil didaftarkan dan disinkronkan ke server!'),
                            backgroundColor: Color(0xFF00B14F),
                          ),
                        );
                      }
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
      ),
    );
  }

  // ==========================================
  // MODAL: UPDATE STUDENT (EDIT SISWA & NAIK KELAS)
  // ==========================================
  void _showEditStudentModal(BuildContext context, SchoolProvider provider, Student s) {
    final nameCtrl = TextEditingController(text: s.name);
    final addressCtrl = TextEditingController(text: s.address == '-' ? '' : s.address);
    final entryYearCtrl = TextEditingController(text: s.entryYear);
    final parentNameCtrl = TextEditingController(text: s.parentName);
    final parentPhoneCtrl = TextEditingController(text: s.parentPhone);
    String selectedGender = s.gender;
    final availableClasses = _classList.where((c) => c != 'Semua').toList();
    String selectedClass = availableClasses.contains(s.className) ? s.className : availableClasses.first;
    String selectedStatus = ['Aktif', 'Lulus', 'Pindah'].contains(s.status) ? s.status : 'Aktif';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          title: Text(
            'Edit / Kenaikan Kelas: ${s.name}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // NISN Readonly Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F2F7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.tag_rounded, size: 16, color: Color(0xFF8E8E93)),
                      const SizedBox(width: 8),
                      Text('NISN: ${s.nisn} (Terkunci)', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Nama Lengkap Siswa'),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Jenis Kelamin: ', style: TextStyle(fontSize: 13)),
                    Radio<String>(
                      value: 'L',
                      groupValue: selectedGender,
                      activeColor: const Color(0xFF007AFF),
                      onChanged: (val) => setModalState(() => selectedGender = val!),
                    ),
                    const Text('L', style: TextStyle(fontSize: 13)),
                    Radio<String>(
                      value: 'P',
                      groupValue: selectedGender,
                      activeColor: const Color(0xFFFF2D55),
                      onChanged: (val) => setModalState(() => selectedGender = val!),
                    ),
                    const Text('P', style: TextStyle(fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: availableClasses.contains(selectedClass) ? selectedClass : availableClasses.first,
                  decoration: const InputDecoration(labelText: 'Kelas / Naik Kelas Ke'),
                  items: availableClasses
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (val) => setModalState(() => selectedClass = val!),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: entryYearCtrl,
                        decoration: const InputDecoration(labelText: 'Tahun Masuk'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedStatus,
                        decoration: const InputDecoration(labelText: 'Status Kesiswaan'),
                        items: ['Aktif', 'Lulus', 'Pindah']
                            .map((st) => DropdownMenuItem(value: st, child: Text(st)))
                            .toList(),
                        onChanged: (val) => setModalState(() => selectedStatus = val!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: addressCtrl,
                  decoration: const InputDecoration(labelText: 'Alamat Tinggal Siswa'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: parentNameCtrl,
                  decoration: const InputDecoration(labelText: 'Nama Wali Murid'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: parentPhoneCtrl,
                  decoration: const InputDecoration(labelText: 'No. HP / WhatsApp Wali'),
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          actions: [
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
                    onPressed: () async {
                      if (nameCtrl.text.trim().isNotEmpty) {
                        await provider.updateStudent(
                          id: s.id,
                          name: nameCtrl.text.trim(),
                          gender: selectedGender,
                          className: selectedClass,
                          parentName: parentNameCtrl.text.trim(),
                          parentPhone: parentPhoneCtrl.text.trim(),
                          address: addressCtrl.text.trim(),
                          entryYear: entryYearCtrl.text.trim(),
                          status: selectedStatus,
                        );
                        if (!ctx.mounted) return;
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Perubahan data siswa & kenaikan kelas berhasil disimpan!'),
                            backgroundColor: Color(0xFF00B14F),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF007AFF),
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
      ),
    );
  }

  // ==========================================
  // MODAL: DELETE STUDENT (MAONEART GLASSMORPHISM MODAL)
  // ==========================================
  void _showDeleteStudentModal(BuildContext context, SchoolProvider provider, Student s) {
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
                color: const Color(0xFFFF2D55).withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.delete_forever_rounded, color: Color(0xFFFF2D55), size: 28),
            ),
            const SizedBox(height: 16),
            const Text(
              'Hapus Data Siswa?',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1C1C1E)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Apakah Anda yakin ingin menghapus siswa "${s.name}" (NISN: ${s.nisn}) dari sistem database?\n\nSemua riwayat presensi dan tabungan siswa ini juga akan dihapus. Tindakan ini tidak dapat dibatalkan.',
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
                    onPressed: () async {
                      await provider.deleteStudent(s.id);
                      if (!ctx.mounted) return;
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Siswa ${s.name} berhasil dihapus dari sistem.'),
                          backgroundColor: const Color(0xFFFF2D55),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF2D55),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text('Ya, Hapus', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showPromoteClassModal(BuildContext context, SchoolProvider provider, Student s) {
    String targetClass = s.className;

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
                        'Kelas Saat Ini: ${s.className}',
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
                    items: _classList.where((c) => c != 'Semua').map((cls) => DropdownMenuItem(value: cls, child: Text(cls))).toList(),
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
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(success
                                  ? 'Kelas ${s.name} berhasil dipindahkan ke $targetClass'
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
}
