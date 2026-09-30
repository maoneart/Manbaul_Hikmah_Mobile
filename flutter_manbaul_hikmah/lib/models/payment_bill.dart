class PaymentBill {
  final int id;
  final int studentId;
  final String studentName;
  final String className;
  final String category; // 'SPP Bulanan', 'Uang Gedung / Infaq', 'Buku & Modul', 'Seragam Sekolah', 'Kegiatan & PTS'
  final String? month;
  final String academicYear;
  final double amount;
  double paidAmount;
  String status; // 'Lunas', 'Belum Lunas'
  final String dueDate;
  String? paidDate;
  String? paymentMethod; // 'Tunai di TU', 'EduPay Tabungan', 'Transfer Bank'
  final String invoiceNumber;
  final String notes;

  PaymentBill({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.className,
    required this.category,
    this.month,
    this.academicYear = '2026/2027',
    required this.amount,
    this.paidAmount = 0.0,
    required this.status,
    required this.dueDate,
    this.paidDate,
    this.paymentMethod,
    required this.invoiceNumber,
    this.notes = '',
  });

  factory PaymentBill.fromJson(Map<String, dynamic> json) {
    return PaymentBill(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      studentId: json['student_id'] is int ? json['student_id'] : int.parse(json['student_id'].toString()),
      studentName: json['student_name'] ?? '',
      className: json['class_name'] ?? '',
      category: json['category'] ?? 'SPP Bulanan',
      month: json['month'],
      academicYear: json['academic_year'] ?? '2026/2027',
      amount: (json['amount'] is num) ? (json['amount'] as num).toDouble() : double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      paidAmount: (json['paid_amount'] is num) ? (json['paid_amount'] as num).toDouble() : double.tryParse(json['paid_amount']?.toString() ?? '0') ?? 0.0,
      status: json['status'] ?? 'Belum Lunas',
      dueDate: json['due_date'] ?? '',
      paidDate: json['paid_date'],
      paymentMethod: json['payment_method'],
      invoiceNumber: json['invoice_number'] ?? '',
      notes: json['notes'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'student_name': studentName,
      'class_name': className,
      'category': category,
      'month': month,
      'academic_year': academicYear,
      'amount': amount,
      'paid_amount': paidAmount,
      'status': status,
      'due_date': dueDate,
      'paid_date': paidDate,
      'payment_method': paymentMethod,
      'invoice_number': invoiceNumber,
      'notes': notes,
    };
  }
}
