import 'dart:convert';
import '../models/payment_bill.dart';
import '../models/school_profile.dart';

class ReceiptPdfGenerator {
  static String _esc(String str) {
    return str
        .replaceAll('\\', '\\\\')
        .replaceAll('(', '\\(')
        .replaceAll(')', '\\)');
  }

  static String _formatNumber(double amount) {
    final parts = amount.toStringAsFixed(0);
    final reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return parts.replaceAllMapped(reg, (Match m) => '${m[1]}.');
  }

  static List<int> generate(PaymentBill bill, SchoolProfile? profile) {
    final schoolName = profile?.schoolName ?? 'SDIT Manbaul Hikmah';
    final npsn = profile?.npsn ?? '20260001';
    final address = profile?.address ?? 'Jl. KH. Noer Ali No. 45, Karang Satria, Tambun Utara, Bekasi';
    final phone = profile?.phone ?? '021-88997766';
    final tuName = profile?.tuName ?? 'Staff Tata Usaha';

    final invoiceNo = bill.invoiceNumber;
    final studentName = bill.studentName;
    final className = bill.className;
    final category = bill.month != null ? '${bill.category} (${bill.month})' : bill.category;
    final paymentMethod = bill.paymentMethod ?? 'Transfer Bank';
    final paidDate = bill.paidDate ?? '-';
    final verifiedBy = bill.verifiedBy ?? tuName;
    final amountStr = 'Rp ${_formatNumber(bill.amount)}';

    final streamContent = '''
0.97 0.98 0.97 rg
40 160 515 640 re f
0 0 0 RG
1 w
40 160 515 640 re S

0 0.55 0.25 RG
2 w
55 725 m 540 725 l S
0.5 w
55 721 m 540 721 l S

BT
/F2 16 Tf
0 0.55 0.25 rg
297 768 Td
(${_esc(schoolName.toUpperCase())}) Tj
ET

BT
/F1 8.5 Tf
0.3 0.3 0.3 rg
297 750 Td
(${_esc(address)}) Tj
ET

BT
/F1 8.5 Tf
297 735 Td
(NPSN: ${_esc(npsn)}   |   Telp: ${_esc(phone)}) Tj
ET

0.85 0.95 0.88 rg
180 682 235 24 re f
0 0.55 0.25 RG
1 w
180 682 235 24 re S

BT
/F2 11 Tf
0 0.45 0.2 rg
215 690 Td
(TANDA BUKTI PEMBAYARAN SAH) Tj
ET

BT
/F1 10 Tf
0.25 0.25 0.25 rg
65 645 Td (Nomor Transaksi) Tj
200 645 Td (: ${_esc(invoiceNo)}) Tj
65 620 Td (Nama Siswa / Santri) Tj
200 620 Td (: ${_esc(studentName)}) Tj
65 595 Td (Kelas / Rombel) Tj
200 595 Td (: ${_esc(className)}) Tj
65 570 Td (Keperluan Pembayaran) Tj
200 570 Td (: ${_esc(category)}) Tj
65 545 Td (Metode Pembayaran) Tj
200 545 Td (: ${_esc(paymentMethod)}) Tj
65 520 Td (Waktu Pembayaran) Tj
200 520 Td (: ${_esc(paidDate)}) Tj
65 495 Td (Status Pembayaran) Tj
200 495 Td (: LUNAS  \\(TERVERIFIKASI\\)) Tj
ET

0 0.55 0.25 rg
65 425 465 42 re f

BT
/F1 9 Tf
1 1 1 rg
297 452 Td
(TOTAL NOMINAL DITERIMA:) Tj
ET

BT
/F2 16 Tf
1 1 1 rg
297 433 Td
(${_esc(amountStr)}) Tj
ET

0.6 0.6 0.6 RG
1 w
[3 3] 0 d
65 375 m 530 375 l S
[] 0 d

BT
/F1 9 Tf
0.3 0.3 0.3 rg
105 345 Td (Penyetor / Wali Murid) Tj
395 345 Td (Petugas Tata Usaha) Tj
ET

BT
/F2 9 Tf
0 0.55 0.25 rg
405 285 Td (SAH - LUNAS) Tj
ET

BT
/F2 9.5 Tf
0.1 0.1 0.1 rg
100 240 Td (\\( Wali Murid \\)) Tj
380 240 Td (\\( ${_esc(verifiedBy)} \\)) Tj
ET
'''.trim();

    final streamBytes = utf8.encode(streamContent);
    final streamLength = streamBytes.length;

    final objects = <String>[
      '<< /Type /Catalog /Pages 2 0 R >>',
      '<< /Type /Pages /Kids [3 0 R] /Count 1 >>',
      '<< /Type /Page /Parent 2 0 R /MediaBox [0 0 595 842] /Resources << /Font << /F1 5 0 R /F2 6 0 R >> >> /Contents 4 0 R >>',
      '<< /Length $streamLength >>\nstream\n$streamContent\nendstream',
      '<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>',
      '<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica-Bold >>',
    ];

    final buffer = StringBuffer();
    buffer.write('%PDF-1.4\n%\xE2\xE3\xCF\xD3\n');

    final offsets = <int>[];
    for (int i = 0; i < objects.length; i++) {
      offsets.add(utf8.encode(buffer.toString()).length);
      buffer.write('${i + 1} 0 obj\n${objects[i]}\nendobj\n');
    }

    final xrefOffset = utf8.encode(buffer.toString()).length;
    buffer.write('xref\n0 ${objects.length + 1}\n0000000000 65535 f \n');
    for (final off in offsets) {
      buffer.write('${off.toString().padLeft(10, '0')} 00000 n \n');
    }
    buffer.write('trailer\n<< /Size ${objects.length + 1} /Root 1 0 R >>\nstartxref\n$xrefOffset\n%%EOF\n');

    return utf8.encode(buffer.toString());
  }
}
