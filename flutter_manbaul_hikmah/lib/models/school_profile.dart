class SchoolProfile {
  final int id;
  final String schoolName;
  final String npsn;
  final String address;
  final String phone;
  final String tuWhatsapp;
  final String bankName;
  final String bankAccountNumber;
  final String bankAccountHolder;
  final String? bankName2;
  final String? bankAccountNumber2;
  final String? bankAccountHolder2;
  final String kepsekName;
  final String? kepsekNip;
  final String tuName;

  SchoolProfile({
    this.id = 1,
    required this.schoolName,
    required this.npsn,
    required this.address,
    this.phone = '',
    required this.tuWhatsapp,
    required this.bankName,
    required this.bankAccountNumber,
    required this.bankAccountHolder,
    this.bankName2,
    this.bankAccountNumber2,
    this.bankAccountHolder2,
    required this.kepsekName,
    this.kepsekNip,
    required this.tuName,
  });

  factory SchoolProfile.fromJson(Map<String, dynamic> json) {
    return SchoolProfile(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '1') ?? 1,
      schoolName: json['school_name'] ?? 'SDIT Manbaul Hikmah',
      npsn: json['npsn'] ?? '20260001',
      address: json['address'] ?? 'Jl. KH. Noer Ali No. 45, Karang Satria, Tambun Utara, Bekasi',
      phone: json['phone'] ?? '021-88997766',
      tuWhatsapp: json['tu_whatsapp'] ?? '6281234567890',
      bankName: json['bank_name'] ?? 'Bank Syariah Indonesia (BSI)',
      bankAccountNumber: json['bank_account_number'] ?? '7188299102',
      bankAccountHolder: json['bank_account_holder'] ?? 'Yayasan Manbaul Hikmah',
      bankName2: json['bank_name_2'],
      bankAccountNumber2: json['bank_account_number_2'],
      bankAccountHolder2: json['bank_account_holder_2'],
      kepsekName: json['kepsek_name'] ?? 'KH. Ahmad Syafei, M.Pd.',
      kepsekNip: json['kepsek_nip'] ?? '197508122002121003',
      tuName: json['tu_name'] ?? 'Ustadzah Halimah, S.E.',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'school_name': schoolName,
      'npsn': npsn,
      'address': address,
      'phone': phone,
      'tu_whatsapp': tuWhatsapp,
      'bank_name': bankName,
      'bank_account_number': bankAccountNumber,
      'bank_account_holder': bankAccountHolder,
      'bank_name_2': bankName2,
      'bank_account_number_2': bankAccountNumber2,
      'bank_account_holder_2': bankAccountHolder2,
      'kepsek_name': kepsekName,
      'kepsek_nip': kepsekNip,
      'tu_name': tuName,
    };
  }
}
