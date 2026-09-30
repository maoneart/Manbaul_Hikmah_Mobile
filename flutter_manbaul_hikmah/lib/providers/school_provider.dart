import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:csv/csv.dart';
import '../models/student.dart';
import '../models/attendance.dart';
import '../models/savings.dart';
import '../models/announcement.dart';
import '../services/api_service.dart';
import '../utils/file_helper.dart';

class SchoolProvider with ChangeNotifier {
  bool _isLoggedIn = true;
  Map<String, dynamic>? _currentUser = {
    'id': 1,
    'username': 'kepsek',
    'name': 'KH. Ahmad Syafei, M.Pd.',
    'role': 'kepsek',
    'phone': '081234567890',
    'assigned_class': null,
  };

  String _currentRole = 'kepsek'; // 'admin', 'kepsek', 'wali_kelas', 'guru', 'wali_murid'
  String _activeClass = 'Kelas 7A';
  bool _isBalanceVisible = true;
  bool _isLoading = false;

  List<Student> _students = [];
  List<AttendanceRecord> _attendances = [];
  List<SavingsTransaction> _transactions = [];
  List<Announcement> _announcements = [];

  // ==========================================
  // DYNAMIC ROLE PERMISSIONS MATRIX
  // ==========================================
  final Map<String, Map<String, bool>> _rolePermissions = {
    'admin': {
      'add_student': true,
      'edit_student': true,
      'delete_student': true,
      'print_nametag': true,
      'scan_qr': true,
      'manual_attendance': true,
      'rekap_attendance': true,
      'deposit_savings': true,
      'withdraw_savings': true,
      'view_all_savings': true,
      'create_announcement': true,
      'broadcast_parent': true,
      'download_template': true,
      'export_data': true,
      'import_data': true,
    },
    'kepsek': {
      'add_student': true,
      'edit_student': true,
      'delete_student': true,
      'print_nametag': true,
      'scan_qr': true,
      'manual_attendance': true,
      'rekap_attendance': true,
      'deposit_savings': true,
      'withdraw_savings': true,
      'view_all_savings': true,
      'create_announcement': true,
      'broadcast_parent': true,
      'download_template': true,
      'export_data': true,
      'import_data': true,
    },
    'wali_kelas': {
      'add_student': true,
      'edit_student': true,
      'delete_student': false,
      'print_nametag': true,
      'scan_qr': true,
      'manual_attendance': true,
      'rekap_attendance': true,
      'deposit_savings': true,
      'withdraw_savings': true,
      'view_all_savings': true,
      'create_announcement': false,
      'broadcast_parent': true,
      'download_template': true,
      'export_data': true,
      'import_data': true,
    },
    'guru': {
      'add_student': false,
      'edit_student': false,
      'delete_student': false,
      'print_nametag': true,
      'scan_qr': true,
      'manual_attendance': true,
      'rekap_attendance': true,
      'deposit_savings': false,
      'withdraw_savings': false,
      'view_all_savings': false,
      'create_announcement': false,
      'broadcast_parent': false,
      'download_template': false,
      'export_data': false,
      'import_data': false,
    },
    'wali_murid': {
      'add_student': false,
      'edit_student': false,
      'delete_student': false,
      'print_nametag': false,
      'scan_qr': false,
      'manual_attendance': false,
      'rekap_attendance': false,
      'deposit_savings': false,
      'withdraw_savings': false,
      'view_all_savings': false,
      'create_announcement': false,
      'broadcast_parent': false,
      'download_template': false,
      'export_data': false,
      'import_data': false,
    },
  };

  bool get isLoggedIn => _isLoggedIn;
  Map<String, dynamic>? get currentUser => _currentUser;
  String get currentRole => _currentRole;
  String get activeClass => _activeClass;
  bool get isBalanceVisible => _isBalanceVisible;
  bool get isLoading => _isLoading;
  Map<String, Map<String, bool>> get rolePermissions => _rolePermissions;

