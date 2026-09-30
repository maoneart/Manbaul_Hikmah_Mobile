import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:csv/csv.dart';
import '../models/student.dart';
import '../models/attendance.dart';
import '../models/savings.dart';
import '../models/announcement.dart';
import '../models/schedule.dart';
import '../models/payment_bill.dart';
import '../models/school_class.dart';
import '../services/api_service.dart';
import '../utils/file_helper.dart';

class SchoolProvider with ChangeNotifier {
  bool _isLoggedIn = false;
  Map<String, dynamic>? _currentUser;

  String _currentRole = 'wali_kelas'; // 'admin', 'kepsek', 'staff', 'wali_kelas', 'guru', 'wali_murid'
  String _activeClass = 'Kelas 7A';
  bool _isBalanceVisible = true;
  bool _isLoading = false;
  int? _selectedChildId;

  List<Student> _students = [];
  List<AttendanceRecord> _attendances = [];
  List<SavingsTransaction> _transactions = [];
  List<Announcement> _announcements = [];
  List<SchoolSchedule> _schedules = [];
  List<PaymentBill> _bills = [];
  List<SchoolClass> _classes = [];

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
    'staff': {
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
      'create_announcement': false,
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
    _rolePermissions['staff'] = {
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
      'create_announcement': false,
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

  /// Mendapatkan daftar semua anak yang terhubung dengan akun Wali Murid (Multi-Anak)
  List<Student> get myChildren {
    if (_currentUser == null) return [];
    final List<Student> result = [];
    final studentId = _currentUser!['student_id'];
    final phone = _currentUser!['phone']?.toString();

    for (final s in _students) {
      bool isMatch = false;
      if (studentId != null && s.id == int.tryParse(studentId.toString())) {
        isMatch = true;
      } else if (phone != null && phone.isNotEmpty && s.parentPhone == phone) {
        isMatch = true;
      }
      if (isMatch && !result.any((x) => x.id == s.id)) {
        result.add(s);
      }
    }

    if (result.isEmpty && _currentRole == 'wali_murid' && _students.isNotEmpty) {
      result.add(_students.first);
    }
    return result;
  }

  /// Mendapatkan data siswa/anak yang aktif dipilih oleh Wali Murid
  Student? get myChildStudent {
    final children = myChildren;
    if (children.isEmpty) return null;
    if (_selectedChildId != null) {
      final found = children.where((s) => s.id == _selectedChildId).toList();
      if (found.isNotEmpty) return found.first;
    }
    return children.first;
  }

  int? get selectedChildId => myChildStudent?.id;

  /// Memilih anak aktif (Child Switcher)
  void selectChild(int studentId) {
    _selectedChildId = studentId;
    final child = myChildStudent;
    if (child != null) {
      _activeClass = child.className;
    }
    notifyListeners();
  }

  /// Siswa aktif: Wali murid HANYA boleh mengakses data anaknya sendiri!
  List<Student> get students {
    if (_currentRole == 'wali_murid') {
      final child = myChildStudent;
      return child != null ? [child] : [];
    }
    return _students.where((s) => _activeClass == 'Semua' || s.className == _activeClass).toList();
  }

  List<Student> get allStudents {
    if (_currentRole == 'wali_murid') {
      final child = myChildStudent;
      return child != null ? [child] : [];
    }
    return _students;
  }
  List<AttendanceRecord> get attendances => _attendances;
  List<SchoolSchedule> get schedules => _schedules;
  List<PaymentBill> get bills => _bills;
  List<SchoolClass> get classes => _classes;
  List<String> get classNames => _classes.map((c) => c.name).toList();
  List<SavingsTransaction> get transactions => _transactions;
  double get totalAllSavings => _students.fold(0.0, (sum, s) => sum + s.balance);
  List<Announcement> get announcements {
    final role = _currentRole;
    if (role == 'admin' || role == 'kepsek') {
      return _announcements;
    }
    if (role == 'staff') {
      return _announcements
          .where((a) => a.targetAudience == 'all' || a.targetAudience == 'teachers')
          .toList();
    }
    if (role == 'wali_kelas') {
      return _announcements
          .where((a) => a.targetAudience == 'all' || a.targetAudience == 'walikelas')
          .toList();
    }
    if (role == 'guru') {
      return _announcements
          .where((a) => a.targetAudience == 'all' || a.targetAudience == 'teachers')
          .toList();
    }
    if (role == 'wali_murid') {
      return _announcements
          .where((a) => a.targetAudience == 'all' || a.targetAudience == 'parents')
          .toList();
    }
    return _announcements.where((a) => a.targetAudience == 'all').toList();
  }

  SchoolProvider() {
    _loadInitialData();
    _loadPreferences();
    loadDataFromApi();
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isLoggedIn = prefs.getBool('is_logged_in') ?? false;
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
      'admin': {'name': 'Hermawan (Super Admin)', 'role': 'admin', 'class': null, 'phone': '081299999999', 'student_id': null},
      'kepsek': {'name': 'KH. Ahmad Syafei, M.Pd.', 'role': 'kepsek', 'class': null, 'phone': '081234567890', 'student_id': null},
      'staff': {'name': 'Hj. Maryam, S.E. (Staff TU)', 'role': 'staff', 'class': null, 'phone': '081298765432', 'student_id': null},
      'walikelas1a': {'name': 'Ustadzah Fatimah, S.Pd.', 'role': 'wali_kelas', 'class': 'Kelas 1A', 'phone': '081234567894', 'student_id': null},
      'walikelas7a': {'name': 'Ustadz Budi Santoso, S.Pd.', 'role': 'wali_kelas', 'class': 'Kelas 7A', 'phone': '081234567891', 'student_id': null},
      'walikelas7b': {'name': 'Ustadzah Siti Aminah, S.Pd.I.', 'role': 'wali_kelas', 'class': 'Kelas 7B', 'phone': '081234567892', 'student_id': null},
      'guru': {'name': 'Ustadz Hendra Pratama, S.Pd.', 'role': 'guru', 'class': null, 'phone': '081234567895', 'student_id': null},
      'ortu_ahmad': {'name': 'Bpk. H. Rahmat (Wali Murid)', 'role': 'wali_murid', 'class': 'Kelas 1A', 'phone': '081234567893', 'student_id': 1},
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
        'student_id': info['student_id'],
      };
      _currentRole = info['role']!.toString();
      if (info['class'] != null) {
        _activeClass = info['class']!.toString();
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

  AttendanceRecord? getStudentAttendance(int studentId, {String? date}) {
    final targetDate = date ?? DateTime.now().toIso8601String().substring(0, 10);
    try {
      return _attendances.firstWhere((a) => a.studentId == studentId && a.date == targetDate);
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

      // 5. Fetch Payment & SPP Bills
      final fetchedBills = await ApiService.getPaymentBills();
      if (fetchedBills.isNotEmpty) {
        _bills = fetchedBills;
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
          final idx = _attendances.indexWhere((a) => a.studentId == rec.studentId && a.date == rec.date);
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

  /// Mark Attendance Manual with flexible Date
  void markAttendance(int studentId, String status, {String? scanTime, String notes = '', String? date}) {
    final targetDate = date ?? DateTime.now().toIso8601String().substring(0, 10);
    final index = _attendances.indexWhere((a) => a.studentId == studentId && a.date == targetDate);
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
        date: targetDate,
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
      date: targetDate,
    ).then((res) {
      if (res['status'] == true) {
        _loadAttendanceForClass(_activeClass == 'Semua' ? 'Kelas 7A' : _activeClass);
      }
    });
  }

  /// Quick SOP: Tandai Semua Siswa Hadir Kolektif (Untuk Wali Kelas)
  void markAllPresent({String? date}) {
    final targetDate = date ?? DateTime.now().toIso8601String().substring(0, 10);
    for (final s in students) {
      final index = _attendances.indexWhere((a) => a.studentId == s.id && a.date == targetDate);
      if (index >= 0) {
        _attendances[index].status = 'Hadir';
        if (_attendances[index].scanTime == null || _attendances[index].scanTime == '-') {
          _attendances[index].scanTime = '07:00 WIB';
        }
      } else {
        _attendances.add(AttendanceRecord(
          studentId: s.id,
          className: s.className,
          date: targetDate,
          status: 'Hadir',
          scanTime: '07:00 WIB',
          notes: 'Presensi Kolektif',
        ));
      }
    }
    notifyListeners();
  }

  /// Generate Format WhatsApp Laporan Kehadiran Kelas Resmi
  String generateWhatsAppAttendanceReport({String? date}) {
    final targetDate = date ?? DateTime.now().toIso8601String().substring(0, 10);
    final classStudents = students;
    final total = classStudents.length;

    int hadir = 0;
    List<String> sakitList = [];
    List<String> izinList = [];
    List<String> alfaList = [];

    for (final s in classStudents) {
      final att = getStudentAttendance(s.id, date: targetDate);
      final st = att?.status ?? 'Alfa';
      final reason = (att?.notes != null && att!.notes.isNotEmpty) ? " (${att.notes})" : "";

      if (st == 'Hadir') {
        hadir++;
      } else if (st == 'Sakit') {
        sakitList.add("- ${s.name}$reason");
      } else if (st == 'Izin') {
        izinList.add("- ${s.name}$reason");
      } else {
        alfaList.add("- ${s.name}");
      }
    }

    final buffer = StringBuffer();
    buffer.writeln("📢 *LAPORAN PRESENSI ${_activeClass.toUpperCase()}*");
    buffer.writeln("🏫 *SDIT Manbaul Hikmah*");
    buffer.writeln("🗓️ *Tanggal:* $targetDate");
    buffer.writeln("--------------------------------");
    buffer.writeln("👥 *Total Siswa:* $total Siswa");
    buffer.writeln("✅ *Hadir:* $hadir Siswa");
    buffer.writeln("🤒 *Sakit:* ${sakitList.length} Siswa");
    if (sakitList.isNotEmpty) {
      buffer.writeln(sakitList.join("\n"));
    }
    buffer.writeln("📝 *Izin:* ${izinList.length} Siswa");
    if (izinList.isNotEmpty) {
      buffer.writeln(izinList.join("\n"));
    }
    buffer.writeln("❌ *Alfa / Tanpa Keterangan:* ${alfaList.length} Siswa");
    if (alfaList.isNotEmpty) {
      buffer.writeln(alfaList.join("\n"));
    }
    buffer.writeln("--------------------------------");
    buffer.writeln("Wali Kelas: ${_currentUser?['name'] ?? 'Ustadz/Ustadzah'}");
    return buffer.toString();
  }

  /// Wali Murid: Mengajukan / Mengirimkan Surat Izin atau Sakit untuk Anaknya Sendiri
  void submitChildAbsence({
    required String date,
    required String status,
    required String notes,
  }) {
    final child = myChildStudent;
    if (child == null) return;
    final parentName = _currentUser?['name'] ?? 'Wali Murid';
    final notesFormatted = notes.isNotEmpty ? 'Surat Wali ($parentName): $notes' : 'Surat Permohonan Wali ($parentName)';
    markAttendance(
      child.id,
      status,
      notes: notesFormatted,
      date: date,
    );
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

  /// Pay School Bill (SPP, Gedung, Seragam, dll)
  Future<bool> paySchoolBill(int billId, String method) async {
    final index = _bills.indexWhere((b) => b.id == billId);
    if (index < 0) return false;

    final bill = _bills[index];
    if (method == 'EduPay Tabungan') {
      final studentIndex = _students.indexWhere((s) => s.id == bill.studentId);
      if (studentIndex >= 0) {
        final student = _students[studentIndex];
        if (student.balance < bill.amount) {
          return false;
        }
        student.balance -= bill.amount;
        _transactions.insert(
          0,
          SavingsTransaction(
            id: DateTime.now().millisecondsSinceEpoch,
            studentId: bill.studentId,
            type: 'tarik',
            amount: bill.amount,
            balanceAfter: student.balance,
            notes: 'Bayar ${bill.category} ${bill.month != null ? "(${bill.month})" : ""}',
            date: "${DateTime.now().day} Sep ${DateTime.now().year}",
          ),
        );
      }
    }

    final now = DateTime.now();
    bill.status = 'Lunas';
    bill.paidAmount = bill.amount;
    bill.paidDate = "${now.day} Sep ${now.year} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
    bill.paymentMethod = method;
    notifyListeners();

    ApiService.paySchoolBill(billId: billId, paymentMethod: method);
    return true;
  }

  /// Add new Payment Bill (Staff TU / Kepsek)
  void addPaymentBill({
    required int studentId,
    required String category,
    String? month,
    required double amount,
  }) {
    final studentList = _students.where((s) => s.id == studentId).toList();
    final studentName = studentList.isNotEmpty ? studentList.first.name : 'Siswa';
    final className = studentList.isNotEmpty ? studentList.first.className : _activeClass;
    final now = DateTime.now();

    _bills.insert(
      0,
      PaymentBill(
        id: DateTime.now().millisecondsSinceEpoch,
        studentId: studentId,
        studentName: studentName,
        className: className,
        category: category,
        month: month,
        amount: amount,
        status: 'Belum Lunas',
        dueDate: "10 ${month ?? 'Okt'} 2026",
        invoiceNumber: "MH-BILL-${now.millisecondsSinceEpoch.toString().substring(7)}",
      ),
    );
    notifyListeners();
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
  Future<bool> addStudent(
    String nisn,
    String name,
    String gender,
    String className,
    String parentName,
    String parentPhone, {
    double balance = 0.0,
    String address = '-',
    String entryYear = '2024',
    String status = 'Aktif',
    String birthPlaceDate = '-',
  }) async {
    final newStudent = Student(
      id: DateTime.now().millisecondsSinceEpoch,
      nisn: nisn,
      name: name,
      gender: gender,
      className: className,
      parentName: parentName.isNotEmpty ? parentName : 'Wali Murid',
      parentPhone: parentPhone.isNotEmpty ? parentPhone : '-',
      balance: balance,
      qrCodeToken: 'MH-STD-$nisn',
      address: address.isNotEmpty ? address : '-',
      entryYear: entryYear.isNotEmpty ? entryYear : '2024',
      status: status.isNotEmpty ? status : 'Aktif',
      birthPlaceDate: birthPlaceDate.isNotEmpty ? birthPlaceDate : '-',
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
      balance: balance,
      address: address,
      entryYear: entryYear,
      status: status,
      birthPlaceDate: birthPlaceDate,
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
    String address = '-',
    String entryYear = '2024',
    String status = 'Aktif',
    String birthPlaceDate = '-',
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
        address: address,
        entryYear: entryYear,
        status: status,
        birthPlaceDate: birthPlaceDate,
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
      address: address,
      entryYear: entryYear,
      status: status,
      birthPlaceDate: birthPlaceDate,
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

  /// Pindah / Kenaikan Kelas Siswa (Class Promotion / Transfer)
  Future<bool> transferStudentClass(int studentId, String newClassName) async {
    final idx = _students.indexWhere((s) => s.id == studentId);
    if (idx < 0) return false;
    final s = _students[idx];
    return await updateStudent(
      id: s.id,
      name: s.name,
      gender: s.gender,
      className: newClassName,
      parentName: s.parentName,
      parentPhone: s.parentPhone,
      address: s.address,
      entryYear: s.entryYear,
      status: s.status,
      birthPlaceDate: s.birthPlaceDate,
    );
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
    rows.add(['nisn', 'nama', 'jenis_kelamin', 'kelas', 'tahun_masuk', 'status', 'alamat', 'nama_wali', 'no_hp_wali', 'saldo_awal']);
    rows.add(['0081234570', 'Muhammad Rizky Pratama', 'L', 'Kelas 1A', '2024', 'Aktif', 'Jl. KH. Noer Ali No. 12', 'H. Bambang', '081234567801', '50000']);
    rows.add(['0081234571', 'Nurul Aulia Rahman', 'P', 'Kelas 1B', '2024', 'Aktif', 'Jl. Sekolah No. 05', 'Ibu Maryam', '081234567802', '100000']);
    rows.add(['0081234572', 'Ahmad Dhani Al-Ghazali', 'L', 'Kelas 6A', '2019', 'Lulus', 'Kp. Karang Satria RT 02/03', 'H. Syafiq', '081234567803', '75000']);
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
      sheetName: 'Template Import Siswa',
      headers: ['nisn', 'nama', 'jenis_kelamin', 'kelas', 'tahun_masuk', 'status', 'alamat', 'nama_wali', 'no_hp_wali', 'saldo_awal'],
      rows: [
        ['0081234570', 'Muhammad Rizky Pratama', 'L', 'Kelas 1A', '2024', 'Aktif', 'Jl. KH. Noer Ali No. 12', 'H. Bambang', '081234567801', '50000'],
        ['0081234571', 'Nurul Aulia Rahman', 'P', 'Kelas 1B', '2024', 'Aktif', 'Jl. Sekolah No. 05', 'Ibu Maryam', '081234567802', '100000'],
        ['0081234572', 'Ahmad Dhani Al-Ghazali', 'L', 'Kelas 6A', '2019', 'Lulus', 'Kp. Karang Satria RT 02/03', 'H. Syafiq', '081234567803', '75000'],
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
        s.entryYear,
        s.status,
        s.address,
        s.parentName,
        s.parentPhone,
        s.balance.toStringAsFixed(0),
        s.qrCodeToken,
      ]);
    }
    final xmlContent = _generateSpreadsheetXml(
      sheetName: 'Data Siswa Manbaul Hikmah',
      headers: ['NISN', 'Nama Lengkap', 'Jenis Kelamin', 'Kelas', 'Tahun Masuk', 'Status', 'Alamat', 'Nama Wali', 'No HP Wali', 'Saldo Tabungan (Rp)', 'Token QR Code'],
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
        
        // Dynamic column mapping for detailed or legacy format
        String entryYear = '2024';
        String status = 'Aktif';
        String address = '-';
        String parentName = 'Wali Murid';
        String parentPhone = '-';
        double balance = 0.0;

        if (row.length >= 9) {
          entryYear = row[4].toString().trim();
          status = row[5].toString().trim();
          address = row[6].toString().trim();
          parentName = (row[7] != null) ? row[7].toString().trim() : 'Wali Murid';
          parentPhone = (row[8] != null) ? row[8].toString().trim() : '-';
          balance = (row.length > 9 && row[9] != null) ? (double.tryParse(row[9].toString()) ?? 0.0) : 0.0;
        } else {
          parentName = (row.length > 4 && row[4] != null) ? row[4].toString().trim() : 'Wali Murid';
          parentPhone = (row.length > 5 && row[5] != null) ? row[5].toString().trim() : '-';
          balance = (row.length > 6 && row[6] != null) ? (double.tryParse(row[6].toString()) ?? 0.0) : 0.0;
        }

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
            entryYear: entryYear,
            status: status,
            address: address,
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
            entryYear: entryYear,
            status: status,
            address: address,
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
          entryYear: entryYear,
          status: status,
          address: address,
        );
        successCount++;
      }

      notifyListeners();
      return {'success': true, 'count': successCount, 'message': 'Berhasil mengimpor $successCount data siswa'};
    } catch (e) {
      return {'success': false, 'message': 'Gagal mengimpor file CSV: $e'};
    }
  }

  /// Import Students from pure SpreadsheetML XML (Excel .xlsx format)
  Future<Map<String, dynamic>> importStudentsFromXml(String xmlData) async {
    try {
      final rowRegex = RegExp(r'<Row>(.*?)</Row>', dotAll: true);
      final cellRegex = RegExp(r'<Data[^>]*>(.*?)</Data>', dotAll: true);
      final rowMatches = rowRegex.allMatches(xmlData).toList();
      if (rowMatches.isEmpty || rowMatches.length < 2) {
        return {'success': false, 'message': 'Berkas Excel tidak memiliki baris data'};
      }

      int count = 0;
      // Skip header row
      for (int i = 1; i < rowMatches.length; i++) {
        final rowXml = rowMatches[i].group(1) ?? '';
        final cells = cellRegex.allMatches(rowXml).map((m) => m.group(1)?.trim() ?? '').toList();
        if (cells.length < 4) continue;

        final nisn = cells[0];
        final name = cells[1];
        final gender = cells[2].toUpperCase().startsWith('P') ? 'P' : 'L';
        final className = cells[3].isNotEmpty ? cells[3] : _activeClass;

        String entryYear = '2024';
        String status = 'Aktif';
        String address = '-';
        String parentName = 'Wali Murid';
        String parentPhone = '-';
        double balance = 0.0;

        if (cells.length >= 9) {
          entryYear = cells[4];
          status = cells[5];
          address = cells[6];
          parentName = cells[7].isNotEmpty ? cells[7] : 'Wali Murid';
          parentPhone = cells[8].isNotEmpty ? cells[8] : '-';
          balance = cells.length > 9 ? (double.tryParse(cells[9]) ?? 0.0) : 0.0;
        } else {
          parentName = cells.length > 4 && cells[4].isNotEmpty ? cells[4] : 'Wali Murid';
          parentPhone = cells.length > 5 && cells[5].isNotEmpty ? cells[5] : '-';
          balance = cells.length > 6 ? (double.tryParse(cells[6]) ?? 0.0) : 0.0;
        }

        if (nisn.isEmpty || name.isEmpty) continue;

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
            entryYear: entryYear,
            status: status,
            address: address,
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
            entryYear: entryYear,
            status: status,
            address: address,
          ));
        }

        ApiService.addStudent(
          nisn: nisn,
          name: name,
          gender: gender,
          className: className,
          parentName: parentName,
          parentPhone: parentPhone,
          balance: balance,
          entryYear: entryYear,
          status: status,
          address: address,
        );
        count++;
      }

      notifyListeners();
      return {'success': true, 'count': count, 'message': 'Berhasil mengimpor $count data siswa dari berkas Excel'};
    } catch (e) {
      return {'success': false, 'message': 'Gagal memproses berkas Excel: $e'};
    }
  }

  /// Import Students directly from file (.xlsx or .csv)
  Future<Map<String, dynamic>> importStudentsFromFile(String filePath) async {
    final content = await FileHelper.readFile(filePath);
    if (content == null || content.isEmpty) {
      return {'success': false, 'message': 'Berkas tidak ditemukan atau kosong di: $filePath'};
    }

    if (filePath.endsWith('.xlsx') || content.contains('<Workbook')) {
      return importStudentsFromXml(content);
    }
    return importStudentsFromCsv(content);
  }

  /// Initial fallback offline data (Real school sample: grades 1 to 6 & alumni)
  void _loadInitialData() {
    _students = [
      Student(id: 1, nisn: '0081234561', name: 'Ahmad Fauzi', gender: 'L', className: 'Kelas 1A', entryYear: '2024', status: 'Aktif', address: 'Jl. KH. Noer Ali No. 12', parentName: 'H. Rahmat', parentPhone: '081234567893', balance: 150000, qrCodeToken: 'MH-STD-0081234561'),
      Student(id: 2, nisn: '0081234562', name: 'Fatimah Az-Zahra', gender: 'P', className: 'Kelas 1A', entryYear: '2024', status: 'Aktif', address: 'Perum Graha Indah Blok B3', parentName: 'M. Yusuf', parentPhone: '081234567894', balance: 275000, qrCodeToken: 'MH-STD-0081234562'),
      Student(id: 3, nisn: '0081234563', name: 'Muhammad Bilal', gender: 'L', className: 'Kelas 1B', entryYear: '2024', status: 'Aktif', address: 'Jl. Sekolah Karang Satria', parentName: 'Drs. Supriyanto', parentPhone: '081234567895', balance: 85000, qrCodeToken: 'MH-STD-0081234563'),
      Student(id: 4, nisn: '0081234564', name: 'Aisyah Humaira', gender: 'P', className: 'Kelas 2A', entryYear: '2023', status: 'Aktif', address: 'Kp. Gabus Tengah RT 01/02', parentName: 'Agus Salim', parentPhone: '081234567896', balance: 320000, qrCodeToken: 'MH-STD-0081234564'),
      Student(id: 5, nisn: '0081234565', name: 'Zaid bin Tsabit', gender: 'L', className: 'Kelas 3A', entryYear: '2022', status: 'Aktif', address: 'Jl. Raya Tambun No. 45', parentName: 'Heri Irawan', parentPhone: '081234567897', balance: 60000, qrCodeToken: 'MH-STD-0081234565'),
      Student(id: 6, nisn: '0081234566', name: 'Khadijah Al-Kubro', gender: 'P', className: 'Kelas 5A', entryYear: '2020', status: 'Aktif', address: 'Villa Mutiara Gading 1', parentName: 'Bambang Sudiro', parentPhone: '081234567898', balance: 190000, qrCodeToken: 'MH-STD-0081234566'),
      Student(id: 7, nisn: '0081234567', name: 'Umar Al-Faruq', gender: 'L', className: 'Kelas 6A', entryYear: '2019', status: 'Lulus', address: 'Kp. Kebalen RT 04/05', parentName: 'H. Mansyur', parentPhone: '081234567899', balance: 110000, qrCodeToken: 'MH-STD-0081234567'),
      Student(id: 8, nisn: '0081234568', name: 'Maryam Syafira', gender: 'P', className: 'Kelas 6A', entryYear: '2019', status: 'Lulus', address: 'Perum Puri Cendana Blok C', parentName: 'Suryono', parentPhone: '081234567800', balance: 450000, qrCodeToken: 'MH-STD-0081234568'),
      Student(id: 11, nisn: '0081234569', name: 'Siti Rahma Fauziah', gender: 'P', className: 'Kelas 1A', entryYear: '2024', status: 'Aktif', address: 'Jl. KH. Noer Ali No. 12', parentName: 'H. Rahmat', parentPhone: '081234567893', balance: 220000, qrCodeToken: 'MH-STD-0081234569'),
    ];

    _attendances = [
      AttendanceRecord(studentId: 1, className: 'Kelas 1A', date: '2026-09-30', status: 'Hadir', scanTime: '06:55 WIB', notes: 'Tepat Waktu via QR'),
      AttendanceRecord(studentId: 2, className: 'Kelas 1A', date: '2026-09-30', status: 'Hadir', scanTime: '07:02 WIB', notes: 'Tepat Waktu via QR'),
      AttendanceRecord(studentId: 3, className: 'Kelas 1B', date: '2026-09-30', status: 'Sakit', scanTime: '-', notes: 'Surat dokter'),
      AttendanceRecord(studentId: 4, className: 'Kelas 2A', date: '2026-09-30', status: 'Hadir', scanTime: '07:05 WIB', notes: 'Tepat Waktu via QR'),
      AttendanceRecord(studentId: 5, className: 'Kelas 3A', date: '2026-09-30', status: 'Izin', scanTime: '-', notes: 'Acara keluarga'),
      AttendanceRecord(studentId: 6, className: 'Kelas 5A', date: '2026-09-30', status: 'Hadir', scanTime: '07:11 WIB', notes: 'Tepat Waktu via QR'),
      AttendanceRecord(studentId: 7, className: 'Kelas 6A', date: '2026-09-30', status: 'Hadir', scanTime: '06:50 WIB', notes: 'Alumni Lulus'),
      AttendanceRecord(studentId: 8, className: 'Kelas 6A', date: '2026-09-30', status: 'Hadir', scanTime: '07:00 WIB', notes: 'Alumni Lulus'),
      AttendanceRecord(studentId: 11, className: 'Kelas 1A', date: '2026-09-30', status: 'Hadir', scanTime: '06:58 WIB', notes: 'Tepat Waktu via QR'),
    ];

    _announcements = [
      Announcement(
        id: 1,
        title: 'Rapat Koordinasi Wali Kelas & Kenaikan Kelas Siswa',
        content: 'Diberitahukan kepada seluruh Wali Kelas tingkat 1 s/d 6 untuk melengkapi buku rapor digital dan rekap kehadiran siswa menjelang pleno kenaikan kelas tahun ajaran baru.',
        targetAudience: 'walikelas',
        category: 'Akademik',
        author: 'KH. Ahmad Syafei, M.Pd.',
        date: '30 Sep 2026',
        isUrgent: true,
      ),
      Announcement(
        id: 2,
        title: 'Pelaksanaan Penilaian Tengah Semester (PTS) Ganjil',
        content: 'Diberitahukan kepada seluruh Dewan Guru bahwa pelaksanaan PTS Ganjil dimulai Senin depan. Mohon naskah soal dan rekap materi kelas disiapkan.',
        targetAudience: 'teachers',
        category: 'Akademik',
        author: 'KH. Ahmad Syafei, M.Pd.',
        date: '28 Sep 2026',
        isUrgent: true,
      ),
      Announcement(
        id: 3,
        title: 'Himbauan Gerakan Menabung & Kartu Name Tag QR',
        content: 'Kepada seluruh Wali Murid, siswa kini dilengkapi Name Tag Digital untuk presensi otomatis dan tabungan sekolah terpadu.',
        targetAudience: 'parents',
        category: 'Kegiatan',
        author: 'KH. Ahmad Syafei, M.Pd.',
        date: '27 Sep 2026',
        isUrgent: false,
      ),
      Announcement(
        id: 4,
        title: 'Peringatan Hari Besar Islam & Pengajian Akbar',
        content: 'Kegiatan belajar mengajar diliburkan menyambut peringatan Maulid Nabi SAW di Masjid Utama Sekolah.',
        targetAudience: 'all',
        category: 'Libur',
        author: 'KH. Ahmad Syafei, M.Pd.',
        date: '29 Sep 2026',
        isUrgent: false,
      ),
    ];

    _transactions = [
      SavingsTransaction(id: 1, studentId: 1, type: 'setor', amount: 50000, balanceAfter: 150000, notes: 'Uang saku mingguan', date: '29 Sep 2026 07:15'),
      SavingsTransaction(id: 2, studentId: 2, type: 'setor', amount: 100000, balanceAfter: 275000, notes: 'Setoran bulanan', date: '28 Sep 2026 09:30'),
      SavingsTransaction(id: 3, studentId: 3, type: 'tarik', amount: 20000, balanceAfter: 85000, notes: 'Beli kitab fiqih', date: '27 Sep 2026 10:15'),
      SavingsTransaction(id: 4, studentId: 4, type: 'setor', amount: 50000, balanceAfter: 320000, notes: 'Tabungan siswa', date: '29 Sep 2026 07:30'),
      SavingsTransaction(id: 5, studentId: 11, type: 'setor', amount: 70000, balanceAfter: 220000, notes: 'Tabungan siswi', date: '29 Sep 2026 08:00'),
    ];

    _schedules = [
      // Senin
      const SchoolSchedule(id: '1', day: 'Senin', subject: 'Tahfidz Al-Qur\'an Juz Amma', className: 'Kelas 1A', teacherName: 'Ustadzah Fatimah, S.Pd.', startTime: '07:30', endTime: '09:00', room: 'Ruang 1A'),
      const SchoolSchedule(id: '2', day: 'Senin', subject: 'Fiqih & Kitab Safinatun Najah', className: 'Kelas 7A', teacherName: 'Ustadz Hendra Pratama, S.Pd.', startTime: '07:30', endTime: '09:00', room: 'Ruang 7A'),
      const SchoolSchedule(id: '3', day: 'Senin', subject: 'Bahasa Arab Dasar', className: 'Kelas 7A', teacherName: 'Ustadz Budi Santoso, S.Pd.', startTime: '09:15', endTime: '10:45', room: 'Ruang 7A'),
      const SchoolSchedule(id: '4', day: 'Senin', subject: 'Fiqih Ibadah', className: 'Kelas 7B', teacherName: 'Ustadz Hendra Pratama, S.Pd.', startTime: '09:15', endTime: '10:45', room: 'Ruang 7B'),
      const SchoolSchedule(id: '5', day: 'Senin', subject: 'Aqidah Akhlak', className: 'Kelas 7A', teacherName: 'Ustadzah Siti Aminah, S.Pd.I.', startTime: '11:00', endTime: '12:30', room: 'Ruang 7A'),

      // Selasa
      const SchoolSchedule(id: '6', day: 'Selasa', subject: 'Hadits Arbain Nawawi', className: 'Kelas 7A', teacherName: 'Ustadz Hendra Pratama, S.Pd.', startTime: '07:30', endTime: '09:00', room: 'Ruang 7A'),
      const SchoolSchedule(id: '7', day: 'Selasa', subject: 'Bahasa Indonesia', className: 'Kelas 7A', teacherName: 'Ustadzah Siti Aminah, S.Pd.I.', startTime: '09:15', endTime: '10:45', room: 'Ruang 7A'),
      const SchoolSchedule(id: '8', day: 'Selasa', subject: 'Sejarah Kebudayaan Islam', className: 'Kelas 7B', teacherName: 'Ustadz Hendra Pratama, S.Pd.', startTime: '11:00', endTime: '12:30', room: 'Ruang 7B'),

      // Rabu
      const SchoolSchedule(id: '9', day: 'Rabu', subject: 'Nahwu & Shorof Dasar', className: 'Kelas 7A', teacherName: 'Ustadz Hendra Pratama, S.Pd.', startTime: '07:30', endTime: '09:00', room: 'Ruang 7A'),
      const SchoolSchedule(id: '10', day: 'Rabu', subject: 'Bahasa Inggris', className: 'Kelas 7A', teacherName: 'Ustadz Budi Santoso, S.Pd.', startTime: '09:15', endTime: '10:45', room: 'Ruang 7A'),
      const SchoolSchedule(id: '11', day: 'Rabu', subject: 'Tajwid & Makharijul Huruf', className: 'Kelas 1A', teacherName: 'Ustadzah Fatimah, S.Pd.', startTime: '07:30', endTime: '09:00', room: 'Ruang 1A'),

      // Kamis
      const SchoolSchedule(id: '12', day: 'Kamis', subject: 'Fiqih Muamalah', className: 'Kelas 7A', teacherName: 'Ustadz Hendra Pratama, S.Pd.', startTime: '07:30', endTime: '09:00', room: 'Ruang 7A'),
      const SchoolSchedule(id: '13', day: 'Kamis', subject: 'Imla & Khot Arab', className: 'Kelas 7A', teacherName: 'Ustadzah Siti Aminah, S.Pd.I.', startTime: '09:15', endTime: '10:45', room: 'Ruang 7A'),
      const SchoolSchedule(id: '14', day: 'Kamis', subject: 'Matematika Terpadu', className: 'Kelas 7A', teacherName: 'Ustadz Budi Santoso, S.Pd.', startTime: '11:00', endTime: '12:30', room: 'Ruang 7A'),

      // Jumat
      const SchoolSchedule(id: '15', day: 'Jumat', subject: 'Muhadharah / Khitobah Siswa', className: 'Kelas 7A', teacherName: 'Ustadz Hendra Pratama, S.Pd.', startTime: '07:30', endTime: '09:00', room: 'Masjid Utama'),
      const SchoolSchedule(id: '16', day: 'Jumat', subject: 'Kajian Kitab Ta\'limul Muta\'allim', className: 'Kelas 7A', teacherName: 'KH. Ahmad Syafei, M.Pd.', startTime: '09:15', endTime: '10:45', room: 'Masjid Utama'),

      // Sabtu
      const SchoolSchedule(id: '17', day: 'Sabtu', subject: 'Kepanduan & Pramuka Siswa', className: 'Kelas 7A', teacherName: 'Ustadz Budi Santoso, S.Pd.', startTime: '07:30', endTime: '09:30', room: 'Lapangan Utama'),
      const SchoolSchedule(id: '18', day: 'Sabtu', subject: 'Seni Tilawah & Hadrah Marawis', className: 'Kelas 7A', teacherName: 'Ustadz Hendra Pratama, S.Pd.', startTime: '10:00', endTime: '11:30', room: 'Aula Serbaguna'),
    ];

    _bills = [
      PaymentBill(
        id: 1,
        studentId: 1,
        studentName: 'Ahmad Fauzi',
        className: 'Kelas 1A',
        category: 'SPP Bulanan',
        month: 'Oktober',
        amount: 250000,
        status: 'Belum Lunas',
        dueDate: '10 Okt 2026',
        invoiceNumber: 'MH-BILL-001',
      ),
      PaymentBill(
        id: 2,
        studentId: 1,
        studentName: 'Ahmad Fauzi',
        className: 'Kelas 1A',
        category: 'SPP Bulanan',
        month: 'September',
        amount: 250000,
        paidAmount: 250000,
        status: 'Lunas',
        dueDate: '10 Sep 2026',
        paidDate: '08 Sep 2026 08:30',
        paymentMethod: 'EduPay Tabungan',
        invoiceNumber: 'INV-MH-202609-001',
      ),
      PaymentBill(
        id: 3,
        studentId: 1,
        studentName: 'Ahmad Fauzi',
        className: 'Kelas 1A',
        category: 'Uang Gedung / Infaq',
        amount: 1500000,
        paidAmount: 1500000,
        status: 'Lunas',
        dueDate: '15 Jul 2026',
        paidDate: '12 Jul 2026 10:15',
        paymentMethod: 'Transfer Bank',
        invoiceNumber: 'INV-MH-202607-005',
      ),
      PaymentBill(
        id: 4,
        studentId: 1,
        studentName: 'Ahmad Fauzi',
        className: 'Kelas 1A',
        category: 'Buku & Modul',
        amount: 350000,
        paidAmount: 350000,
        status: 'Lunas',
        dueDate: '20 Jul 2026',
        paidDate: '18 Jul 2026 11:00',
        paymentMethod: 'Tunai di TU',
        invoiceNumber: 'INV-MH-202607-018',
      ),
      PaymentBill(
        id: 5,
        studentId: 2,
        studentName: 'Fatimah Az-Zahra',
        className: 'Kelas 1A',
        category: 'SPP Bulanan',
        month: 'Oktober',
        amount: 250000,
        paidAmount: 250000,
        status: 'Lunas',
        dueDate: '10 Okt 2026',
        paidDate: '01 Okt 2026 09:12',
        paymentMethod: 'EduPay Tabungan',
        invoiceNumber: 'INV-MH-202610-002',
      ),
      PaymentBill(
        id: 6,
        studentId: 3,
        studentName: 'Muhammad Bilal',
        className: 'Kelas 1B',
        category: 'SPP Bulanan',
        month: 'Oktober',
        amount: 250000,
        status: 'Belum Lunas',
        dueDate: '10 Okt 2026',
        invoiceNumber: 'MH-BILL-003',
      ),
      PaymentBill(
        id: 7,
        studentId: 3,
        studentName: 'Muhammad Bilal',
        className: 'Kelas 1B',
        category: 'Seragam Sekolah',
        amount: 450000,
        paidAmount: 450000,
        status: 'Lunas',
        dueDate: '25 Jul 2026',
        paidDate: '20 Jul 2026 14:00',
        paymentMethod: 'Tunai di TU',
        invoiceNumber: 'INV-MH-202607-040',
      ),
      PaymentBill(
        id: 10,
        studentId: 11,
        studentName: 'Siti Rahma Fauziah',
        className: 'Kelas 1A',
        category: 'SPP Bulanan',
        month: 'Oktober',
        amount: 250000,
        paidAmount: 250000,
        status: 'Lunas',
        dueDate: '10 Okt 2026',
        paidDate: '01 Okt 2026 09:00',
        paymentMethod: 'Transfer Bank',
        invoiceNumber: 'INV-MH-202610-011',
      ),
    ];

    _classes = [
      SchoolClass(id: 1, name: 'Kelas 1A', gradeLevel: '1', homeroomTeacherName: 'Ustadzah Fatimah, S.Pd.'),
      SchoolClass(id: 2, name: 'Kelas 1B', gradeLevel: '1', homeroomTeacherName: 'Ustadzah Nurul Hidayah, S.Pd.'),
      SchoolClass(id: 3, name: 'Kelas 1C', gradeLevel: '1', homeroomTeacherName: 'Ustadzah Maryam, S.Pd.'),
      SchoolClass(id: 4, name: 'Kelas 2A', gradeLevel: '2', homeroomTeacherName: 'Ustadz Ahmad Fauzan, S.Pd.I.'),
      SchoolClass(id: 5, name: 'Kelas 2B', gradeLevel: '2', homeroomTeacherName: 'Ustadzah Khadijah, S.Pd.'),
      SchoolClass(id: 6, name: 'Kelas 2C', gradeLevel: '2', homeroomTeacherName: 'Ustadz Zainal Abidin, S.Pd.'),
      SchoolClass(id: 7, name: 'Kelas 3A', gradeLevel: '3', homeroomTeacherName: 'Ustadz Ridwan Kamil, S.Pd.'),
      SchoolClass(id: 8, name: 'Kelas 3B', gradeLevel: '3', homeroomTeacherName: 'Ustadzah Aisyah, S.Pd.I.'),
      SchoolClass(id: 9, name: 'Kelas 3C', gradeLevel: '3', homeroomTeacherName: 'Ustadz Luqman Hakim, S.Pd.'),
      SchoolClass(id: 10, name: 'Kelas 4A', gradeLevel: '4', homeroomTeacherName: 'Ustadz Hendra Pratama, S.Pd.'),
      SchoolClass(id: 11, name: 'Kelas 4B', gradeLevel: '4', homeroomTeacherName: 'Ustadzah Dewi Sartika, S.Pd.'),
      SchoolClass(id: 12, name: 'Kelas 4C', gradeLevel: '4', homeroomTeacherName: 'Ustadz Hasan Basri, S.Pd.I.'),
      SchoolClass(id: 13, name: 'Kelas 5A', gradeLevel: '5', homeroomTeacherName: 'Ustadz Budi Santoso, S.Pd.'),
      SchoolClass(id: 14, name: 'Kelas 5B', gradeLevel: '5', homeroomTeacherName: 'Ustadzah Siti Aminah, S.Pd.I.'),
      SchoolClass(id: 15, name: 'Kelas 5C', gradeLevel: '5', homeroomTeacherName: 'Ustadz Yusuf Mansur, S.Pd.'),
      SchoolClass(id: 16, name: 'Kelas 6A', gradeLevel: '6', homeroomTeacherName: 'Ustadz Abdullah Syafi\'i, M.Pd.'),
      SchoolClass(id: 17, name: 'Kelas 6B', gradeLevel: '6', homeroomTeacherName: 'Ustadzah Halimah, S.Pd.'),
      SchoolClass(id: 18, name: 'Kelas 6C', gradeLevel: '6', homeroomTeacherName: 'Ustadz Ali Ridho, S.Pd.I.'),
      SchoolClass(id: 19, name: 'Kelas 7A', gradeLevel: '7', homeroomTeacherName: 'Ustadz Hendra Pratama, S.Pd.'),
      SchoolClass(id: 20, name: 'Kelas 7B', gradeLevel: '7', homeroomTeacherName: 'Ustadz Budi Santoso, S.Pd.'),
    ];
  }

  // ==========================================
  // MASTER KELAS & WALI KELAS MANAGEMENT (STAFF TU)
  // ==========================================
  void addClass({
    required String name,
    required String gradeLevel,
    String homeroomTeacher = '',
    int capacity = 30,
  }) {
    final nextId = _classes.isEmpty ? 1 : _classes.map((c) => c.id).reduce((a, b) => a > b ? a : b) + 1;
    _classes.add(SchoolClass(
      id: nextId,
      name: name,
      gradeLevel: gradeLevel,
      homeroomTeacherName: homeroomTeacher,
      capacity: capacity,
    ));
    notifyListeners();
  }

  void updateClass({
    required int classId,
    required String name,
    required String gradeLevel,
    required String homeroomTeacher,
    required int capacity,
  }) {
    final idx = _classes.indexWhere((c) => c.id == classId);
    if (idx != -1) {
      final oldName = _classes[idx].name;
      _classes[idx] = SchoolClass(
        id: classId,
        name: name,
        gradeLevel: gradeLevel,
        homeroomTeacherName: homeroomTeacher,
        capacity: capacity,
      );
      // Update any student whose className was oldName
      if (oldName != name) {
        for (final s in _students) {
          if (s.className == oldName) {
            s.className = name;
          }
        }
      }
      notifyListeners();
    }
  }

  void updateClassHomeroom({required int classId, required String homeroomTeacher}) {
    final idx = _classes.indexWhere((c) => c.id == classId);
    if (idx != -1) {
      _classes[idx].homeroomTeacherName = homeroomTeacher;
      notifyListeners();
    }
  }

  void deleteClass(int classId) {
    _classes.removeWhere((c) => c.id == classId);
    notifyListeners();
  }

  // ==========================================
  // JADWAL MAPEL / PELAJARAN CRUD (STAFF TU)
  // ==========================================
  void addSchedule(SchoolSchedule schedule) {
    _schedules.add(schedule);
    notifyListeners();
  }

  void updateSchedule(SchoolSchedule schedule) {
    final idx = _schedules.indexWhere((s) => s.id == schedule.id);
    if (idx != -1) {
      _schedules[idx] = schedule;
      notifyListeners();
    }
  }

  void deleteSchedule(String id) {
    _schedules.removeWhere((s) => s.id == id);
    notifyListeners();
  }

  // ==========================================
  // GENERATE SPP BULANAN MASSAL KELAS (STAFF TU)
  // ==========================================
  int generateClassMonthlyBills({
    required String className,
    required String month,
    required double amount,
    required String dueDate,
  }) {
    final targetStudents = _students.where((s) => s.className == className).toList();
    int count = 0;
    for (final s in targetStudents) {
      final alreadyExists = _bills.any((b) => b.studentId == s.id && b.category == 'SPP Bulanan' && b.month == month);
      if (!alreadyExists) {
        final nextId = _bills.isEmpty ? 1 : _bills.map((b) => b.id).reduce((a, b) => a > b ? a : b) + 1;
        _bills.insert(
          0,
          PaymentBill(
            id: nextId,
            studentId: s.id,
            studentName: s.name,
            className: s.className,
            category: 'SPP Bulanan',
            month: month,
            amount: amount,
            status: 'Belum Lunas',
            dueDate: dueDate,
            invoiceNumber: 'MH-SPP-${DateTime.now().millisecondsSinceEpoch}-$nextId',
          ),
        );
        count++;
      }
    }
    notifyListeners();
    return count;
  }
}
