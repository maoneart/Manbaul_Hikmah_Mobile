class AttendanceRecord {
  final int studentId;
  final String className;
  final String date;
  String status; // 'Hadir', 'Sakit', 'Izin', 'Alfa', 'Belum Absen'
  String? scanTime;
  String notes;

  AttendanceRecord({
    required this.studentId,
    required this.className,
    required this.date,
    required this.status,
    this.scanTime,
    this.notes = '',
  });

  Map<String, dynamic> toJson() => {
    'student_id': studentId,
    'class_name': className,
    'date': date,
    'status': status,
    'scan_time': scanTime,
    'notes': notes,
  };

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) => AttendanceRecord(
    studentId: json['student_id'] is int ? json['student_id'] : int.parse(json['student_id'].toString()),
    className: json['class_name'] ?? 'Kelas 7A',
    date: json['date'] ?? json['attendance_date'] ?? '',
    status: json['status'] ?? 'Belum Absen',
    scanTime: json['scan_time'],
    notes: json['notes'] ?? '',
  );
}
