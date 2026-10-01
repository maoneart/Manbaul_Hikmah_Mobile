class Student {
  final int id;
  final String nisn;
  final String studentNik; // NIK Siswa (16 digit)
  final String name;
  final String gender;
  String className;
  final String parentName;
  final String parentPhone;
  final String parentNik; // NIK Orang Tua/Wali (16 digit)
  double balance;
  final String qrCodeToken;
  final String address;
  final String entryYear;
  final String admissionDate; // Tanggal Masuk (SOP)
  final String status; // 'Aktif', 'Lulus', 'Pindah'
  final String graduationDate; // Tanggal Lulus (jika Lulus)
  final String birthPlaceDate;

  Student({
    required this.id,
    required this.nisn,
    this.studentNik = '',
    required this.name,
    required this.gender,
    required this.className,
    required this.parentName,
    required this.parentPhone,
    this.parentNik = '',
    required this.balance,
    required this.qrCodeToken,
    this.address = '-',
    this.entryYear = '2024',
    this.admissionDate = '',
    this.status = 'Aktif',
    this.graduationDate = '',
    this.birthPlaceDate = '-',
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'nisn': nisn,
    'student_nik': studentNik,
    'name': name,
    'gender': gender,
    'class_name': className,
    'parent_name': parentName,
    'parent_phone': parentPhone,
    'parent_nik': parentNik,
    'balance': balance,
    'qr_code_token': qrCodeToken,
    'address': address,
    'entry_year': entryYear,
    'admission_date': admissionDate,
    'status': status,
    'graduation_date': graduationDate,
    'birth_place_date': birthPlaceDate,
  };

  factory Student.fromJson(Map<String, dynamic> json) => Student(
    id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
    nisn: json['nisn']?.toString() ?? '',
    studentNik: json['student_nik']?.toString() ?? json['nik_siswa']?.toString() ?? '',
    name: json['name']?.toString() ?? '',
    gender: json['gender'] ?? 'L',
    className: json['class_name'] ?? 'Kelas 1A',
    parentName: json['parent_name'] ?? '',
    parentPhone: json['parent_phone'] ?? '',
    parentNik: json['parent_nik']?.toString() ?? json['nik_ortu']?.toString() ?? '',
    balance: double.tryParse(json['balance'].toString()) ?? 0.0,
    qrCodeToken: json['qr_code_token'] ?? 'MH-STD-${json['nisn']}',
    address: json['address'] ?? json['alamat'] ?? '-',
    entryYear: json['entry_year'] ?? json['tahun_masuk'] ?? '2024',
    admissionDate: json['admission_date']?.toString() ?? json['tanggal_masuk']?.toString() ?? (json['entry_year'] != null ? '${json['entry_year']}-07-15' : '2024-07-15'),
    status: json['status'] ?? 'Aktif',
    graduationDate: json['graduation_date']?.toString() ?? json['tanggal_lulus']?.toString() ?? '',
    birthPlaceDate: json['birth_place_date'] ?? json['ttl'] ?? '-',
  );

  Student copyWith({
    int? id,
    String? nisn,
    String? studentNik,
    String? name,
    String? gender,
    String? className,
    String? parentName,
    String? parentPhone,
    String? parentNik,
    double? balance,
    String? qrCodeToken,
    String? address,
    String? entryYear,
    String? admissionDate,
    String? status,
    String? graduationDate,
    String? birthPlaceDate,
  }) {
    return Student(
      id: id ?? this.id,
      nisn: nisn ?? this.nisn,
      studentNik: studentNik ?? this.studentNik,
      name: name ?? this.name,
      gender: gender ?? this.gender,
      className: className ?? this.className,
      parentName: parentName ?? this.parentName,
      parentPhone: parentPhone ?? this.parentPhone,
      parentNik: parentNik ?? this.parentNik,
      balance: balance ?? this.balance,
      qrCodeToken: qrCodeToken ?? this.qrCodeToken,
      address: address ?? this.address,
      entryYear: entryYear ?? this.entryYear,
      admissionDate: admissionDate ?? this.admissionDate,
      status: status ?? this.status,
      graduationDate: graduationDate ?? this.graduationDate,
      birthPlaceDate: birthPlaceDate ?? this.birthPlaceDate,
    );
  }
}
