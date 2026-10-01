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

  static String _terbilang(double amount) {
    final n = amount.toInt();
    if (n == 0) return 'Nol Rupiah';

    const satuan = [
      '', 'Satu', 'Dua', 'Tiga', 'Empat', 'Lima', 'Enam', 'Tujuh', 'Delapan', 'Sembilan', 'Sepuluh', 'Sebelas'
    ];

    String conv(int num) {
      if (num < 12) return satuan[num];
      if (num < 20) return '${satuan[num - 10]} Belas';
      if (num < 100) return '${satuan[num ~/ 10]} Puluh ${conv(num % 10)}'.trim();
      if (num < 200) return 'Seratus ${conv(num - 100)}'.trim();
      if (num < 1000) return '${satuan[num ~/ 100]} Ratus ${conv(num % 100)}'.trim();
      if (num < 2000) return 'Seribu ${conv(num - 1000)}'.trim();
      if (num < 1000000) return '${conv(num ~/ 1000)} Ribu ${conv(num % 1000)}'.trim();
      if (num < 1000000000) return '${conv(num ~/ 1000000)} Juta ${conv(num % 1000000)}'.trim();
      return '${conv(num ~/ 1000000000)} Miliar ${conv(num % 1000000000)}'.trim();
    }

    return '${conv(n)} Rupiah';
  }

  static List<int> generate(PaymentBill bill, SchoolProfile? profile) {
    final schoolName = profile?.schoolName ?? 'SDIT Manbaul Hikmah';
    final npsn = profile?.npsn ?? '20260001';
    final address = profile?.address ?? 'Jl. KH. Noer Ali No. 45, Karang Satria, Tambun Utara, Bekasi';
    final phone = profile?.tuWhatsapp ?? profile?.phone ?? '0812-9876-5432';
    final tuName = bill.verifiedBy ?? profile?.tuName ?? 'Staff Tata Usaha';

    final invoiceNo = bill.invoiceNumber.isNotEmpty ? bill.invoiceNumber : 'INV-MH-${bill.id}';
    final studentName = bill.studentName;
    final className = bill.className;
    final category = bill.category;
    final period = bill.month != null ? '${bill.month} • T.A ${bill.academicYear}' : 'T.A ${bill.academicYear}';
    final paymentMethod = bill.paymentMethod ?? 'Transfer Bank (BSI)';
    final paidDate = bill.paidDate ?? '18 Juli 2026, 11:00 WIB';
    final amountFormatted = 'Rp ${_formatNumber(bill.amount)}';
    final terbilangStr = '## ${_terbilang(bill.amount)} ##';

    final lines = <String>[];

    void drawRect(double x, double y, double w, double h, {bool fill = true, bool stroke = true}) {
      final op = (fill && stroke) ? 'B' : (fill ? 'f' : 'S');
      lines.add('${x.toStringAsFixed(1)} ${y.toStringAsFixed(1)} ${w.toStringAsFixed(1)} ${h.toStringAsFixed(1)} re $op');
    }

    void drawLine(double x1, double y1, double x2, double y2, {double width = 1.0}) {
      lines.add('${width.toStringAsFixed(2)} w ${x1.toStringAsFixed(1)} ${y1.toStringAsFixed(1)} m ${x2.toStringAsFixed(1)} ${y2.toStringAsFixed(1)} l S');
    }

    void drawText(String text, double x, double y, {String font = '/F1', double size = 10, String color = '0 0 0 rg'}) {
      lines.add('BT $font $size Tf $color 1 0 0 1 ${x.toStringAsFixed(1)} ${y.toStringAsFixed(1)} Tm (${_esc(text)}) Tj ET');
    }

    void drawCenteredText(String text, double y, {double pageWidth = 595.0, String font = '/F1', double size = 10, String color = '0 0 0 rg'}) {
      final estWidth = text.length * size * 0.52;
      final x = (pageWidth - estWidth) / 2;
      drawText(text, x, y, font: font, size: size, color: color);
    }

    // ==========================================
    // 1. PAPER & BACKGROUND CONTAINER
    // ==========================================
    lines.add('1 1 1 rg');
    drawRect(35, 70, 525, 735, fill: true, stroke: false);

    // Outer Dark Green Border
    lines.add('0.02 0.35 0.18 RG');
    lines.add('2 w');
    drawRect(35, 70, 525, 735, fill: false, stroke: true);

    // Inner Gold Hairline Border
    lines.add('0.85 0.65 0.15 RG');
    lines.add('0.75 w');
    drawRect(39, 74, 517, 727, fill: false, stroke: true);

    // ==========================================
    // 2. KOP SURAT RESMI LEMBAGA
    // ==========================================
    // Header soft background
    lines.add('0.95 0.98 0.96 rg');
    drawRect(40, 715, 515, 89, fill: true, stroke: false);

    // Double Green & Gold separator lines
    lines.add('0.02 0.35 0.18 RG');
    drawLine(40, 715, 555, 715, width: 2.0);
    lines.add('0.85 0.65 0.15 RG');
    drawLine(40, 711, 555, 711, width: 1.0);

    // Logo Emblem Box
    lines.add('0.02 0.35 0.18 rg');
    drawRect(55, 732, 50, 50, fill: true, stroke: false);
    lines.add('0.85 0.65 0.15 RG');
    drawRect(55, 732, 50, 50, fill: false, stroke: true);
    drawText('MH', 68, 748, font: '/F2', size: 20, color: '0.98 0.85 0.35 rg');

    // Kop Text
    drawText('YAYASAN PENDIDIKAN ISLAM MANBAUL HIKMAH', 118, 775, font: '/F2', size: 10.5, color: '0.02 0.35 0.18 rg');
    drawText(schoolName.toUpperCase(), 118, 756, font: '/F2', size: 15, color: '0.01 0.25 0.12 rg');
    drawText(address, 118, 741, font: '/F1', size: 8, color: '0.30 0.30 0.30 rg');
    drawText('NPSN: $npsn   |   No. Kontak / WA: $phone   |   Web: maoneart.my.id', 118, 727, font: '/F1', size: 7.5, color: '0.40 0.40 0.40 rg');

    // ==========================================
    // 3. TITLE RIBBON
    // ==========================================
    lines.add('0.02 0.35 0.18 rg');
    drawRect(140, 672, 315, 25, fill: true, stroke: false);
    lines.add('0.85 0.65 0.15 RG');
    drawRect(140, 672, 315, 25, fill: false, stroke: true);

    drawCenteredText('KUITANSI BUKTI PEMBAYARAN SAH', 680, font: '/F2', size: 11, color: '1 1 1 rg');

    // ==========================================
    // 4. TRANSACTION META BAR
    // ==========================================
    lines.add('0.97 0.98 0.97 rg');
    drawRect(55, 624, 485, 36, fill: true, stroke: false);
    lines.add('0.85 0.88 0.85 RG');
    drawRect(55, 624, 485, 36, fill: false, stroke: true);

    // Invoice No
    drawText('No. Kwitansi / Transaksi:', 70, 646, font: '/F1', size: 8, color: '0.5 0.5 0.5 rg');
    drawText(invoiceNo, 70, 633, font: '/F2', size: 10.5, color: '0.02 0.35 0.18 rg');

    // Paid Date
    drawText('Tanggal & Waktu Pembayaran:', 240, 646, font: '/F1', size: 8, color: '0.5 0.5 0.5 rg');
    drawText(paidDate, 240, 633, font: '/F2', size: 9.5, color: '0.15 0.15 0.15 rg');

    // Status Badge
    drawText('Status:', 420, 646, font: '/F1', size: 8, color: '0.5 0.5 0.5 rg');
    lines.add('0.85 0.96 0.88 rg');
    drawRect(420, 630, 105, 16, fill: true, stroke: false);
    lines.add('0.10 0.60 0.30 RG');
    drawRect(420, 630, 105, 16, fill: false, stroke: true);
    drawText('● LUNAS / SAH', 432, 634, font: '/F2', size: 8.5, color: '0.05 0.50 0.20 rg');

    // ==========================================
    // 5. DATA IDENTITAS SISWA & PENYETOR
    // ==========================================
    lines.add('1 1 1 rg');
    drawRect(55, 526, 485, 88, fill: true, stroke: false);
    lines.add('0.85 0.88 0.85 RG');
    drawRect(55, 526, 485, 88, fill: false, stroke: true);

    // Subheader title
    lines.add('0.93 0.96 0.94 rg');
    drawRect(55, 598, 485, 16, fill: true, stroke: false);
    drawText('DATA IDENTITAS SISWA & PENYETOR', 68, 603, font: '/F2', size: 8, color: '0.02 0.35 0.18 rg');

    // Column Left: Student Info
    drawText('Nama Lengkap Siswa', 70, 582, font: '/F1', size: 8.5, color: '0.45 0.45 0.45 rg');
    drawText(': $studentName', 165, 582, font: '/F2', size: 9.5, color: '0.1 0.1 0.1 rg');

    drawText('Kelas / Rombel', 70, 562, font: '/F1', size: 8.5, color: '0.45 0.45 0.45 rg');
    drawText(': $className', 165, 562, font: '/F1', size: 9, color: '0.15 0.15 0.15 rg');

    drawText('Tahun Pelajaran', 70, 542, font: '/F1', size: 8.5, color: '0.45 0.45 0.45 rg');
    drawText(': ${bill.academicYear}', 165, 542, font: '/F1', size: 9, color: '0.15 0.15 0.15 rg');

    // Column Right: Payer & Payment Info
    drawText('Penyetor / Wali Murid', 320, 582, font: '/F1', size: 8.5, color: '0.45 0.45 0.45 rg');
    drawText(': Wali Murid ($studentName)', 425, 582, font: '/F1', size: 8.5, color: '0.1 0.1 0.1 rg');

    drawText('Metode Pembayaran', 320, 562, font: '/F1', size: 8.5, color: '0.45 0.45 0.45 rg');
    drawText(': $paymentMethod', 425, 562, font: '/F2', size: 8.5, color: '0.02 0.35 0.18 rg');

    drawText('Petugas Penerima TU', 320, 542, font: '/F1', size: 8.5, color: '0.45 0.45 0.45 rg');
    drawText(': $tuName', 425, 542, font: '/F1', size: 8.5, color: '0.15 0.15 0.15 rg');

    // ==========================================
    // 6. TABEL RINCIAN PEMBAYARAN (ZEBRA TABLE)
    // ==========================================
    // Table Header
    lines.add('0.02 0.35 0.18 rg');
    drawRect(55, 492, 485, 22, fill: true, stroke: false);
    drawText('NO', 70, 499, font: '/F2', size: 8.5, color: '1 1 1 rg');
    drawText('URAIAN / POS PEMBAYARAN', 110, 499, font: '/F2', size: 8.5, color: '1 1 1 rg');
    drawText('PERIODE / BULAN', 320, 499, font: '/F2', size: 8.5, color: '1 1 1 rg');
    drawText('JUMLAH (RP)', 455, 499, font: '/F2', size: 8.5, color: '1 1 1 rg');

    // Table Row 1
    lines.add('1 1 1 rg');
    drawRect(55, 448, 485, 44, fill: true, stroke: false);
    lines.add('0.85 0.88 0.85 RG');
    drawRect(55, 448, 485, 44, fill: false, stroke: true);

    drawText('1.', 72, 472, font: '/F1', size: 9, color: '0.3 0.3 0.3 rg');
    drawText(category, 110, 474, font: '/F2', size: 9.5, color: '0.1 0.1 0.1 rg');
    drawText('Pelunasan Biaya Administrasi Resmi Sekolah', 110, 458, font: '/F1', size: 7.5, color: '0.5 0.5 0.5 rg');
    drawText(period, 320, 470, font: '/F1', size: 8.5, color: '0.2 0.2 0.2 rg');
    drawText(amountFormatted, 455, 470, font: '/F2', size: 10.5, color: '0.02 0.35 0.18 rg');

    // Table Total Row
    lines.add('0.90 0.96 0.92 rg');
    drawRect(55, 416, 485, 32, fill: true, stroke: false);
    lines.add('0.02 0.35 0.18 RG');
    lines.add('1 w');
    drawRect(55, 416, 485, 32, fill: false, stroke: true);

    drawText('TOTAL NOMINAL PEMBAYARAN DITERIMA', 110, 427, font: '/F2', size: 9.5, color: '0.02 0.35 0.18 rg');
    drawText(amountFormatted, 435, 425, font: '/F2', size: 14, color: '0.01 0.28 0.12 rg');

    // ==========================================
    // 7. TERBILANG BOX
    // ==========================================
    lines.add('0.99 0.98 0.92 rg');
    drawRect(55, 378, 485, 26, fill: true, stroke: false);
    lines.add('0.85 0.65 0.15 RG');
    drawRect(55, 378, 485, 26, fill: false, stroke: true);

    drawText('TERBILANG:', 68, 387, font: '/F2', size: 8, color: '0.70 0.50 0.05 rg');
    drawText(terbilangStr, 135, 386, font: '/F3', size: 9.5, color: '0.15 0.15 0.15 rg');

    // ==========================================
    // 8. LEGAL VALIDITY & SECURITY NOTE
    // ==========================================
    lines.add('0.97 0.98 0.99 rg');
    drawRect(55, 338, 485, 28, fill: true, stroke: false);
    lines.add('0.85 0.88 0.92 RG');
    drawRect(55, 338, 485, 28, fill: false, stroke: true);

    drawText('CATATAN KEABSAHAN DOKUMEN:', 68, 353, font: '/F2', size: 7.5, color: '0.02 0.35 0.18 rg');
    drawText('Kuitansi ini diterbitkan secara resmi oleh Sistem Keuangan SDIT Manbaul Hikmah dan sah sebagai bukti', 68, 343, font: '/F1', size: 7, color: '0.40 0.40 0.40 rg');
    drawText('pembayaran biaya pendidikan yang sah tanpa memerlukan legalisir basah sesuai ketentuan administrasi.', 68, 333, font: '/F1', size: 7, color: '0.40 0.40 0.40 rg');

    // ==========================================
    // 9. DUAL SIGNATURES & OFFICIAL STAMP
    // ==========================================
    // Left: Wali Murid
    drawText('Penyetor / Wali Murid,', 90, 312, font: '/F1', size: 8.5, color: '0.3 0.3 0.3 rg');
    lines.add('0.7 0.7 0.7 RG');
    drawLine(70, 248, 220, 248, width: 0.8);
    drawText('( Wali Murid Siswa )', 95, 235, font: '/F2', size: 8.5, color: '0.2 0.2 0.2 rg');

    // Right: Staff TU & Stempel Digital
    drawText('Bekasi, $paidDate', 375, 318, font: '/F1', size: 8, color: '0.3 0.3 0.3 rg');
    drawText('Petugas Keuangan / Tata Usaha,', 375, 306, font: '/F1', size: 8.5, color: '0.3 0.3 0.3 rg');

    // Official Stamp Emblem
    lines.add('0.93 0.98 0.95 rg');
    drawRect(375, 256, 135, 42, fill: true, stroke: false);
    lines.add('0.05 0.50 0.20 RG');
    lines.add('1.2 w');
    drawRect(375, 256, 135, 42, fill: false, stroke: true);

    drawText('★ TERVERIFIKASI SAH ★', 388, 285, font: '/F2', size: 7.5, color: '0.05 0.50 0.20 rg');
    drawText('TATA USAHA & KEUANGAN', 386, 273, font: '/F2', size: 6.5, color: '0.02 0.35 0.18 rg');
    drawText('SDIT MANBAUL HIKMAH', 391, 262, font: '/F2', size: 6.5, color: '0.02 0.35 0.18 rg');

    lines.add('0.7 0.7 0.7 RG');
    drawLine(365, 248, 520, 248, width: 0.8);
    drawText('( $tuName )', 395, 235, font: '/F2', size: 8.5, color: '0.15 0.15 0.15 rg');
    drawText('Staff Administrasi & Keuangan', 385, 224, font: '/F1', size: 7.5, color: '0.5 0.5 0.5 rg');

    // ==========================================
    // 10. FOOTER SERIAL & WATERMARK
    // ==========================================
    lines.add('0.85 0.85 0.85 RG');
    drawLine(45, 110, 550, 110, width: 0.5);

    drawText('Kuitansi Resmi SDIT Manbaul Hikmah • Dokumen Sah Finansial', 55, 96, font: '/F1', size: 7.5, color: '0.5 0.5 0.5 rg');
    drawText('ID: $invoiceNo • Dicetak via Manbaul Hikmah Mobile App', 55, 84, font: '/F1', size: 7, color: '0.6 0.6 0.6 rg');

    final streamContent = lines.join('\n');
    final streamBytes = utf8.encode(streamContent);
    final streamLength = streamBytes.length;

    final objects = <String>[
      '<< /Type /Catalog /Pages 2 0 R >>',
      '<< /Type /Pages /Kids [3 0 R] /Count 1 >>',
      '<< /Type /Page /Parent 2 0 R /MediaBox [0 0 595 842] /Resources << /Font << /F1 5 0 R /F2 6 0 R /F3 7 0 R >> >> /Contents 4 0 R >>',
      '<< /Length $streamLength >>\nstream\n$streamContent\nendstream',
      '<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>',
      '<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica-Bold >>',
      '<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica-Oblique >>',
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
