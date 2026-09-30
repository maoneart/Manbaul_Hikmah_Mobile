class SavingsTransaction {
  final int id;
  final int studentId;
  final String type; // 'setor', 'tarik'
  final double amount;
  final double balanceAfter;
  final String notes;
  final String date;

  SavingsTransaction({
    required this.id,
    required this.studentId,
    required this.type,
    required this.amount,
    required this.balanceAfter,
    required this.notes,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'student_id': studentId,
    'type': type,
    'amount': amount,
    'balance_after': balanceAfter,
    'notes': notes,
    'date': date,
  };

  factory SavingsTransaction.fromJson(Map<String, dynamic> json) => SavingsTransaction(
    id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
    studentId: json['student_id'] is int ? json['student_id'] : int.parse(json['student_id'].toString()),
    type: json['type'] ?? json['transaction_type'] ?? 'setor',
    amount: double.tryParse(json['amount'].toString()) ?? 0.0,
    balanceAfter: double.tryParse(json['balance_after'].toString()) ?? 0.0,
    notes: json['notes'] ?? 'Tabungan',
    date: json['date'] ?? json['transaction_date'] ?? '',
  );
}
