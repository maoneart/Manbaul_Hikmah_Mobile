import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/school_provider.dart';
import '../../theme/app_theme.dart';
import '../../models/student.dart';

class SavingsScreen extends StatefulWidget {
  final VoidCallback? onNavigateHome;
  const SavingsScreen({super.key, this.onNavigateHome});

  @override
  State<SavingsScreen> createState() => _SavingsScreenState();
}

class _SavingsScreenState extends State<SavingsScreen> {
  String _selectedClassFilter = 'Semua Kelas';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SchoolProvider>(context);
    final role = provider.currentRole;
    final isWaliMurid = role == 'wali_murid';
    final isAdminOrKepsek = role == 'admin' || role == 'kepsek';
    final myChild = provider.myChildStudent;

    // Staff TU tidak memiliki akses tabungan siswa (dikelola khusus Wali Kelas)
    if (role == 'staff') {
      return Scaffold(
        backgroundColor: const Color(0xFFF2F4F7),
        appBar: AppBar(
          leading: (Navigator.canPop(context) || widget.onNavigateHome != null)
              ? IconButton(
                  icon: const Icon(CupertinoIcons.chevron_back, color: Colors.white, size: 28),
                  tooltip: 'Kembali',
                  onPressed: () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    } else if (widget.onNavigateHome != null) {
                      widget.onNavigateHome!();
                    }
                  },
                )
              : null,
          title: const Text('Buku Tabungan Siswa', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          backgroundColor: const Color(0xFF00B14F),
          elevation: 0,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_outline_rounded, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                const Text(
                  'Kewenangan Khusus Wali Kelas',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1C1C1E)),
                ),
                const SizedBox(height: 8),
                Text(
                  'Pencatatan dan mutasi tabungan siswa dikelola langsung oleh masing-masing Wali Kelas.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (!isAdminOrKepsek && _selectedClassFilter == 'Semua Kelas') {
      _selectedClassFilter = provider.activeClass;
    }

