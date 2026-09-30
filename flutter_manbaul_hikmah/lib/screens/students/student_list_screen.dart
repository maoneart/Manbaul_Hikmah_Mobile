import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/student.dart';
import '../../providers/school_provider.dart';
import 'student_nametag_screen.dart';

class StudentListScreen extends StatefulWidget {
  const StudentListScreen({super.key});

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _selectedClassFilter = 'Semua';

  final List<String> _classList = [
    'Semua',
    'Kelas 7A',
    'Kelas 7B',
    'Kelas 8A',
    'Kelas 9A',
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SchoolProvider>(context);

    // Apply Real-time Search and Class Filter
    final query = _searchCtrl.text.toLowerCase().trim();
    final filteredStudents = provider.allStudents.where((s) {
      final matchClass = (_selectedClassFilter == 'Semua') || (s.className == _selectedClassFilter);
      final matchQuery = query.isEmpty ||
          s.name.toLowerCase().contains(query) ||
          s.nisn.toLowerCase().contains(query) ||
          s.parentName.toLowerCase().contains(query);
      return matchClass && matchQuery;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        title: const Text(
          'Data Santri & Siswa',
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
            icon: const Icon(Icons.sync_rounded, color: Color(0xFF00B14F)),
            tooltip: 'Segarkan Data dari Server',
            onPressed: () {
              provider.loadDataFromApi();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Menyinkronkan data santri dengan server...'),
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
                  'DAFTAR SANTRI (${filteredStudents.length} SISWA)',
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
                          'Tidak ada data santri ditemukan',
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
            // Student Profile Row
            Row(
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
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00B14F).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(6),
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
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'NISN: ${s.nisn} • ${s.gender == "L" ? "Laki-laki" : "Perempuan"}',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.person_outline_rounded, size: 14, color: Colors.grey.shade500),
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

                // 1. Cetak Name Tag (Purple)
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => StudentNametagScreen(student: s)),
                    );
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFAF52DE).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.qr_code_rounded, size: 14, color: Color(0xFFAF52DE)),
                        SizedBox(width: 4),
                        Text(
                          'Name Tag',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFAF52DE)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 6),

                // 2. Edit Santri (Amber/Blue)
                if (provider.canEditStudent) ...[
                  InkWell(
                    onTap: () => _showEditStudentModal(context, provider, s),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF007AFF).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.edit_rounded, size: 14, color: Color(0xFF007AFF)),
                          SizedBox(width: 4),
                          Text(
                            'Edit',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF007AFF)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                ],

                // 3. Delete Santri (Red) - With MaoneArt Glassmorphism Confirmation Modal
                if (provider.canDeleteStudent)
                  InkWell(
                    onTap: () => _showDeleteStudentModal(context, provider, s),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
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
  // MODAL: DOWNLOAD TEMPLATE EXCEL
  // ==========================================
  Future<void> _handleDownloadTemplate(BuildContext context, SchoolProvider provider) async {
    final res = await provider.saveStudentTemplateToDownloads();
    final csv = res['csv'] ?? provider.getStudentImportTemplateCsv();
    Clipboard.setData(ClipboardData(text: csv));

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
                color: const Color(0xFF007AFF).withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.file_download_done_rounded, color: Color(0xFF007AFF), size: 28),
            ),
            const SizedBox(height: 16),
            const Text(
              'Template Excel Siap!',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1C1C1E)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Template berkas telah tersimpan di folder Download:\n'
              '📂 /sdcard/Download/Template_Import_Siswa_Manbaul_Hikmah.xlsx\n'
              '📂 /sdcard/Download/Template_Import_Siswa_Manbaul_Hikmah.csv\n\n'
              'Format tabel juga telah disalin ke Clipboard untuk langsung ditempel di Excel atau Google Sheets.',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600, height: 1.4),
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
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: csv));
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Teks template disalin ulang ke Clipboard!'),
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
                    child: const Text('Salin Lagi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
  // MODAL: EXPORT DATA SISWA (EXCEL/CSV)
  // ==========================================
  Future<void> _handleExportData(BuildContext context, SchoolProvider provider) async {
    final res = await provider.saveStudentsExportToDownloads();
    final csv = res['csv'] ?? provider.exportStudentsToCsv();
    Clipboard.setData(ClipboardData(text: csv));

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
              child: const Icon(Icons.ios_share_rounded, color: Color(0xFF34C759), size: 28),
            ),
            const SizedBox(height: 16),
            const Text(
              'Export Data Berhasil!',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1C1C1E)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Sebanyak ${provider.allStudents.length} data santri telah diekspor ke folder Download:\n'
              '📂 /sdcard/Download/Data_Siswa_Manbaul_Hikmah.xlsx\n'
              '📂 /sdcard/Download/Data_Siswa_Manbaul_Hikmah.csv\n\n'
              'Data tabel CSV juga tersalin otomatis di Clipboard Anda.',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600, height: 1.4),
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
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: csv));
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Data CSV disalin ke Clipboard!'),
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
                    child: const Text('Salin CSV', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
  // MODAL: IMPORT DATA SISWA (EXCEL/CSV)
  // ==========================================
  void _handleImportData(BuildContext context, SchoolProvider provider) {
    final csvCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          title: const Text(
            'Import Massal Data Santri',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tempelkan data santri format tabel CSV dari Excel sesuai template:',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: () async {
                        final clip = await Clipboard.getData('text/plain');
                        if (clip != null && clip.text != null) {
                          setModalState(() {
                            csvCtrl.text = clip.text!;
                          });
                        }
                      },
                      icon: const Icon(Icons.paste_rounded, size: 16),
                      label: const Text('Tempel dari Clipboard', style: TextStyle(fontSize: 11)),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        setModalState(() {
                          csvCtrl.text = provider.getStudentImportTemplateCsv();
                        });
                      },
                      child: const Text('Gunakan Contoh', style: TextStyle(fontSize: 11)),
                    ),
                  ],
                ),
                Container(
                  height: 140,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F2F7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: TextField(
                    controller: csvCtrl,
                    maxLines: null,
                    expands: true,
                    style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.all(10),
                      border: InputBorder.none,
                      hintText: 'nisn,nama,jenis_kelamin,kelas,nama_wali,no_hp_wali,saldo_awal\n0081234570,Rizky,L,Kelas 7A,Bambang,0812345678,50000',
                    ),
                  ),
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
                      if (csvCtrl.text.trim().isEmpty) return;
                      final result = await provider.importStudentsFromCsv(csvCtrl.text.trim());
                      if (!ctx.mounted) return;
                      Navigator.pop(ctx);
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
                    child: const Text('Proses Impor', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
    final parentNameCtrl = TextEditingController();
    final parentPhoneCtrl = TextEditingController();
    String selectedGender = 'L';
    String selectedClass = provider.activeClass == 'Semua' ? 'Kelas 7A' : provider.activeClass;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          title: const Text(
            'Tambah Santri / Siswa',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nisnCtrl,
                  decoration: const InputDecoration(
                    labelText: 'NISN / Nomor Induk Santri',
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
                  value: selectedClass,
                  decoration: const InputDecoration(labelText: 'Kelas'),
                  items: ['Kelas 7A', 'Kelas 7B', 'Kelas 8A', 'Kelas 9A']
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (val) => setModalState(() => selectedClass = val!),
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
  // MODAL: UPDATE STUDENT (EDIT SISWA)
  // ==========================================
  void _showEditStudentModal(BuildContext context, SchoolProvider provider, Student s) {
    final nameCtrl = TextEditingController(text: s.name);
    final parentNameCtrl = TextEditingController(text: s.parentName);
    final parentPhoneCtrl = TextEditingController(text: s.parentPhone);
    String selectedGender = s.gender;
    String selectedClass = s.className;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          title: Text(
            'Edit Data Siswa: ${s.name}',
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
                  value: ['Kelas 7A', 'Kelas 7B', 'Kelas 8A', 'Kelas 9A'].contains(selectedClass)
                      ? selectedClass
                      : 'Kelas 7A',
                  decoration: const InputDecoration(labelText: 'Kelas'),
                  items: ['Kelas 7A', 'Kelas 7B', 'Kelas 8A', 'Kelas 9A']
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (val) => setModalState(() => selectedClass = val!),
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
                        );
                        if (!ctx.mounted) return;
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Perubahan data siswa berhasil disimpan!'),
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
              'Apakah Anda yakin ingin menghapus santri "${s.name}" (NISN: ${s.nisn}) dari sistem database?\n\nSemua riwayat presensi dan tabungan santri ini juga akan dihapus. Tindakan ini tidak dapat dibatalkan.',
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
}