  // Permission Verification Engine
  bool hasPermission(String permKey) {
    if (_currentRole == 'admin') return true;
    return _rolePermissions[_currentRole]?[permKey] ?? false;
  }

  bool checkRolePermission(String role, String permKey) {
    if (role == 'admin') return true;
    return _rolePermissions[role]?[permKey] ?? false;
  }

  void updateRolePermission(String role, String permKey, bool value) {
    if (role == 'admin') return; // Admin permissions are permanent
    if (_rolePermissions.containsKey(role)) {
      _rolePermissions[role]![permKey] = value;
      _savePreferences();
      notifyListeners();
    }
  }

  void resetPermissionsToDefault() {
    _rolePermissions['kepsek'] = {
      'add_student': true,
      'edit_student': true,
      'delete_student': true,
      'print_nametag': true,
      'scan_qr': true,
      'manual_attendance': true,
      'rekap_attendance': true,
      'deposit_savings': true,
      'withdraw_savings': true,
      'view_all_savings': true,
      'create_announcement': true,
      'broadcast_parent': true,
      'download_template': true,
      'export_data': true,
      'import_data': true,
    };
    _rolePermissions['wali_kelas'] = {
      'add_student': true,
      'edit_student': true,
      'delete_student': false,
      'print_nametag': true,
      'scan_qr': true,
      'manual_attendance': true,
      'rekap_attendance': true,
      'deposit_savings': true,
      'withdraw_savings': true,
      'view_all_savings': true,
      'create_announcement': false,
      'broadcast_parent': true,
      'download_template': true,
      'export_data': true,
      'import_data': true,
    };
    _rolePermissions['guru'] = {
      'add_student': false,
      'edit_student': false,
      'delete_student': false,
      'print_nametag': true,
      'scan_qr': true,
      'manual_attendance': true,
      'rekap_attendance': true,
      'deposit_savings': false,
      'withdraw_savings': false,
      'view_all_savings': false,
      'create_announcement': false,
      'broadcast_parent': false,
      'download_template': false,
      'export_data': false,
      'import_data': false,
    };
    _rolePermissions['wali_murid'] = {
      'add_student': false,
      'edit_student': false,
      'delete_student': false,
      'print_nametag': false,
      'scan_qr': false,
      'manual_attendance': false,
      'rekap_attendance': false,
      'deposit_savings': false,
      'withdraw_savings': false,
      'view_all_savings': false,
      'create_announcement': false,
      'broadcast_parent': false,
      'download_template': false,
      'export_data': false,
      'import_data': false,
    };
    _savePreferences();
    notifyListeners();
  }

  // Capability getters
  bool get canAddStudent => hasPermission('add_student');
  bool get canEditStudent => hasPermission('edit_student');
  bool get canDeleteStudent => hasPermission('delete_student');
  bool get canPrintNametag => hasPermission('print_nametag');
  bool get canScanQr => hasPermission('scan_qr');
  bool get canInputAttendance => hasPermission('manual_attendance');
  bool get canRekapAttendance => hasPermission('rekap_attendance');
  bool get canManageSavings => hasPermission('deposit_savings') || hasPermission('withdraw_savings');
  bool get canCreateAnnouncement => hasPermission('create_announcement');
  bool get canExportImport => hasPermission('export_data') || hasPermission('import_data');
  bool get canDownloadTemplate => hasPermission('download_template');

  List<Student> get students =>
      _students.where((s) => _activeClass == 'Semua' || s.className == _activeClass).toList();
  List<Student> get allStudents => _students;
  List<AttendanceRecord> get attendances => _attendances;
  List<SavingsTransaction> get transactions => _transactions;
  List<Announcement> get announcements => _announcements;

