class Student {
  final int id;
  final String nisn;
  final String name;
  final String gender;
  String className;
  final String parentName;
  final String parentPhone;
  double balance;
  final String qrCodeToken;
  final String address;
  final String entryYear;
  final String status; // 'Aktif', 'Lulus', 'Pindah'
  final String birthPlaceDate;

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
    this.address = '-',
    this.entryYear = '2024',
    this.status = 'Aktif',
    this.birthPlaceDate = '-',
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
    'address': address,
    'entry_year': entryYear,
    'status': status,
    'birth_place_date': birthPlaceDate,
  };

  factory Student.fromJson(Map<String, dynamic> json) => Student(
    id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
    nisn: json['nisn'].toString(),
    name: json['name'].toString(),
    gender: json['gender'] ?? 'L',
    className: json['class_name'] ?? 'Kelas 1A',
    parentName: json['parent_name'] ?? '',
    parentPhone: json['parent_phone'] ?? '',
    balance: double.tryParse(json['balance'].toString()) ?? 0.0,
    qrCodeToken: json['qr_code_token'] ?? 'MH-STD-${json['nisn']}',
    address: json['address'] ?? json['alamat'] ?? '-',
    entryYear: json['entry_year'] ?? json['tahun_masuk'] ?? '2024',
    status: json['status'] ?? 'Aktif',
    birthPlaceDate: json['birth_place_date'] ?? json['ttl'] ?? '-',
  );
}
