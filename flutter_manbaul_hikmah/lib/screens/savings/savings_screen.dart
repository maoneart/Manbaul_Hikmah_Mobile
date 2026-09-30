import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/school_provider.dart';
import '../../theme/app_theme.dart';
import '../../models/student.dart';

class SavingsScreen extends StatelessWidget {
  const SavingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SchoolProvider>(context);
    final role = provider.currentRole;
    final isWaliMurid = role == 'wali_murid';
    final myChild = provider.myChildStudent;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isWaliMurid ? 'Buku Tabungan Santri' : 'Buku Tabungan Siswa',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            Text(
              isWaliMurid
                  ? 'Akun Siswa: ${myChild?.name ?? "Santri Binaan"}'
                  : 'Kelas: ${provider.activeClass} • ${provider.students.length} Siswa',
              style: const TextStyle(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF00B14F),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: isWaliMurid
            ? _buildWaliMuridSavingsView(context, provider, myChild)
            : _buildTeacherAdminSavingsView(context, provider),
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
                'Data santri tidak ditemukan',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 6),
              Text(
                'Akun wali murid belum terhubung dengan data santri. Silakan hubungi Tata Usaha.',
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
                    child: const Text(
                      'TABUNGAN SANTRI',
                      style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified_user_rounded, color: Colors.white, size: 12),
                        SizedBox(width: 4),
                        Text('Rekening Aktif', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                myChild.name,
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                '${myChild.className} • NISN: ${myChild.nisn}',
                style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 12),
              ),
              const Divider(color: Colors.white24, height: 24),
              const Text('Total Saldo Tersedia:', style: TextStyle(color: Colors.white70, fontSize: 11)),
              const SizedBox(height: 4),
              Text(
                'Rp ${myChild.balance.toStringAsFixed(0).replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]}.")}',
                style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: -0.5),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Info Banner Edukasi / SOP Tabungan Sekolah
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline_rounded, color: Colors.blue.shade700, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Untuk menambah setoran tabungan atau penarikan uang saku santri, silakan diserahkan melalui Wali Kelas (${myChild.className}) atau loket Tata Usaha sekolah.',
                  style: TextStyle(fontSize: 12, color: Colors.blue.shade900, height: 1.35),
                ),
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
              final isSetor = t.type == 'setor';

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
  Widget _buildTeacherAdminSavingsView(BuildContext context, SchoolProvider provider) {
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
              Text('Total Saldo Tabungan ${provider.activeClass}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
              const SizedBox(height: 4),
              Text(
                'Rp ${provider.totalSavings.toStringAsFixed(0).replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]}.")}',
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
              ),
              const Divider(color: Colors.white24, height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showTransactionDialog(context, provider, 'setor'),
                      icon: const Icon(Icons.arrow_downward, size: 16),
                      label: const Text('+ Setor', style: TextStyle(fontWeight: FontWeight.bold)),
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
                      onPressed: () => _showTransactionDialog(context, provider, 'tarik'),
                      icon: const Icon(Icons.arrow_upward, size: 16),
                      label: const Text('- Tarik', style: TextStyle(fontWeight: FontWeight.bold)),
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

        const SizedBox(height: 20),

        // Students Savings Balance List
        const Text(
          'Daftar Tabungan Santri / Siswa',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textDark),
        ),
        const SizedBox(height: 10),

        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: provider.students.length,
          itemBuilder: (context, idx) {
            final s = provider.students[idx];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.amber.shade100,
                  child: Text(s.name.isNotEmpty ? s.name[0] : 'S', style: TextStyle(color: Colors.amber.shade900, fontWeight: FontWeight.bold)),
                ),
                title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                subtitle: Text('NISN: ${s.nisn}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
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

  void _showTransactionDialog(BuildContext context, SchoolProvider provider, String type) {
    if (provider.students.isEmpty) return;
    int selectedStudentId = provider.students.first.id;
    final amountCtrl = TextEditingController();
    final notesCtrl = TextEditingController(text: type == 'setor' ? 'Setoran mingguan' : 'Penarikan uang saku');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(type == 'setor' ? 'Setor Tabungan Siswa' : 'Tarik Tabungan Siswa', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  value: selectedStudentId,
                  decoration: const InputDecoration(labelText: 'Pilih Siswa'),
                  items: provider.students.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name, style: const TextStyle(fontSize: 13)))).toList(),
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
                TextField(controller: notesCtrl, decoration: const InputDecoration(labelText: 'Catatan')),
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
                              content: Text('Transaksi ${type.toUpperCase()} Rp ${amount.toStringAsFixed(0)} berhasil!'),
                              backgroundColor: const Color(0xFF00B14F),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Gagal! Saldo santri tidak mencukupi untuk ditarik.'),
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
              'Saldo: Rp ${student.balance.toStringAsFixed(0).replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]}.")}',
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
                    final isSetor = t.type == 'setor';
                    return ListTile(
                      dense: true,
                      leading: Icon(
                        isSetor ? Icons.arrow_downward : Icons.arrow_upward,
                        color: isSetor ? const Color(0xFF008A3D) : const Color(0xFFFF3B30),
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
