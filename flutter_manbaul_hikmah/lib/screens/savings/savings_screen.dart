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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buku Tabungan Siswa', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.gojekGreen,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
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
                  const Text('Total Saldo Tabungan ' + 'Kelas 7A', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(
                    'Rp ' + provider.totalSavings.toStringAsFixed(0).replaceAllMapped(RegExp(r'(d{1,3})(?=(d{3})+(?!d))'), (Match m) => m[1] + '.'),
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.black),
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
                    subtitle: Text('NISN: ' + s.nisn, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Rp ' + s.balance.toStringAsFixed(0).replaceAllMapped(RegExp(r'(d{1,3})(?=(d{3})+(?!d))'), (Match m) => m[1] + '.'),
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
        ),
      ),
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
                    label: Text((nominal / 1000).toStringAsFixed(0) + 'rb', style: const TextStyle(fontSize: 10)),
                    onPressed: () => amountCtrl.text = nominal.toString(),
                  )).toList(),
                ),
                TextField(controller: notesCtrl, decoration: const InputDecoration(labelText: 'Catatan')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () {
                final amount = double.tryParse(amountCtrl.text) ?? 0;
                if (amount > 0) {
                  final ok = provider.recordSavings(selectedStudentId, type, amount, notesCtrl.text.trim());
                  Navigator.pop(ctx);
                  if (ok) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Transaksi ' + type.toUpperCase() + ' Rp ' + amount.toStringAsFixed(0) + ' berhasil!')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Gagal! Saldo siswa tidak mencukupi untuk ditarik.')),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: type == 'setor' ? AppTheme.gojekGreen : Colors.rose),
              child: const Text('Simpan Transaksi'),
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Buku Mutasi: ' + student.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            Text('Saldo: Rp ' + student.balance.toStringAsFixed(0), style: const TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.bold)),
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
                      leading: Icon(isSetor ? Icons.arrow_downward : Icons.arrow_upward, color: isSetor ? Colors.green : Colors.red, size: 20),
                      title: Text((isSetor ? '+' : '-') + 'Rp ' + t.amount.toStringAsFixed(0), style: TextStyle(fontWeight: FontWeight.bold, color: isSetor ? Colors.green : Colors.red)),
                      subtitle: Text(t.notes + ' • ' + t.date, style: const TextStyle(fontSize: 10)),
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