  SchoolProvider() {
    _loadInitialData();
    _loadPreferences();
    loadDataFromApi();
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isLoggedIn = prefs.getBool('is_logged_in') ?? true;
      final savedUser = prefs.getString('current_user');
      if (savedUser != null) {
        _currentUser = jsonDecode(savedUser);
        _currentRole = _currentUser?['role'] ?? 'kepsek';
        if (_currentUser?['assigned_class'] != null) {
          _activeClass = _currentUser!['assigned_class'];
        }
      }
      
      // Load saved permission matrix
      final savedPerms = prefs.getString('app_role_permissions_json');
      if (savedPerms != null) {
        final decoded = jsonDecode(savedPerms) as Map<String, dynamic>;
        for (final roleEntry in decoded.entries) {
          if (_rolePermissions.containsKey(roleEntry.key) && roleEntry.value is Map) {
            final map = roleEntry.value as Map<String, dynamic>;
            for (final permEntry in map.entries) {
              _rolePermissions[roleEntry.key]![permEntry.key] = permEntry.value == true;
            }
          }
        }
      }

      notifyListeners();
    } catch (_) {}
  }

  Future<void> _savePreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_logged_in', _isLoggedIn);
      if (_currentUser != null) {
        await prefs.setString('current_user', jsonEncode(_currentUser));
      }
      await prefs.setString('app_role_permissions_json', jsonEncode(_rolePermissions));
    } catch (_) {}
  }

  /// User Login (Support Live API & Local Fallback for Demo Accounts)
  Future<Map<String, dynamic>> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Try Live API Login
      final res = await ApiService.login(username, password);
      if (res['status'] == true && res['data'] is Map<String, dynamic>) {
        final userData = res['data'] as Map<String, dynamic>;
        _currentUser = userData;
        _currentRole = userData['role'] ?? 'wali_kelas';
        if (userData['assigned_class'] != null && userData['assigned_class'].toString().isNotEmpty) {
          _activeClass = userData['assigned_class'].toString();
        }
        _isLoggedIn = true;
        await _savePreferences();
        await loadDataFromApi();
        _isLoading = false;
        notifyListeners();
        return {'success': true, 'message': res['message'] ?? 'Login berhasil'};
      }
    } catch (_) {}

    // 2. Fallback Demo Accounts
    final demoUsers = {
      'admin': {'name': 'Hermawan (Super Admin)', 'role': 'admin', 'class': null, 'phone': '081299999999'},
      'kepsek': {'name': 'KH. Ahmad Syafei, M.Pd.', 'role': 'kepsek', 'class': null, 'phone': '081234567890'},
      'walikelas7a': {'name': 'Ustadz Budi Santoso, S.Pd.', 'role': 'wali_kelas', 'class': 'Kelas 7A', 'phone': '081234567891'},
      'walikelas7b': {'name': 'Ustadzah Siti Aminah, S.Pd.I.', 'role': 'wali_kelas', 'class': 'Kelas 7B', 'phone': '081234567892'},
      'guru': {'name': 'Ustadz Hendra Pratama, S.Pd.', 'role': 'guru', 'class': 'Kelas 8A', 'phone': '081234567895'},
      'ortu_ahmad': {'name': 'Bpk. H. Rahmat (Wali Ahmad)', 'role': 'wali_murid', 'class': 'Kelas 7A', 'phone': '081234567893'},
    };

    final u = username.toLowerCase().trim();
    if (demoUsers.containsKey(u)) {
      final info = demoUsers[u]!;
      _currentUser = {
        'id': u.hashCode,
        'username': u,
        'name': info['name'],
        'role': info['role'],
        'phone': info['phone'],
        'assigned_class': info['class'],
      };
      _currentRole = info['role']!;
      if (info['class'] != null) {
        _activeClass = info['class']!;
      }
      _isLoggedIn = true;
      await _savePreferences();
      _isLoading = false;
      notifyListeners();
      return {'success': true, 'message': 'Masuk sebagai ${info['name']} (Mode Demo/Offline)'};
    }

    _isLoading = false;
    notifyListeners();
    return {'success': false, 'message': 'Username atau password tidak cocok'};
  }

  void logout() {
    _isLoggedIn = false;
    _currentUser = null;
    _savePreferences();
    notifyListeners();
  }

  void updateProfile(String name, String phone) {
    if (_currentUser != null) {
      _currentUser!['name'] = name;
      _currentUser!['phone'] = phone;
      _savePreferences();
      notifyListeners();
    }
  }

  void toggleBalanceVisibility() {
    _isBalanceVisible = !_isBalanceVisible;
    notifyListeners();
  }

  void switchRole(String role) {
    _currentRole = role;
    if (_currentUser != null) {
      _currentUser!['role'] = role;
    }
    _savePreferences();
    notifyListeners();
  }

  void switchClass(String className) {
    _activeClass = className;
    notifyListeners();
    _loadAttendanceForClass(className);
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

  /// Load fresh data from Shared Hosting REST API
  Future<void> loadDataFromApi() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Fetch Students
      final fetchedStudents = await ApiService.getStudents();
      if (fetchedStudents.isNotEmpty) {
        _students = fetchedStudents;
      }

      // 2. Fetch Attendance for Active Class
      await _loadAttendanceForClass(_activeClass == 'Semua' ? 'Kelas 7A' : _activeClass);

      // 3. Fetch Savings Summary & Transactions
      final savingsData = await ApiService.getSavingsSummary();
      if (savingsData['success'] == true && savingsData['transactions'] is List<SavingsTransaction>) {
        final transList = savingsData['transactions'] as List<SavingsTransaction>;
        if (transList.isNotEmpty) {
          _transactions = transList;
        }
      }

      // 4. Fetch Announcements
      final fetchedAnnouncements = await ApiService.getAnnouncements();
      if (fetchedAnnouncements.isNotEmpty) {
        _announcements = fetchedAnnouncements;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading data from API: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadAttendanceForClass(String className) async {
    try {
      final attResult = await ApiService.getTodayAttendance(className: className);
      if (attResult['success'] == true && attResult['records'] is List<AttendanceRecord>) {
        final records = attResult['records'] as List<AttendanceRecord>;
        for (final rec in records) {
          final idx = _attendances.indexWhere((a) => a.studentId == rec.studentId);
          if (idx >= 0) {
            _attendances[idx] = rec;
          } else {
            _attendances.add(rec);
          }
        }
        notifyListeners();
      }
    } catch (_) {}
  }

  /// Scan QR Code Attendance
  String scanQrCode(String qrToken) {
    Student? student;
    try {
      student = _students.firstWhere(
        (s) => s.qrCodeToken == qrToken || s.nisn == qrToken || 'MH-STD-${s.nisn}' == qrToken,
      );
    } catch (_) {
      student = null;
    }

    final now = DateTime.now();
    final timeStr =
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} WIB";

    if (student != null) {
      markAttendance(student.id, 'Hadir', scanTime: timeStr, notes: 'Presensi Scan QR');
      ApiService.scanQrAttendance(qrToken: qrToken).then((res) {
        if (res['status'] == true) {
          loadDataFromApi();
        }
      });
      return "Berhasil Absen: ${student.name} (${student.className})";
    } else {
      ApiService.scanQrAttendance(qrToken: qrToken).then((res) {
        if (res['status'] == true) {
          loadDataFromApi();
        }
      });
      return "Presensi QR diproses: $qrToken";
    }
  }

  /// Mark Attendance Manual
  void markAttendance(int studentId, String status, {String? scanTime, String notes = ''}) {
    final index = _attendances.indexWhere((a) => a.studentId == studentId);
    if (index >= 0) {
      _attendances[index].status = status;
      if (scanTime != null) _attendances[index].scanTime = scanTime;
      if (notes.isNotEmpty) _attendances[index].notes = notes;
    } else {
      final studentList = _students.where((s) => s.id == studentId).toList();
      final className = studentList.isNotEmpty ? studentList.first.className : _activeClass;
      _attendances.add(AttendanceRecord(
        studentId: studentId,
        className: className,
        date: DateTime.now().toIso8601String().substring(0, 10),
        status: status,
        scanTime: scanTime,
        notes: notes,
      ));
    }
    notifyListeners();

    ApiService.markAttendance(
      studentId: studentId,
      status: status,
      notes: notes,
    ).then((res) {
      if (res['status'] == true) {
        _loadAttendanceForClass(_activeClass == 'Semua' ? 'Kelas 7A' : _activeClass);
      }
    });
  }

  /// Record Savings Transaction (Setor / Tarik)
  bool recordSavings(int studentId, String type, double amount, String notes) {
    final studentIndex = _students.indexWhere((s) => s.id == studentId);
    if (studentIndex < 0 || amount <= 0) return false;

    final student = _students[studentIndex];
    if (type == 'tarik' && student.balance < amount) {
      return false;
    }

    final newBalance = (type == 'setor') ? (student.balance + amount) : (student.balance - amount);
    student.balance = newBalance;

    final now = DateTime.now();
    final dateStr =
        "${now.day} Sep ${now.year} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

    _transactions.insert(
      0,
      SavingsTransaction(
        id: DateTime.now().millisecondsSinceEpoch,
        studentId: studentId,
        type: type,
        amount: amount,
        balanceAfter: newBalance,
        notes: notes.isNotEmpty ? notes : (type == 'setor' ? 'Setor Tabungan' : 'Tarik Tabungan'),
        date: dateStr,
      ),
    );

    notifyListeners();

    ApiService.recordSavings(
      studentId: studentId,
      type: type,
      amount: amount,
      notes: notes,
    ).then((res) {
      if (res['status'] == true) {
        ApiService.getStudents().then((sList) {
          if (sList.isNotEmpty) {
            _students = sList;
            notifyListeners();
          }
        });
      }
    });

    return true;
  }

  /// Add Announcement
  void addAnnouncement(String title, String content, String target, String category,
      {bool isUrgent = false}) {
    final now = DateTime.now();
    _announcements.insert(
      0,
      Announcement(
        id: DateTime.now().millisecondsSinceEpoch,
        title: title,
        content: content,
        targetAudience: target,
        category: category,
        author: _currentUser?['name'] ?? 'Kepala Sekolah',
        date: "${now.day} Sep ${now.year}",
        isUrgent: isUrgent,
      ),
    );
    notifyListeners();

    ApiService.addAnnouncement(
      title: title,
      content: content,
      targetAudience: target,
      category: category,
      isUrgent: isUrgent,
    ).then((res) {
      if (res['status'] == true) {
        ApiService.getAnnouncements().then((aList) {
          if (aList.isNotEmpty) {
            _announcements = aList;
            notifyListeners();
          }
        });
      }
    });
  }

  // ==========================================
  // STUDENT FULL CRUD OPERATIONS
  // ==========================================

  /// 1. Create Student
  Future<bool> addStudent(String nisn, String name, String gender, String className, String parentName,
      String parentPhone) async {
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
    notifyListeners();

    final res = await ApiService.addStudent(
      nisn: nisn,
      name: name,
      gender: gender,
      className: className,
      parentName: parentName,
      parentPhone: parentPhone,
    );

    if (res['status'] == true) {
      final sList = await ApiService.getStudents();
      if (sList.isNotEmpty) {
        _students = sList;
        notifyListeners();
      }
      return true;
    }
    return true;
  }

  /// 2. Update Student
  Future<bool> updateStudent({
    required int id,
    required String name,
    required String gender,
    required String className,
    required String parentName,
    required String parentPhone,
  }) async {
    final idx = _students.indexWhere((s) => s.id == id);
    if (idx >= 0) {
      _students[idx] = Student(
        id: id,
        nisn: _students[idx].nisn,
        name: name,
        gender: gender,
        className: className,
        parentName: parentName,
        parentPhone: parentPhone,
        balance: _students[idx].balance,
        qrCodeToken: _students[idx].qrCodeToken,
      );
      notifyListeners();
    }

    final res = await ApiService.updateStudent(
      id: id,
      name: name,
      gender: gender,
      className: className,
      parentName: parentName,
      parentPhone: parentPhone,
    );

    if (res['status'] == true) {
      final sList = await ApiService.getStudents();
      if (sList.isNotEmpty) {
        _students = sList;
        notifyListeners();
      }
      return true;
    }
    return true;
  }

  /// 3. Delete Student
  Future<bool> deleteStudent(int id) async {
    _students.removeWhere((s) => s.id == id);
    _attendances.removeWhere((a) => a.studentId == id);
    _transactions.removeWhere((t) => t.studentId == id);
    notifyListeners();

    final res = await ApiService.deleteStudent(id);
    if (res['status'] == true) {
      final sList = await ApiService.getStudents();
      if (sList.isNotEmpty) {
        _students = sList;
        notifyListeners();
      }
      return true;
    }
    return true;
  }

  // ==========================================
  // EXCEL / CSV IMPORT & EXPORT GENERATORS
  // ==========================================

  /// Generate CSV formatted string for all Students (Excel compatible)
  String exportStudentsToCsv() {
    final rows = <List<dynamic>>[];
    rows.add(['NISN', 'Nama Lengkap', 'Jenis Kelamin', 'Kelas', 'Nama Wali', 'No HP Wali', 'Saldo Tabungan (Rp)', 'Token QR Code']);
    for (final s in _students) {
      rows.add([
        s.nisn,
        s.name,
        s.gender == 'L' ? 'Laki-laki' : 'Perempuan',
        s.className,
        s.parentName,
        s.parentPhone,
        s.balance.toStringAsFixed(0),
        s.qrCodeToken,
      ]);
    }
    return const ListToCsvConverter().convert(rows);
  }

  /// Generate CSV formatted string for Attendance Rekap (Excel compatible)
  String exportAttendanceToCsv() {
    final rows = <List<dynamic>>[];
    rows.add(['Tanggal', 'NISN', 'Nama Siswa', 'Kelas', 'Status Kehadiran', 'Waktu Scan', 'Keterangan']);
    for (final att in _attendances) {
      final student = _students.firstWhere(
        (s) => s.id == att.studentId,
        orElse: () => Student(
          id: att.studentId,
          nisn: '-',
          name: 'Siswa #${att.studentId}',
          gender: 'L',
          className: att.className,
          parentName: '-',
          parentPhone: '-',
          balance: 0,
          qrCodeToken: '-',
        ),
      );
      rows.add([
        att.date,
        student.nisn,
        student.name,
        att.className,
        att.status,
        att.scanTime ?? '-',
        att.notes,
      ]);
    }
    return const ListToCsvConverter().convert(rows);
  }

  /// Template CSV for importing student data into system
  String getStudentImportTemplateCsv() {
    final rows = <List<dynamic>>[];
    rows.add(['nisn', 'nama', 'jenis_kelamin', 'kelas', 'nama_wali', 'no_hp_wali', 'saldo_awal']);
    rows.add(['0081234570', 'Muhammad Rizky Pratama', 'L', 'Kelas 7A', 'H. Bambang', '081234567801', '50000']);
    rows.add(['0081234571', 'Nurul Aulia Rahman', 'P', 'Kelas 7A', 'Ibu Maryam', '081234567802', '100000']);
    return const ListToCsvConverter().convert(rows);
  }

  /// Helper to generate pure SpreadsheetML XML for Microsoft Excel (.xlsx/.xml)
  String _generateSpreadsheetXml({
    required String sheetName,
    required List<String> headers,
    required List<List<dynamic>> rows,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('<?xml version="1.0" encoding="UTF-8"?>');
    buffer.writeln('<?mso-application progid="Excel.Sheet"?>');
    buffer.writeln('<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet"');
    buffer.writeln(' xmlns:o="urn:schemas-microsoft-com:office:office"');
    buffer.writeln(' xmlns:x="urn:schemas-microsoft-com:office:excel"');
    buffer.writeln(' xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet">');
    buffer.writeln(' <Worksheet ss:Name="$sheetName">');
    buffer.writeln('  <Table>');

    // Headers
    buffer.writeln('   <Row>');
    for (final h in headers) {
      buffer.writeln('    <Cell><Data ss:Type="String">${_escapeXml(h)}</Data></Cell>');
    }
    buffer.writeln('   </Row>');

    // Rows
    for (final row in rows) {
      buffer.writeln('   <Row>');
      for (final val in row) {
        final str = val?.toString() ?? '';
        final isNum = num.tryParse(str) != null && !str.startsWith('0');
        if (isNum) {
          buffer.writeln('    <Cell><Data ss:Type="Number">$str</Data></Cell>');
        } else {
          buffer.writeln('    <Cell><Data ss:Type="String">${_escapeXml(str)}</Data></Cell>');
        }
      }
      buffer.writeln('   </Row>');
    }

    buffer.writeln('  </Table>');
    buffer.writeln(' </Worksheet>');
    buffer.writeln('</Workbook>');
    return buffer.toString();
  }

  String _escapeXml(String input) {
    return input
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;');
  }

  /// Save Student Import Template directly to /sdcard/Download
  Future<Map<String, dynamic>> saveStudentTemplateToDownloads() async {
    final csvContent = getStudentImportTemplateCsv();
    final xmlContent = _generateSpreadsheetXml(
      sheetName: 'Template Import Santri',
      headers: ['nisn', 'nama', 'jenis_kelamin', 'kelas', 'nama_wali', 'no_hp_wali', 'saldo_awal'],
      rows: [
        ['0081234570', 'Muhammad Rizky Pratama', 'L', 'Kelas 7A', 'H. Bambang', '081234567801', '50000'],
        ['0081234571', 'Nurul Aulia Rahman', 'P', 'Kelas 7A', 'Ibu Maryam', '081234567802', '100000'],
        ['0081234572', 'Ahmad Dhani Al-Ghazali', 'L', 'Kelas 7B', 'H. Syafiq', '081234567803', '75000'],
      ],
    );

    const basePath = '/sdcard/Download';
    final hasFolder = await FileHelper.directoryExists(basePath);

    if (hasFolder) {
      await FileHelper.saveString('$basePath/Template_Import_Siswa_Manbaul_Hikmah.xlsx', xmlContent);
      await FileHelper.saveString('$basePath/Template_Import_Siswa_Manbaul_Hikmah.csv', '\uFEFF$csvContent');
      return {
        'success': true,
        'path': '$basePath/Template_Import_Siswa_Manbaul_Hikmah.xlsx',
        'csv': csvContent,
      };
    }

    return {
      'success': false,
      'csv': csvContent,
    };
  }

  /// Save Students Export to /sdcard/Download
  Future<Map<String, dynamic>> saveStudentsExportToDownloads() async {
    final csvContent = exportStudentsToCsv();
    final rows = <List<dynamic>>[];
    for (final s in _students) {
      rows.add([
        s.nisn,
        s.name,
        s.gender == 'L' ? 'Laki-laki' : 'Perempuan',
        s.className,
        s.parentName,
        s.parentPhone,
        s.balance.toStringAsFixed(0),
        s.qrCodeToken,
      ]);
    }
    final xmlContent = _generateSpreadsheetXml(
      sheetName: 'Data Santri Manbaul Hikmah',
      headers: ['NISN', 'Nama Lengkap', 'Jenis Kelamin', 'Kelas', 'Nama Wali', 'No HP Wali', 'Saldo Tabungan (Rp)', 'Token QR Code'],
      rows: rows,
    );

    const basePath = '/sdcard/Download';
    final hasFolder = await FileHelper.directoryExists(basePath);

    if (hasFolder) {
      await FileHelper.saveString('$basePath/Data_Siswa_Manbaul_Hikmah.xlsx', xmlContent);
      await FileHelper.saveString('$basePath/Data_Siswa_Manbaul_Hikmah.csv', '\uFEFF$csvContent');
      return {
        'success': true,
        'path': '$basePath/Data_Siswa_Manbaul_Hikmah.xlsx',
        'csv': csvContent,
      };
    }

    return {
      'success': false,
      'csv': csvContent,
    };
  }

  /// Import Students from CSV text
  Future<Map<String, dynamic>> importStudentsFromCsv(String csvData) async {
    try {
      final rows = const CsvToListConverter().convert(csvData);
      if (rows.isEmpty || rows.length < 2) {
        return {'success': false, 'message': 'Format CSV kosong atau tidak memiliki data baris'};
      }

      int successCount = 0;
      // Skip header row
      for (int i = 1; i < rows.length; i++) {
        final row = rows[i];
        if (row.length < 4) continue;

        final nisn = row[0].toString().trim();
        final name = row[1].toString().trim();
        final gender = (row[2].toString().toUpperCase().startsWith('P')) ? 'P' : 'L';
        final className = row[3].toString().trim().isNotEmpty ? row[3].toString().trim() : _activeClass;
        final parentName = (row.length > 4 && row[4] != null) ? row[4].toString().trim() : 'Wali Murid';
        final parentPhone = (row.length > 5 && row[5] != null) ? row[5].toString().trim() : '-';
        final balance = (row.length > 6 && row[6] != null) ? (double.tryParse(row[6].toString()) ?? 0.0) : 0.0;

        if (nisn.isEmpty || name.isEmpty) continue;

        // Check if student exists locally
        final existingIdx = _students.indexWhere((s) => s.nisn == nisn);
        if (existingIdx >= 0) {
          _students[existingIdx] = Student(
            id: _students[existingIdx].id,
            nisn: nisn,
            name: name,
            gender: gender,
            className: className,
            parentName: parentName,
            parentPhone: parentPhone,
            balance: balance > 0 ? balance : _students[existingIdx].balance,
            qrCodeToken: 'MH-STD-$nisn',
          );
        } else {
          _students.add(Student(
            id: DateTime.now().millisecondsSinceEpoch + i,
            nisn: nisn,
            name: name,
            gender: gender,
            className: className,
            parentName: parentName,
            parentPhone: parentPhone,
            balance: balance,
            qrCodeToken: 'MH-STD-$nisn',
          ));
        }

        // Push to server in background
        ApiService.addStudent(
          nisn: nisn,
          name: name,
          gender: gender,
          className: className,
          parentName: parentName,
          parentPhone: parentPhone,
          balance: balance,
        );
        successCount++;
      }

      notifyListeners();
      return {'success': true, 'count': successCount, 'message': 'Berhasil mengimpor $successCount data siswa'};
    } catch (e) {
      return {'success': false, 'message': 'Gagal mengimpor file CSV: $e'};
    }
  }

  /// Initial fallback offline data
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
      AttendanceRecord(studentId: 1, className: 'Kelas 7A', date: '2026-09-30', status: 'Hadir', scanTime: '06:55 WIB', notes: 'Tepat Waktu via QR'),
      AttendanceRecord(studentId: 2, className: 'Kelas 7A', date: '2026-09-30', status: 'Hadir', scanTime: '07:02 WIB', notes: 'Tepat Waktu via QR'),
      AttendanceRecord(studentId: 3, className: 'Kelas 7A', date: '2026-09-30', status: 'Sakit', scanTime: '-', notes: 'Surat dokter'),
      AttendanceRecord(studentId: 4, className: 'Kelas 7A', date: '2026-09-30', status: 'Hadir', scanTime: '07:05 WIB', notes: 'Tepat Waktu via QR'),
      AttendanceRecord(studentId: 5, className: 'Kelas 7A', date: '2026-09-30', status: 'Izin', scanTime: '-', notes: 'Acara keluarga'),
      AttendanceRecord(studentId: 6, className: 'Kelas 7A', date: '2026-09-30', status: 'Hadir', scanTime: '07:11 WIB', notes: 'Tepat Waktu via QR'),
      AttendanceRecord(studentId: 7, className: 'Kelas 7A', date: '2026-09-30', status: 'Alfa', scanTime: '-', notes: 'Belum scan'),
      AttendanceRecord(studentId: 8, className: 'Kelas 7A', date: '2026-09-30', status: 'Hadir', scanTime: '07:14 WIB', notes: 'Tepat Waktu via QR'),
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
}
