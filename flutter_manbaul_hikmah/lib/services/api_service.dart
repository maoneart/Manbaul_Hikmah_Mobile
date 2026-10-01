import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/student.dart';
import '../models/attendance.dart';
import '../models/savings.dart';
import '../models/announcement.dart';
import '../models/payment_bill.dart';

class ApiService {
  static const String baseUrl = 'https://maoneart.my.id/manbaul/api';
  static const String appKey = 'MH-SECURE-API-2026-MAONEART';
  static const Duration timeoutDuration = Duration(seconds: 15);

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-App-Key': appKey,
        'Authorization': 'Bearer $appKey',
      };

  static dynamic _safeJsonDecode(String source) {
    try {
      return jsonDecode(source);
    } catch (_) {
      return null;
    }
  }

  /// 0. User Login
  static Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final uri = Uri.parse('$baseUrl/auth.php?action=login');
      final response = await http
          .post(
            uri,
            headers: _headers,
            body: jsonEncode({
              'username': username,
              'password': password,
            }),
          )
          .timeout(timeoutDuration);

      final body = _safeJsonDecode(response.body);
      if (body is Map<String, dynamic>) {
        return body;
      }
    } catch (e) {
      return {'status': false, 'message': 'Gagal terhubung ke server: $e'};
    }
    return {'status': false, 'message': 'Respon server tidak valid'};
  }

  /// 0.1 Get Users List
  static Future<List<Map<String, dynamic>>> getUsers() async {
    try {
      final uri = Uri.parse('$baseUrl/auth.php?action=users');
      final response = await http.get(uri, headers: _headers).timeout(timeoutDuration);
      if (response.statusCode == 200) {
        final body = _safeJsonDecode(response.body);
        if (body is Map && body['status'] == true && body['data'] is List) {
          return List<Map<String, dynamic>>.from(body['data']);
        }
      }
    } catch (_) {}
    return [];
  }

  /// 1. Get Students List
  static Future<List<Student>> getStudents({String? className, String? search}) async {
    try {
      final queryParams = <String, String>{};
      if (className != null && className.isNotEmpty && className != 'Semua') {
        queryParams['class'] = className;
      }
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final uri = Uri.parse('$baseUrl/students.php').replace(
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      final response = await http.get(uri, headers: _headers).timeout(timeoutDuration);
      if (response.statusCode == 200) {
        final body = _safeJsonDecode(response.body);
        if (body is Map && body['status'] == true && body['data'] is List) {
          return (body['data'] as List)
              .map((item) => Student.fromJson(item as Map<String, dynamic>))
              .toList();
        }
      }
    } catch (e) {
      // Fallback
    }
    return [];
  }

  /// 2. Add New Student
  static Future<Map<String, dynamic>> addStudent({
    required String nisn,
    required String name,
    required String gender,
    required String className,
    required String parentName,
    required String parentPhone,
    double balance = 0.0,
    String address = '-',
    String entryYear = '2024',
    String status = 'Aktif',
    String birthPlaceDate = '-',
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/students.php');
      final response = await http
          .post(
            uri,
            headers: _headers,
            body: jsonEncode({
              'nisn': nisn,
              'name': name,
              'gender': gender,
              'class_name': className,
              'parent_name': parentName,
              'parent_phone': parentPhone,
              'balance': balance,
              'address': address,
              'entry_year': entryYear,
              'status': status,
              'birth_place_date': birthPlaceDate,
            }),
          )
          .timeout(timeoutDuration);

      final body = _safeJsonDecode(response.body);
      if (body is Map<String, dynamic>) {
        return body;
      }
    } catch (e) {
      return {'status': false, 'message': 'Gagal terhubung ke server: $e'};
    }
    return {'status': false, 'message': 'Respon server tidak valid'};
  }

  /// 2.1 Update Student
  static Future<Map<String, dynamic>> updateStudent({
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
    try {
      final uri = Uri.parse('$baseUrl/students.php');
      final response = await http
          .put(
            uri,
            headers: _headers,
            body: jsonEncode({
              'id': id,
              'name': name,
              'gender': gender,
              'class_name': className,
              'parent_name': parentName,
              'parent_phone': parentPhone,
              'address': address,
              'entry_year': entryYear,
              'status': status,
              'birth_place_date': birthPlaceDate,
            }),
          )
          .timeout(timeoutDuration);
      final body = _safeJsonDecode(response.body);
      if (body is Map<String, dynamic>) {
        return body;
      }
    } catch (e) {
      return {'status': false, 'message': 'Gagal update: $e'};
    }
    return {'status': false, 'message': 'Gagal memperbarui data siswa'};
  }

  /// 2.2 Delete Student
  static Future<Map<String, dynamic>> deleteStudent(int id) async {
    try {
      final uri = Uri.parse('$baseUrl/students.php?id=$id');
      final response = await http.delete(uri, headers: _headers).timeout(timeoutDuration);
      final body = _safeJsonDecode(response.body);
      if (body is Map<String, dynamic>) {
        return body;
      }
    } catch (e) {
      return {'status': false, 'message': 'Gagal menghapus: $e'};
    }
    return {'status': false, 'message': 'Gagal menghapus siswa'};
  }

  /// 3. Get Today Attendance for Class
  static Future<Map<String, dynamic>> getTodayAttendance({String className = 'Semua', String? date}) async {
    try {
      final queryParams = <String, String>{'action': 'today', 'class': className};
      if (date != null && date.isNotEmpty) {
        queryParams['date'] = date;
      }

      final uri = Uri.parse('$baseUrl/attendance.php').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: _headers).timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final body = _safeJsonDecode(response.body);
        if (body is Map && body['status'] == true && body['data'] is Map) {
          final data = body['data'] as Map<String, dynamic>;
          final rawStudents = (data['students'] as List?) ?? [];
          final records = rawStudents.map((s) {
            return AttendanceRecord(
              studentId: s['student_id'] is int ? s['student_id'] : int.parse(s['student_id'].toString()),
              className: s['class_name'] ?? className,
              date: data['date'] ?? '',
              status: (s['status'] == null || s['status'] == 'Belum Absen') ? 'Belum Absen' : s['status'].toString(),
              scanTime: s['scan_time'],
              notes: s['notes'] ?? '',
            );
          }).toList();

          return {
            'success': true,
            'stats': data['stats'],
            'records': records,
          };
        }
      }
    } catch (e) {
      // Fallback
    }
    return {'success': false, 'stats': null, 'records': <AttendanceRecord>[]};
  }

  /// 4. Mark Attendance Manual (Hadir, Sakit, Izin, Alfa)
  static Future<Map<String, dynamic>> markAttendance({
    required int studentId,
    required String status,
    String? date,
    String notes = '',
    String recordedBy = 'Aplikasi Mobile',
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/attendance.php?action=manual');
      final response = await http
          .post(
            uri,
            headers: _headers,
            body: jsonEncode({
              'student_id': studentId,
              'status': status,
              if (date != null) 'date': date,
              'notes': notes,
              'recorded_by': recordedBy,
            }),
          )
          .timeout(timeoutDuration);

      final body = _safeJsonDecode(response.body);
      if (body is Map<String, dynamic>) {
        return body;
      }
    } catch (e) {
      return {'status': false, 'message': 'Gagal mencatat presensi: $e'};
    }
    return {'status': false, 'message': 'Gagal memproses presensi'};
  }

  /// 5. Scan QR Code Attendance
  static Future<Map<String, dynamic>> scanQrAttendance({
    required String qrToken,
    String recordedBy = 'Scan QR Mobile',
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/attendance.php?action=scan');
      final response = await http
          .post(
            uri,
            headers: _headers,
            body: jsonEncode({
              'qr_token': qrToken,
              'recorded_by': recordedBy,
            }),
          )
          .timeout(timeoutDuration);

      final body = _safeJsonDecode(response.body);
      if (body is Map<String, dynamic>) {
        return body;
      }
    } catch (e) {
      return {'status': false, 'message': 'Koneksi error: $e'};
    }
    return {'status': false, 'message': 'Respon server tidak valid'};
  }

  /// 5b. Lock Attendance Today (Auto-Alfa SOP)
  static Future<Map<String, dynamic>> lockAttendance({
    String className = 'Semua',
    String? date,
    String recordedBy = 'SOP Kunci Presensi (Wali Kelas)',
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/attendance.php?action=lock');
      final response = await http
          .post(
            uri,
            headers: _headers,
            body: jsonEncode({
              'class': className,
              if (date != null) 'date': date,
              'recorded_by': recordedBy,
            }),
          )
          .timeout(timeoutDuration);

      final body = _safeJsonDecode(response.body);
      if (body is Map<String, dynamic>) {
        return body;
      }
    } catch (e) {
      return {'status': false, 'message': 'Gagal mengunci presensi: $e'};
    }
    return {'status': false, 'message': 'Gagal memproses kunci presensi'};
  }

  /// 6. Get Savings Summary & Recent Transactions
  static Future<Map<String, dynamic>> getSavingsSummary({String? className}) async {
    try {
      final queryParams = <String, String>{'action': 'summary'};
      if (className != null && className.isNotEmpty && className != 'Semua') {
        queryParams['class'] = className;
      }

      final uri = Uri.parse('$baseUrl/savings.php').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: _headers).timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final body = _safeJsonDecode(response.body);
        if (body is Map && body['status'] == true && body['data'] is Map) {
          final data = body['data'] as Map<String, dynamic>;
          final rawTrans = (data['recent_transactions'] as List?) ?? [];
          final transactions = rawTrans
              .map((t) => SavingsTransaction.fromJson(t as Map<String, dynamic>))
              .toList();

          return {
            'success': true,
            'total_savings': double.tryParse(data['total_savings'].toString()) ?? 0.0,
            'total_students': int.tryParse(data['total_students'].toString()) ?? 0,
            'transactions': transactions,
          };
        }
      }
    } catch (e) {
      // Fallback
    }
    return {'success': false, 'total_savings': 0.0, 'total_students': 0, 'transactions': <SavingsTransaction>[]};
  }

  /// 7. Record Savings Transaction (Setor / Tarik)
  static Future<Map<String, dynamic>> recordSavings({
    required int studentId,
    required String type, // 'setor' or 'tarik'
    required double amount,
    String notes = 'Tabungan Siswa',
    String recordedBy = 'Aplikasi Mobile',
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/savings.php?action=transaction');
      final response = await http
          .post(
            uri,
            headers: _headers,
            body: jsonEncode({
              'student_id': studentId,
              'type': type,
              'amount': amount,
              'notes': notes,
              'recorded_by': recordedBy,
            }),
          )
          .timeout(timeoutDuration);

      final body = _safeJsonDecode(response.body);
      if (body is Map<String, dynamic>) {
        return body;
      }
    } catch (e) {
      return {'status': false, 'message': 'Gagal mencatat transaksi: $e'};
    }
    return {'status': false, 'message': 'Gagal memproses transaksi tabungan'};
  }

  /// 8. Get Announcements
  static Future<List<Announcement>> getAnnouncements({String target = 'all'}) async {
    try {
      final uri = Uri.parse('$baseUrl/announcements.php').replace(
        queryParameters: {'target': target},
      );
      final response = await http.get(uri, headers: _headers).timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final body = _safeJsonDecode(response.body);
        if (body is Map && body['status'] == true && body['data'] is List) {
          return (body['data'] as List)
              .map((item) => Announcement.fromJson(item as Map<String, dynamic>))
              .toList();
        }
      }
    } catch (e) {
      // Fallback
    }
    return [];
  }

  /// 9. Add Announcement (Kepsek)
  static Future<Map<String, dynamic>> addAnnouncement({
    required String title,
    required String content,
    String targetAudience = 'all',
    String category = 'Akademik',
    String authorName = 'KH. Ahmad Syafei, M.Pd.',
    String authorRole = 'Kepala Sekolah',
    bool isUrgent = false,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/announcements.php');
      final response = await http
          .post(
            uri,
            headers: _headers,
            body: jsonEncode({
              'title': title,
              'content': content,
              'target_audience': targetAudience,
              'category': category,
              'author_name': authorName,
              'author_role': authorRole,
              'is_urgent': isUrgent ? 1 : 0,
            }),
          )
          .timeout(timeoutDuration);

      final body = _safeJsonDecode(response.body);
      if (body is Map<String, dynamic>) {
        return body;
      }
    } catch (e) {
      return {'status': false, 'message': 'Gagal mempublikasikan: $e'};
    }
    return {'status': false, 'message': 'Gagal mempublikasikan pengumuman'};
  }

  /// 10. Get Classes
  static Future<List<Map<String, dynamic>>> getClasses() async {
    try {
      final uri = Uri.parse('$baseUrl/classes.php');
      final response = await http.get(uri, headers: _headers).timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final body = _safeJsonDecode(response.body);
        if (body is Map && body['status'] == true && body['data'] is List) {
          return List<Map<String, dynamic>>.from(body['data']);
        }
      }
    } catch (e) {
      // Fallback
    }
    return [];
  }

  /// 11. Get Payment & SPP Bills
  static Future<List<PaymentBill>> getPaymentBills({String? className, int? studentId}) async {
    try {
      final queryParams = <String, String>{'action': 'bills'};
      if (className != null && className.isNotEmpty && className != 'Semua') {
        queryParams['class'] = className;
      }
      if (studentId != null && studentId > 0) {
        queryParams['student_id'] = studentId.toString();
      }

      final uri = Uri.parse('$baseUrl/payments.php').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: _headers).timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final body = _safeJsonDecode(response.body);
        if (body is Map && body['status'] == true && body['data'] is List) {
          final list = body['data'] as List;
          return list.map((json) => PaymentBill.fromJson(json as Map<String, dynamic>)).toList();
        }
      }
    } catch (_) {}
    return [];
  }

  /// 12. Pay School Bill (SPP / Gedung / dll)
  static Future<Map<String, dynamic>> paySchoolBill({
    required int billId,
    String paymentMethod = 'Tunai di TU',
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/payments.php?action=pay');
      final response = await http
          .post(
            uri,
            headers: _headers,
            body: jsonEncode({
              'bill_id': billId,
              'payment_method': paymentMethod,
            }),
          )
          .timeout(timeoutDuration);

      final body = _safeJsonDecode(response.body);
      if (body is Map<String, dynamic>) {
        return body;
      }
    } catch (e) {
      return {'status': false, 'message': 'Gagal memproses pembayaran: $e'};
    }
    return {'status': false, 'message': 'Respon server tidak valid'};
  }

  /// 13. Create New Payment Bill
  static Future<Map<String, dynamic>> createPaymentBill({
    required int studentId,
    required String category,
    String? month,
    required double amount,
    String? dueDate,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/payments.php?action=create_bill');
      final response = await http
          .post(
            uri,
            headers: _headers,
            body: jsonEncode({
              'student_id': studentId,
              'category': category,
              'month': month ?? '',
              'amount': amount,
              'due_date': dueDate ?? '10 Setiap Bulan',
            }),
          )
          .timeout(timeoutDuration);

      final body = _safeJsonDecode(response.body);
      if (body is Map<String, dynamic>) {
        return body;
      }
    } catch (e) {
      return {'status': false, 'message': 'Gagal membuat tagihan: $e'};
    }
    return {'status': false, 'message': 'Respon server tidak valid'};
  }

  /// 14. Generate Monthly SPP Bills for Whole Class
  static Future<Map<String, dynamic>> generateClassMonthlyBills({
    required String className,
    required String month,
    required double amount,
    required String dueDate,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/payments.php?action=generate_class_bills');
      final response = await http
          .post(
            uri,
            headers: _headers,
            body: jsonEncode({
              'class_name': className,
              'month': month,
              'amount': amount,
              'due_date': dueDate,
            }),
          )
          .timeout(timeoutDuration);

      final body = _safeJsonDecode(response.body);
      if (body is Map<String, dynamic>) {
        return body;
      }
    } catch (e) {
      return {'status': false, 'message': 'Gagal generate tagihan: $e'};
    }
    return {'status': false, 'message': 'Respon server tidak valid'};
  }
}
