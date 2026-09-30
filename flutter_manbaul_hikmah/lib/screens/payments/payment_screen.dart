import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/payment_bill.dart';
import '../../providers/school_provider.dart';
import '../../theme/app_theme.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedStatusFilter = 'Semua'; // 'Semua', 'Belum Lunas', 'Lunas'
  String _selectedClassFilter = 'Semua';

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SchoolProvider>(context);
    final role = provider.currentRole;
    final isWaliMurid = role == 'wali_murid';

    final myChild = provider.myChildStudent;
    final childId = myChild?.id ?? 1;
    final childName = myChild?.name ?? 'Santri';

    // Filter bills
    List<PaymentBill> filteredBills = provider.bills.where((b) {
      if (isWaliMurid) {
        // Only show bills for their child
        if (b.studentId != childId) return false;
      } else if (_selectedClassFilter != 'Semua' && b.className != _selectedClassFilter) {
        return false;
      }

      if (_selectedStatusFilter == 'Belum Lunas' && b.status != 'Belum Lunas') return false;
      if (_selectedStatusFilter == 'Lunas' && b.status != 'Lunas') return false;
      return true;
    }).toList();

    // Calculate totals
    double totalPaid = 0;
    double totalUnpaid = 0;
    final baseBills = isWaliMurid ? provider.bills.where((b) => b.studentId == childId) : provider.bills;
    for (final b in baseBills) {
      if (b.status == 'Lunas') {
        totalPaid += b.amount;
      } else {
        totalUnpaid += b.amount;
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.chevron_back, color: Color(0xFF1C1C1E), size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pembayaran & SPP Sekolah',
              style: TextStyle(
                color: Color(0xFF1C1C1E),
                fontSize: 17,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.4,
              ),
            ),
            Text(
              isWaliMurid
                  ? 'Tagihan Santri: $childName (${myChild?.className ?? ""})'
                  : 'Administrasi Keuangan Pesantren',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          if (role == 'staff' || role == 'admin' || role == 'kepsek')
            IconButton(
              icon: const Icon(Icons.add_circle_outline_rounded, color: Color(0xFF00B14F), size: 26),
              tooltip: 'Buat Tagihan SPP Baru',
              onPressed: () => _showAddBillModal(context, provider),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // 1. Bento Box Summary Cards
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              children: [
                Row(
                  children: [
                    // Belum Lunas Box
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF3B30).withOpacity(0.08),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFFF3B30).withOpacity(0.2)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.pending_actions_rounded, size: 16, color: Color(0xFFFF3B30)),
                                SizedBox(width: 6),
                                Text(
                                  'Tunggakan',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFFF3B30)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Rp ${_formatNumber(totalUnpaid)}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1C1C1E),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Lunas Box
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF34C759).withOpacity(0.08),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF34C759).withOpacity(0.2)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.check_circle_outline_rounded, size: 16, color: Color(0xFF34C759)),
                                SizedBox(width: 6),
                                Text(
                                  'Terbayar',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF28A745)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Rp ${_formatNumber(totalPaid)}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1C1C1E),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Status Filter Chips
                Row(
                  children: [
                    _buildFilterChip('Semua'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Belum Lunas'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Lunas'),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // 2. Bill List
          Expanded(
            child: filteredBills.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long_rounded, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text(
                          'Tidak Ada Tagihan $_selectedStatusFilter',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1C1C1E)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Semua kewajiban pembayaran telah sesuai data.',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filteredBills.length,
                    itemBuilder: (context, index) {
                      final bill = filteredBills[index];
                      return _buildBillCard(context, provider, bill);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedStatusFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedStatusFilter = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00B14F) : const Color(0xFFF2F2F7),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF8E8E93),
          ),
        ),
      ),
    );
  }

  Widget _buildBillCard(BuildContext context, SchoolProvider provider, PaymentBill bill) {
    final isLunas = bill.status == 'Lunas';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Category Pill & Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF007AFF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  bill.category,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF007AFF),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isLunas ? const Color(0xFF34C759).withOpacity(0.12) : const Color(0xFFFF3B30).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      isLunas ? Icons.check_circle_rounded : Icons.access_time_filled_rounded,
                      size: 13,
                      color: isLunas ? const Color(0xFF28A745) : const Color(0xFFFF3B30),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      bill.status,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isLunas ? const Color(0xFF28A745) : const Color(0xFFFF3B30),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Title & Student Details
          Text(
            bill.month != null ? '${bill.category} - Bulan ${bill.month}' : bill.category,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1C1C1E),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                '${bill.studentName} • ${bill.className}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1, thickness: 0.7),
          const SizedBox(height: 12),

          // Bottom Row: Nominal & Action Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isLunas ? 'Terbayar pada ${bill.paidDate ?? "-"}' : 'Jatuh tempo: ${bill.dueDate}',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Rp ${_formatNumber(bill.amount)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1C1C1E),
                    ),
                  ),
                ],
              ),

              // Action: Bayar (if Belum Lunas) or Kuitansi (if Lunas)
              if (isLunas)
                OutlinedButton.icon(
                  onPressed: () => _showReceiptDialog(context, bill),
                  icon: const Icon(Icons.receipt_rounded, size: 15),
                  label: const Text('Kuitansi', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF00B14F),
                    side: const BorderSide(color: Color(0xFF00B14F)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                )
              else
                ElevatedButton.icon(
                  onPressed: () => _showPayModal(context, provider, bill),
                  icon: const Icon(Icons.payment_rounded, size: 15),
                  label: const Text('Bayar', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00B14F),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // MaoneArt Glassmorphism Symmetrical Payment Modal
  void _showPayModal(BuildContext context, SchoolProvider provider, PaymentBill bill) {
    String selectedMethod = 'EduPay Tabungan';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (modalCtx, setModalState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Pembayaran Tagihan Sekolah',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1C1C1E)),
              ),
              const SizedBox(height: 4),
              Text(
                '${bill.category} • ${bill.studentName} (${bill.className})',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 16),

              // Total to pay
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F2F7),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total yang Harus Dibayar', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    Text(
                      'Rp ${_formatNumber(bill.amount)}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF00B14F)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              const Text('Pilih Metode Pembayaran', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),

              // Method Options
              _buildMethodRadio(
                title: 'EduPay Tabungan Siswa',
                subtitle: 'Saldo Tersedia: Rp ${_formatNumber(provider.totalSavings)}',
                value: 'EduPay Tabungan',
                groupValue: selectedMethod,
                onChanged: (v) => setModalState(() => selectedMethod = v!),
              ),
              _buildMethodRadio(
                title: 'Tunai di Tata Usaha (TU)',
                subtitle: 'Bayar langsung ke loket keuangan sekolah',
                value: 'Tunai di TU',
                groupValue: selectedMethod,
                onChanged: (v) => setModalState(() => selectedMethod = v!),
              ),
              _buildMethodRadio(
                title: 'Transfer Bank Syariah (BSI / Mandiri)',
                subtitle: 'Verifikasi otomatis via bendahara',
                value: 'Transfer Bank',
                groupValue: selectedMethod,
                onChanged: (v) => setModalState(() => selectedMethod = v!),
              ),

              const SizedBox(height: 24),

              // MaoneArt 100% Symmetrical 2-column Grid Buttons
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
                      child: const Text('Batal', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF8E8E93))),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(ctx);
                        final success = await provider.paySchoolBill(bill.id, selectedMethod);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(success ? 'Pembayaran berhasil diproses!' : 'Gagal memproses pembayaran. Cek saldo Anda.'),
                              backgroundColor: success ? const Color(0xFF00B14F) : Colors.red,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00B14F),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Bayar Sekarang', style: TextStyle(fontWeight: FontWeight.bold)),
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

  Widget _buildMethodRadio({
    required String title,
    required String subtitle,
    required String value,
    required String groupValue,
    required ValueChanged<String?> onChanged,
  }) {
    final isSelected = value == groupValue;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00B14F).withOpacity(0.06) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? const Color(0xFF00B14F) : Colors.grey.shade200,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_unchecked_rounded,
              color: isSelected ? const Color(0xFF00B14F) : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1C1C1E))),
                  Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Digital Receipt Popup (Kuitansi Resmi)
  void _showReceiptDialog(BuildContext context, PaymentBill bill) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF34C759).withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded, color: Color(0xFF28A745), size: 36),
            ),
            const SizedBox(height: 14),
            const Text(
              'KUITANSI PEMBAYARAN RESMI',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF1C1C1E), letterSpacing: 0.5),
            ),
            const Text(
              'Pondok Pesantren Manbaul Hikmah',
              style: TextStyle(fontSize: 11, color: Color(0xFF8E8E93)),
            ),
            const SizedBox(height: 16),
            const Divider(thickness: 0.8),
            const SizedBox(height: 12),

            _buildReceiptRow('Nomor Kuitansi', bill.invoiceNumber),
            _buildReceiptRow('Nama Santri', bill.studentName),
            _buildReceiptRow('Kelas', bill.className),
            _buildReceiptRow('Keperluan', bill.month != null ? '${bill.category} (${bill.month})' : bill.category),
            _buildReceiptRow('Tanggal Bayar', bill.paidDate ?? '-'),
            _buildReceiptRow('Metode Bayar', bill.paymentMethod ?? '-'),
            const SizedBox(height: 8),
            const Divider(thickness: 0.8),
            const SizedBox(height: 8),
            _buildReceiptRow('TOTAL BAYAR', 'Rp ${_formatNumber(bill.amount)}', isBold: true),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00B14F),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Tutup', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: isBold ? 13 : 11, fontWeight: isBold ? FontWeight.bold : FontWeight.w500, color: Colors.grey.shade600)),
          Text(value, style: TextStyle(fontSize: isBold ? 14 : 11, fontWeight: isBold ? FontWeight.w800 : FontWeight.bold, color: const Color(0xFF1C1C1E))),
        ],
      ),
    );
  }

  // Modal Buat Tagihan SPP Baru (Staff TU / Kepsek)
  void _showAddBillModal(BuildContext context, SchoolProvider provider) {
    int selectedStudentId = provider.students.isNotEmpty ? provider.students.first.id : 1;
    String selectedCategory = 'SPP Bulanan';
    String selectedMonth = 'November';
    final amountCtrl = TextEditingController(text: '250000');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (mCtx, setMState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Buat Tagihan Biaya Sekolah', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),

              // Pilih Siswa
              const Text('Pilih Santri / Siswa', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F2F7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: selectedStudentId,
                    isExpanded: true,
                    items: provider.allStudents.map((s) {
                      return DropdownMenuItem<int>(
                        value: s.id,
                        child: Text('${s.name} (${s.className})', style: const TextStyle(fontSize: 13)),
                      );
                    }).toList(),
                    onChanged: (v) {
                      if (v != null) setMState(() => selectedStudentId = v);
                    },
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Kategori Tagihan
              const Text('Kategori Biaya', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F2F7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedCategory,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(value: 'SPP Bulanan', child: Text('SPP Bulanan (Syahriyah)')),
                      DropdownMenuItem(value: 'Uang Gedung / Infaq', child: Text('Uang Gedung / Sarana')),
                      DropdownMenuItem(value: 'Buku & Modul', child: Text('Buku Pelajaran & Modul')),
                      DropdownMenuItem(value: 'Seragam Santri', child: Text('Seragam Sekolah')),
                      DropdownMenuItem(value: 'Kegiatan & PTS', child: Text('Biaya Ujian / PTS & Kegiatan')),
                    ],
                    onChanged: (v) {
                      if (v != null) setMState(() => selectedCategory = v);
                    },
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Nominal
              const Text('Nominal Tagihan (Rp)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F2F7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: amountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    prefixText: 'Rp ',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Symmetrical 2-column action buttons
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
                      child: const Text('Batal', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF8E8E93))),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final nominal = double.tryParse(amountCtrl.text) ?? 250000;
                        provider.addPaymentBill(
                          studentId: selectedStudentId,
                          category: selectedCategory,
                          month: selectedCategory == 'SPP Bulanan' ? selectedMonth : null,
                          amount: nominal,
                        );
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Tagihan baru berhasil dibuat!'), backgroundColor: Color(0xFF00B14F)),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00B14F),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Simpan Tagihan', style: TextStyle(fontWeight: FontWeight.bold)),
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

  static String _formatNumber(double num) {
    return num.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }
}