    final classOptions = ['Semua Kelas', ...provider.classes.map((c) => c.name)];

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      appBar: AppBar(
        leading: (Navigator.canPop(context) || widget.onNavigateHome != null)
            ? IconButton(
                icon: const Icon(CupertinoIcons.chevron_back, color: Colors.white, size: 28),
                tooltip: 'Kembali',
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  } else if (widget.onNavigateHome != null) {
                    widget.onNavigateHome!();
                  }
                },
              )
            : null,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isWaliMurid ? 'Buku Tabungan Siswa' : 'Buku Tabungan Siswa',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            Text(
              isWaliMurid
                  ? 'Akun Siswa: ${myChild?.name ?? "Siswa Binaan"}'
                  : (isAdminOrKepsek
                      ? 'Monitoring Global • ${_selectedClassFilter}'
                      : 'Kelas Binaan: ${provider.activeClass}'),
              style: const TextStyle(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF00B14F),
        elevation: 0,
        actions: [
          if (isAdminOrKepsek)
            PopupMenuButton<String>(
              icon: const Icon(Icons.filter_list_rounded, color: Colors.white),
              tooltip: 'Pilih Rombel / Semua Kelas',
              onSelected: (val) {
                setState(() => _selectedClassFilter = val);
              },
              itemBuilder: (ctx) {
                return classOptions.map((cls) {
                  return PopupMenuItem(
                    value: cls,
                    child: Text(
                      cls,
                      style: TextStyle(fontWeight: _selectedClassFilter == cls ? FontWeight.bold : FontWeight.normal),
                    ),
                  );
                }).toList();
              },
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: isWaliMurid
            ? _buildWaliMuridSavingsView(context, provider, myChild)
            : _buildTeacherAdminSavingsView(context, provider, isAdminOrKepsek),
      ),
    );
  }

  // ==========================================
  // VIEW KHUSUS WALI MURID (HANYA TABUNGAN ANAKNYA)
  // ==========================================
  Widget _buildWaliMuridSavingsView(BuildContext context, SchoolProvider provider, Student? myChild) {
    if (myChild == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 40),
          child: Column(
            children: [
              Icon(Icons.person_off_rounded, size: 60, color: Colors.grey.shade400),
              const SizedBox(height: 12),
              const Text(
                'Data siswa tidak ditemukan',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 6),
              Text(
                'Akun wali murid belum terhubung dengan data siswa. Silakan hubungi Tata Usaha.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    final trans = provider.getStudentTransactions(myChild.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Multi-Child Switcher bila anak > 1
        if (provider.myChildren.length > 1) ...[
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
              ],
            ),
            child: Row(
              children: provider.myChildren.map((ch) {
                final isSelected = ch.id == myChild.id;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => provider.selectChild(ch.id),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF00B14F) : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            ch.gender == 'L' ? Icons.face_rounded : Icons.face_3_rounded,
                            size: 14,
                            color: isSelected ? Colors.white : Colors.grey.shade700,
                          ),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              ch.name.split(' ').first,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.grey.shade800,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 14),
        ],

        // Kartu Saldo Tabungan Anak
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF92400E), Color(0xFFD97706), Color(0xFFF59E0B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD97706).withOpacity(0.35),
                blurRadius: 12,
                offset: const Offset(0, 5),
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
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'TABUNGAN: ${myChild.className}',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                    ),
                  ),
                  const Text('EduPay Siswa', style: TextStyle(color: Colors.white70, fontSize: 11)),
                ],
              ),
              const SizedBox(height: 14),
              const Text('Saldo Kas Siswa Saat Ini:', style: TextStyle(color: Colors.white70, fontSize: 12)),
              const SizedBox(height: 4),
              Text(
                'Rp ${myChild.balance.toStringAsFixed(0).replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]}.")}',
                style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900),
              ),
              const Divider(color: Colors.white24, height: 24),
              Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: Colors.white70, size: 14),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Setor tunai atau penarikan uang saku dilayani melalui Loket Tata Usaha Sekolah.',
                      style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 11),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Section Riwayat Mutasi Transaksi Anak
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Riwayat Mutasi Tabungan',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1C1C1E)),
            ),
            Text(
              '${trans.length} Transaksi',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        const SizedBox(height: 10),

        if (trans.isEmpty)
          Container(
            padding: const EdgeInsets.all(28),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(Icons.receipt_long_outlined, size: 44, color: Colors.grey.shade400),
                const SizedBox(height: 10),
                const Text(
                  'Belum ada transaksi tabungan',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1C1C1E)),
                ),
                const SizedBox(height: 4),
                Text(
                  'Catatan setoran atau penarikan uang saku akan muncul di sini secara otomatis.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
              ],
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: trans.length,
            itemBuilder: (context, idx) {
              final t = trans[idx];
              final isSetor = t.type.toLowerCase() == 'setor';

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isSetor ? const Color(0xFF00B14F).withOpacity(0.12) : const Color(0xFFFF3B30).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isSetor ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                        color: isSetor ? const Color(0xFF008A3D) : const Color(0xFFFF3B30),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isSetor ? 'Setor Tabungan' : 'Tarik Uang Saku',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1C1C1E)),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${t.notes.isNotEmpty ? t.notes : (isSetor ? "Setor tunai" : "Penarikan uang saku")} • ${t.date}',
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${isSetor ? "+" : "-"}Rp ${t.amount.toStringAsFixed(0).replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]}.")}',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: isSetor ? const Color(0xFF008A3D) : const Color(0xFFFF3B30),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  // ==========================================
  // VIEW GURU / WALI KELAS / STAFF TU / KEPSEK
  // ==========================================
  Widget _buildTeacherAdminSavingsView(
    BuildContext context,
    SchoolProvider provider,
    bool isAdminOrKepsek,
  ) {
    // List siswa yang ditampilkan berdasarkan filter kelas
    final List<Student> targetStudents = isAdminOrKepsek
        ? (_selectedClassFilter == 'Semua Kelas'
            ? provider.allStudents
            : provider.allStudents.where((s) => s.className == _selectedClassFilter).toList())
        : provider.students;

    final displayedStudents = targetStudents.where((s) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return s.name.toLowerCase().contains(q) || s.nisn.contains(q);
    }).toList();

    // Hitung total saldo yang ditampilkan
    final double displayedTotalSavings = isAdminOrKepsek && _selectedClassFilter == 'Semua Kelas'
        ? provider.totalAllSavings
        : targetStudents.fold(0.0, (sum, s) => sum + s.balance);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Total Savings Card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFFB45309), Color(0xFFD97706)]),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(color: Colors.amber.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isAdminOrKepsek && _selectedClassFilter == 'Semua Kelas'
                        ? 'Total Kas Tabungan Seluruh Siswa'
                        : 'Total Saldo Rombel $_selectedClassFilter',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(8)),
                    child: Text(
                      '${targetStudents.length} Siswa',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Rp ${displayedTotalSavings.toStringAsFixed(0).replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]}.")}',
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
              ),
              const Divider(color: Colors.white24, height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showTransactionDialog(context, provider, 'setor', targetStudents),
                      icon: const Icon(Icons.arrow_downward, size: 16),
                      label: const Text('+ Setor Kasir', style: TextStyle(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.green.shade800,
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showTransactionDialog(context, provider, 'tarik', targetStudents),
                      icon: const Icon(Icons.arrow_upward, size: 16),
                      label: const Text('- Tarik Uang Saku', style: TextStyle(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.2),
                        foregroundColor: Colors.white,
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Search Bar Siswa
        Container(
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6, offset: const Offset(0, 2)),
            ],
          ),
          child: TextField(
            onChanged: (v) => setState(() => _searchQuery = v),
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Cari siswa berdasarkan nama / NISN...',
              hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13),
              prefixIcon: const Icon(Icons.search_rounded, size: 18, color: Colors.grey),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Students Savings Balance List
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Buku Tabungan Siswa',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textDark),
            ),
            Text(
              '${displayedStudents.length} Siswa',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
        const SizedBox(height: 10),

        displayedStudents.isEmpty
            ? Container(
                padding: const EdgeInsets.all(24),
                width: double.infinity,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                child: const Text('Tidak ada data siswa yang cocok.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.grey)),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: displayedStudents.length,
                itemBuilder: (context, idx) {
                  final s = displayedStudents[idx];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.amber.shade100,
                        child: Text(s.name.isNotEmpty ? s.name[0] : 'S', style: TextStyle(color: Colors.amber.shade900, fontWeight: FontWeight.bold)),
                      ),
                      title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      subtitle: Text('${s.className} • NISN: ${s.nisn}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Rp ${s.balance.toStringAsFixed(0).replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]}.")}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textDark),
                          ),
                          GestureDetector(
                            onTap: () => _showPassbookDialog(context, provider, s),
                            child: const Text('Buku Mutasi >', style: TextStyle(fontSize: 10, color: Colors.amber, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ],
    );
  }

  void _showTransactionDialog(
    BuildContext context,
    SchoolProvider provider,
    String type,
    List<Student> studentCandidates,
  ) {
    final pool = studentCandidates.isNotEmpty ? studentCandidates : provider.allStudents;
    if (pool.isEmpty) return;

    int selectedStudentId = pool.first.id;
    final amountCtrl = TextEditingController();
    final notesCtrl = TextEditingController(text: type == 'setor' ? 'Setoran tunai di loket TU' : 'Penarikan uang saku siswa');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            type == 'setor' ? 'Setor Kasir Tabungan Siswa' : 'Tarik Uang Saku Siswa',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  value: selectedStudentId,
                  decoration: const InputDecoration(labelText: 'Pilih Siswa / Murid'),
                  isExpanded: true,
                  items: pool.map((s) => DropdownMenuItem(
                    value: s.id,
                    child: Text('${s.name} (${s.className})', style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis),
                  )).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => selectedStudentId = val);
                  },
                ),
                TextField(
                  controller: amountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Nominal (Rp)', hintText: 'Contoh: 50000'),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [10000, 20000, 50000, 100000].map((nominal) => ActionChip(
                    label: Text('${(nominal / 1000).toStringAsFixed(0)}rb', style: const TextStyle(fontSize: 10)),
                    onPressed: () => amountCtrl.text = nominal.toString(),
                  )).toList(),
                ),
                TextField(controller: notesCtrl, decoration: const InputDecoration(labelText: 'Catatan Transaksi')),
              ],
            ),
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    child: const Text('Batal'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final amount = double.tryParse(amountCtrl.text) ?? 0;
                      if (amount > 0) {
                        final ok = provider.recordSavings(selectedStudentId, type, amount, notesCtrl.text.trim());
                        Navigator.pop(ctx);
                        if (ok) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Transaksi ${type.toUpperCase()} Rp ${amount.toStringAsFixed(0)} berhasil diproses!'),
                              backgroundColor: const Color(0xFF00B14F),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Gagal! Saldo siswa tidak mencukupi untuk ditarik.'),
                              backgroundColor: Color(0xFFFF3B30),
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: type == 'setor' ? const Color(0xFF00B14F) : const Color(0xFFFF3B30),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Simpan'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showPassbookDialog(BuildContext context, SchoolProvider provider, Student student) {
    final trans = provider.getStudentTransactions(student.id);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Buku Mutasi: ${student.name}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            Text(
              '${student.className} • Saldo: Rp ${student.balance.toStringAsFixed(0).replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]}.")}',
              style: const TextStyle(fontSize: 12, color: Color(0xFF008A3D), fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: trans.isEmpty
              ? const Center(child: Text('Belum ada riwayat transaksi', style: TextStyle(color: Colors.grey)))
              : ListView.builder(
                  itemCount: trans.length,
                  itemBuilder: (c, i) {
                    final t = trans[i];
                    final isSetor = t.type.toLowerCase() == 'setor';
                    return ListTile(
                      dense: true,
                      leading: Icon(
                        isSetor ? Icons.arrow_downward : Icons.arrow_upward,
                        color: isSetor ? const Color(0xFF00B14F) : const Color(0xFFFF3B30),
                        size: 20,
                      ),
                      title: Text(
                        '${isSetor ? "+" : "-"}Rp ${t.amount.toStringAsFixed(0).replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]}.")}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isSetor ? const Color(0xFF008A3D) : const Color(0xFFFF3B30),
                        ),
                      ),
                      subtitle: Text('${t.notes} • ${t.date}', style: const TextStyle(fontSize: 10)),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Tutup')),
        ],
      ),
    );
  }
}
