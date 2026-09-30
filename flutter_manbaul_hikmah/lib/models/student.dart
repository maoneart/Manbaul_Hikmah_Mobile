class Student {
  final int id;
  final String nisn;
  final String name;
  final String gender;
  final String className;
  final String parentName;
  final String parentPhone;
  double balance;
  final String qrCodeToken;

  Student({
    required this.id,
    required this.nisn,
    required this.name,
    required this.gender,
    required this.className,
    required this.parentName,
    required this.parentPhone,
    required this.balance,
    required this.qrCodeToken,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'nisn': nisn,
    'name': name,
    'gender': gender,
    'class_name': className,
    'parent_name': parentName,
    'parent_phone': parentPhone,
    'balance': balance,
    'qr_code_token': qrCodeToken,
  };

  factory Student.fromJson(Map<String, dynamic> json) => Student(
    id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
    nisn: json['nisn'].toString(),
    name: json['name'].toString(),
    gender: json['gender'] ?? 'L',
    className: json['class_name'] ?? 'Kelas 7A',
    parentName: json['parent_name'] ?? '',
    parentPhone: json['parent_phone'] ?? '',
    balance: double.tryParse(json['balance'].toString()) ?? 0.0,
    qrCodeToken: json['qr_code_token'] ?? 'MH-STD-${json['nisn']}',
  );
}
