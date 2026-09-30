import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/student.dart';
import '../models/attendance.dart';
import '../models/savings.dart';
import '../models/announcement.dart';

class SchoolProvider with ChangeNotifier {
  String _currentRole = 'wali_kelas'; // 'wali_kelas', 'kepsek', 'wali_murid'
  String _activeClass = 'Kelas 7A';
  bool _isBalanceVisible = true;

  List<Student> _students = [];
  List<AttendanceRecord> _attendances = [];
  List<SavingsTransaction> _transactions = [];
  List<Announcement> _announcements = [];

  String get currentRole => _currentRole;
  String get activeClass => _activeClass;
  bool get isBalanceVisible => _isBalanceVisible;

  List<Student> get students => _students.where((s) => _activeClass == 'Semua' || s.className == _activeClass).toList();
  List<Student> get allStudents => _students;
  List<AttendanceRecord> get attendances => _attendances;
  List<SavingsTransaction> get transactions => _transactions;
  List<Announcement> get announcements => _announcements;

  SchoolProvider() {
    _loadInitialData();
  }

  void toggleBalanceVisibility() {
    _isBalanceVisible = !_isBalanceVisible;
    notifyListeners();
  }

  void switchRole(String role) {
    _currentRole = role;
    notifyListeners();
  }

  void switchClass(String className) {
    _activeClass = className;
    notifyListeners();
  }

  double get totalSavings {
    return students.fold(0.0, (sum, s) => sum + s.balance);
  }

  int get hadirCount => students.where((s) {
    final att = getStudentAttendance(s.id);
    return att != null && att.status == 'Hadir';
  }).length;

  int get sakitCount => students.where((s) {
    final att = getStudentAttendance(s.id);
    return att != null && att.status == 'Sakit';
  }).length;

  int get izinCount => students.where((s) {
    final att = getStudentAttendance(s.id);
    return att != null && att.status == 'Izin';
  }).length;

  int get alfaCount => students.where((s) {
    final att = getStudentAttendance(s.id);
    return att != null && att.status == 'Alfa';
  }).length;

  AttendanceRecord? getStudentAttendance(int studentId) {
    try {
      return _attendances.firstWhere((a) => a.studentId == studentId);
    } catch (_) {
      return null;
    }
  }

  List<SavingsTransaction> getStudentTransactions(int studentId) {
    return _transactions.where((t) => t.studentId == studentId).toList();
  }
  String scanQrCode(String qrToken) {
    Student? student;
    try {
      student = _students.firstWhere((s) => s.qrCodeToken == qrToken || s.nisn == qrToken);
    } catch (_) {
      student = null;
    }

    if (student == null) {
      return "QR Code tidak dikenali dalam sistem";
    }

    final now = DateTime.now();
    final timeStr = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} WIB";

    markAttendance(student.id, 'Hadir', scanTime: timeStr, notes: 'Presensi Scan QR');
    return "Berhasil Absen: ${student.name} (${student.className})";
  }

  void markAttendance(int studentId, String status, {String? scanTime, String notes = ''}) {
    final index = _attendances.indexWhere((a) => a.studentId == studentId);
    if (index >= 0) {
      _attendances[index].status = status;
      if (scanTime != null) _attendances[index].scanTime = scanTime;
      if (notes.isNotEmpty) _attendances[index].notes = notes;
    } else {
      final student = _students.firstWhere((s) => s.id == studentId);
      _attendances.add(AttendanceRecord(
        studentId: studentId,
        className: student.className,
        date: DateTime.now().toIso8601String().substring(0, 10),
        status: status,
        scanTime: scanTime,
        notes: notes,
      ));
    }
    _saveData();
    notifyListeners();
  }

  bool recordSavings(int studentId, String type, double amount, String notes) {
    final studentIndex = _students.indexWhere((s) => s.id == studentId);
    if (studentIndex < 0 || amount <= 0) return false;

    final student = _students[studentIndex];
    if (type == 'tarik' && student.balance < amount) {
      return false; // Insufficient balance
    }

    final newBalance = (type == 'setor') ? (student.balance + amount) : (student.balance - amount);
    student.balance = newBalance;

    final now = DateTime.now();
    final dateStr = "${now.day} Sep ${now.year} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

    _transactions.insert(0, SavingsTransaction(
      id: DateTime.now().millisecondsSinceEpoch,
      studentId: studentId,
      type: type,
      amount: amount,
      balanceAfter: newBalance,
      notes: notes.isNotEmpty ? notes : (type == 'setor' ? 'Setor Tabungan' : 'Tarik Tabungan'),
      date: dateStr,
    ));

    _saveData();
    notifyListeners();
    return true;
  }

  void addAnnouncement(String title, String content, String target, String category, {bool isUrgent = false}) {
    final now = DateTime.now();
    _announcements.insert(0, Announcement(
      id: DateTime.now().millisecondsSinceEpoch,
      title: title,
      content: content,
      targetAudience: target,
      category: category,
      author: 'KH. Ahmad Syafei, M.Pd.',
      date: "${now.day} Sep ${now.year}",
      isUrgent: isUrgent,
    ));
    _saveData();
    notifyListeners();
  }

  void addStudent(String nisn, String name, String gender, String className, String parentName, String parentPhone) {
    final newStudent = Student(
      id: DateTime.now().millisecondsSinceEpoch,
      nisn: nisn,
      name: name,
      gender: gender,
      className: className,
      parentName: parentName.isNotEmpty ? parentName : 'Wali Murid',
      parentPhone: parentPhone.isNotEmpty ? parentPhone : '-',
      balance: 0.0,
      qrCodeToken: 'MH-STD-$nisn',
    );
    _students.add(newStudent);
    _saveData();
    notifyListeners();
  }

  void _loadInitialData() {
    _students = [
      Student(id: 1, nisn: '0081234561', name: 'Ahmad Fauzi', gender: 'L', className: 'Kelas 7A', parentName: 'H. Rahmat', parentPhone: '081234567893', balance: 150000, qrCodeToken: 'MH-STD-0081234561'),
      Student(id: 2, nisn: '0081234562', name: 'Fatimah Az-Zahra', gender: 'P', className: 'Kelas 7A', parentName: 'M. Yusuf', parentPhone: '081234567894', balance: 275000, qrCodeToken: 'MH-STD-0081234562'),
      Student(id: 3, nisn: '0081234563', name: 'Muhammad Bilal', gender: 'L', className: 'Kelas 7A', parentName: 'Drs. Supriyanto', parentPhone: '081234567895', balance: 85000, qrCodeToken: 'MH-STD-0081234563'),
      Student(id: 4, nisn: '0081234564', name: 'Aisyah Humaira', gender: 'P', className: 'Kelas 7A', parentName: 'Agus Salim', parentPhone: '081234567896', balance: 320000, qrCodeToken: 'MH-STD-0081234564'),
      Student(id: 5, nisn: '0081234565', name: 'Zaid bin Tsabit', gender: 'L', className: 'Kelas 7A', parentName: 'Heri Irawan', parentPhone: '081234567897', balance: 60000, qrCodeToken: 'MH-STD-0081234565'),
      Student(id: 6, nisn: '0081234566', name: 'Khadijah Al-Kubro', gender: 'P', className: 'Kelas 7A', parentName: 'Bambang Sudiro', parentPhone: '081234567898', balance: 190000, qrCodeToken: 'MH-STD-0081234566'),
      Student(id: 7, nisn: '0081234567', name: 'Umar Al-Faruq', gender: 'L', className: 'Kelas 7A', parentName: 'H. Mansyur', parentPhone: '081234567899', balance: 110000, qrCodeToken: 'MH-STD-0081234567'),
      Student(id: 8, nisn: '0081234568', name: 'Maryam Syafira', gender: 'P', className: 'Kelas 7A', parentName: 'Suryono', parentPhone: '081234567800', balance: 450000, qrCodeToken: 'MH-STD-0081234568'),
    ];

    _attendances = [
      AttendanceRecord(studentId: 1, className: 'Kelas 7A', date: '2026-09-29', status: 'Hadir', scanTime: '06:55 WIB', notes: 'Tepat Waktu via QR'),
      AttendanceRecord(studentId: 2, className: 'Kelas 7A', date: '2026-09-29', status: 'Hadir', scanTime: '07:02 WIB', notes: 'Tepat Waktu via QR'),
      AttendanceRecord(studentId: 3, className: 'Kelas 7A', date: '2026-09-29', status: 'Sakit', scanTime: '-', notes: 'Surat dokter'),
      AttendanceRecord(studentId: 4, className: 'Kelas 7A', date: '2026-09-29', status: 'Hadir', scanTime: '07:05 WIB', notes: 'Tepat Waktu via QR'),
      AttendanceRecord(studentId: 5, className: 'Kelas 7A', date: '2026-09-29', status: 'Izin', scanTime: '-', notes: 'Acara keluarga'),
      AttendanceRecord(studentId: 6, className: 'Kelas 7A', date: '2026-09-29', status: 'Hadir', scanTime: '07:11 WIB', notes: 'Tepat Waktu via QR'),
      AttendanceRecord(studentId: 7, className: 'Kelas 7A', date: '2026-09-29', status: 'Alfa', scanTime: '-', notes: 'Belum scan'),
      AttendanceRecord(studentId: 8, className: 'Kelas 7A', date: '2026-09-29', status: 'Hadir', scanTime: '07:14 WIB', notes: 'Tepat Waktu via QR'),
    ];

    _announcements = [
      Announcement(id: 1, title: 'Pelaksanaan Penilaian Tengah Semester (PTS) Ganjil', content: 'Diberitahukan kepada seluruh Dewan Guru bahwa pelaksanaan PTS Ganjil dimulai Senin depan. Mohon rekap absensi kelas disiapkan.', targetAudience: 'teachers', category: 'Akademik', author: 'KH. Ahmad Syafei, M.Pd.', date: '28 Sep 2026', isUrgent: true),
      Announcement(id: 2, title: 'Himbauan Gerakan Menabung & Kartu Name Tag QR', content: 'Kepada seluruh Wali Murid, santri kini dilengkapi Name Tag Digital untuk presensi otomatis dan tabungan sekolah.', targetAudience: 'parents', category: 'Kegiatan', author: 'KH. Ahmad Syafei, M.Pd.', date: '27 Sep 2026', isUrgent: false),
      Announcement(id: 3, title: 'Peringatan Hari Besar Islam & Pengajian Santri', content: 'Kegiatan belajar mengajar diliburkan menyambut peringatan Maulid Nabi SAW di Masjid Utama.', targetAudience: 'all', category: 'Libur', author: 'KH. Ahmad Syafei, M.Pd.', date: '29 Sep 2026', isUrgent: false),
    ];

    _transactions = [
      SavingsTransaction(id: 1, studentId: 1, type: 'setor', amount: 50000, balanceAfter: 150000, notes: 'Uang saku mingguan', date: '29 Sep 2026 07:15'),
      SavingsTransaction(id: 2, studentId: 2, type: 'setor', amount: 100000, balanceAfter: 275000, notes: 'Setoran bulanan', date: '28 Sep 2026 09:30'),
      SavingsTransaction(id: 3, studentId: 3, type: 'tarik', amount: 20000, balanceAfter: 85000, notes: 'Beli kitab fiqih', date: '27 Sep 2026 10:15'),
      SavingsTransaction(id: 4, studentId: 4, type: 'setor', amount: 50000, balanceAfter: 320000, notes: 'Tabungan santri', date: '29 Sep 2026 07:30'),
    ];
  }

  void _saveData() {}
}
