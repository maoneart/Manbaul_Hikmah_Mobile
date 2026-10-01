import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/student.dart';
import '../../models/attendance.dart';
import '../../providers/school_provider.dart';
import '../../theme/app_theme.dart';
import 'qr_scanner_screen.dart';

class AttendanceScreen extends StatefulWidget {
  final VoidCallback? onNavigateHome;
  const AttendanceScreen({super.key, this.onNavigateHome});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  DateTime _selectedDate = DateTime.now();
  String _selectedStatusFilter = 'Semua'; // 'Semua', 'Hadir', 'Sakit', 'Izin', 'Alfa'
  String _selectedClassFilter = 'Semua';

  String get _formattedDateString {
    return "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";
  }

  String get _displayDateHuman {
    const months = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    const days = ['', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Ahad'];
    return "${days[_selectedDate.weekday]}, ${_selectedDate.day} ${months[_selectedDate.month]} ${_selectedDate.year}";
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SchoolProvider>(context);
    final role = provider.currentRole;
    final isLeader = role == 'kepsek' || role == 'admin' || role == 'staff';
    final isWaliMurid = role == 'wali_murid';
    final myChild = provider.myChildStudent;

    // List of students: Kepsek/TU/Admin can supervise all students
    final List<Student> students;
    if (isLeader) {
      students = (_selectedClassFilter == 'Semua')
          ? provider.allStudents
          : provider.allStudents.where((s) => s.className == _selectedClassFilter).toList();
    } else {
      students = provider.students;
    }

    // Filter students by selected status
    final filteredStudents = students.where((s) {
      if (_selectedStatusFilter == 'Semua') return true;
      final att = provider.getStudentAttendance(s.id, date: _formattedDateString);
      final status = att?.status ?? 'Alfa';
      return status == _selectedStatusFilter;
    }).toList();

    // Counts for selected date
    int hadir = 0;
    int sakit = 0;
    int izin = 0;
    int alfa = 0;

    for (final s in students) {
      final att = provider.getStudentAttendance(s.id, date: _formattedDateString);
      final st = att?.status ?? 'Alfa';
      if (st == 'Hadir') hadir++;
      else if (st == 'Sakit') sakit++;
      else if (st == 'Izin') izin++;
      else if (st == 'Alfa') alfa++;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        leading: (Navigator.canPop(context) || widget.onNavigateHome != null)
            ? IconButton(
                icon: const Icon(CupertinoIcons.chevron_back, color: Color(0xFF1C1C1E), size: 28),
                tooltip: 'Kembali',
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  } else if (widget.onNavigateHome != null) {
                    widget.onNavigateHome!();
                  }
                },
              )
            : null,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Presensi & Kehadiran Siswa',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1C1C1E)),
            ),
            Text(
              isWaliMurid
                  ? 'Akun Siswa: ${myChild?.name ?? "Siswa"} • ${myChild?.className ?? ""}'
                  : (isLeader
                      ? '${_selectedClassFilter == "Semua" ? "Semua Kelas" : _selectedClassFilter} • ${students.length} Siswa'
                      : 'Kelas: ${provider.activeClass} • ${students.length} Siswa'),
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        actions: [
          if (isLeader) ...[
            PopupMenuButton<String>(
              icon: const Icon(Icons.filter_list_rounded, color: Color(0xFF00B14F)),
              tooltip: 'Pilih Rombel / Semua Kelas',
              onSelected: (val) {
                setState(() => _selectedClassFilter = val);
              },
              itemBuilder: (ctx) {
                final classOptions = ['Semua', ...provider.classNames];
                return classOptions.map((cls) {
                  return PopupMenuItem(
                    value: cls,
                    child: Text(
                      cls == 'Semua' ? 'Semua Kelas (${provider.allStudents.length} Siswa)' : cls,
                      style: TextStyle(
                        fontWeight: _selectedClassFilter == cls ? FontWeight.bold : FontWeight.normal,
                        color: _selectedClassFilter == cls ? const Color(0xFF00B14F) : const Color(0xFF1C1C1E),
                      ),
                    ),
                  );
                }).toList();
              },
            ),
            const SizedBox(width: 4),
          ],
          if (!isWaliMurid) ...[
            IconButton(
              icon: const Icon(Icons.table_chart_rounded, color: Color(0xFF00B14F)),
              tooltip: 'Export Rekap Excel',
              onPressed: () {
                final csv = provider.exportAttendanceToCsv();
                Clipboard.setData(ClipboardData(text: csv));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Rekap presensi berhasil disalin format Excel/CSV!'),
                    backgroundColor: Color(0xFF00B14F),
                  ),
                );
              },
            ),
            const SizedBox(width: 4),
          ],
        ],
      ),
      floatingActionButton: (role == 'kepsek' || role == 'staff')
          ? null
          : FloatingActionButton.extended(
              onPressed: () => isWaliMurid
                  ? _showParentLeaveModal(context, provider, myChild)
                  : _showManualAttendanceModal(context, provider),
              backgroundColor: const Color(0xFF00B14F),
              icon: Icon(isWaliMurid ? Icons.assignment_turned_in_rounded : Icons.edit_calendar_rounded, color: Colors.white),
              label: Text(
                isWaliMurid ? 'Kirim Surat Izin / Sakit' : 'Input Izin / Sakit',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 90),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Interactive Date Picker Bar (Apple Calendar Header)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(CupertinoIcons.chevron_left_circle_fill, color: Color(0xFF00B14F), size: 28),
                    onPressed: () {
                      setState(() {
                        _selectedDate = _selectedDate.subtract(const Duration(days: 1));
                      });
                    },
                  ),
                  GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2024),
                        lastDate: DateTime(2030),
                        builder: (ctx, child) {
                          return Theme(
                            data: Theme.of(ctx).copyWith(
                              colorScheme: const ColorScheme.light(
                                primary: Color(0xFF00B14F),
                                onPrimary: Colors.white,
                                onSurface: Color(0xFF1C1C1E),
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null) {
                        setState(() => _selectedDate = picked);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F2F7),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_month_rounded, size: 16, color: Color(0xFF00B14F)),
                          const SizedBox(width: 8),
                          Text(
                            _displayDateHuman,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1C1C1E),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(CupertinoIcons.chevron_right_circle_fill, color: Color(0xFF00B14F), size: 28),
                    onPressed: () {
                      setState(() {
                        _selectedDate = _selectedDate.add(const Duration(days: 1));
                      });
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            if (isWaliMurid)
              _buildWaliMuridAttendanceView(context, provider, myChild)
            else ...[
              // 2. Bento Quick Scan Bar (Khusus Wali Kelas / Admin)
              if (role != 'kepsek' && role != 'staff') ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0D3B2E), Color(0xFF00B14F)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00B14F).withOpacity(0.25),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.qr_code_scanner_rounded, color: Colors.white, size: 28),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Presensi Scan QR Otomatis',
                                style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Scan name tag murid untuk absensi tepat waktu.',
                                style: TextStyle(color: Colors.white70, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const QrScannerScreen()));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF008A3D),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          ),
                          child: const Text('Buka Kamera', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // 3. Status Filter Chips (Hadir, Sakit, Izin, Alfa)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      _buildStatusChip('Semua', students.length, const Color(0xFF1C1C1E)),
                      const SizedBox(width: 8),
                      _buildStatusChip('Hadir', hadir, const Color(0xFF34C759)),
                      const SizedBox(width: 8),
                      _buildStatusChip('Sakit', sakit, const Color(0xFF007AFF)),
                      const SizedBox(width: 8),
                      _buildStatusChip('Izin', izin, const Color(0xFFFF9500)),
                      const SizedBox(width: 8),
                      _buildStatusChip('Alfa', alfa, const Color(0xFFFF453A)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // 4. Student Attendance List
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: filteredStudents.isEmpty
                    ? Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.person_off_rounded, size: 52, color: Colors.grey.shade400),
                            const SizedBox(height: 10),
                            Text(
                              'Tidak ada murid berstatus $_selectedStatusFilter',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Pilih filter lain atau ubah status presensi murid.',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredStudents.length,
                        itemBuilder: (context, idx) {
                          final student = filteredStudents[idx];
                          final att = provider.getStudentAttendance(student.id, date: _formattedDateString);
                          final status = att?.status ?? 'Alfa';
                          final notes = att?.notes ?? '';
                          final scanTime = att?.scanTime;

                          final canEditStatus = role == 'wali_kelas' || role == 'admin';
                          return _buildStudentAttendanceCard(context, provider, student, status, notes, scanTime, canEditStatus);
                        },
                      ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status, int count, Color color) {
    final isSelected = _selectedStatusFilter == status;
    return GestureDetector(
      onTap: () => setState(() => _selectedStatusFilter = status),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Text(
              status,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF1C1C1E),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withOpacity(0.25) : color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentAttendanceCard(
    BuildContext context,
    SchoolProvider provider,
    Student student,
    String status,
    String notes,
    String? scanTime,
    bool canEditStatus,
  ) {
    Color statusColor = const Color(0xFFFF3B30); // Alfa
    if (status == 'Hadir') statusColor = const Color(0xFF34C759);
    if (status == 'Sakit') statusColor = const Color(0xFF007AFF);
    if (status == 'Izin') statusColor = const Color(0xFFFF9500);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: statusColor.withOpacity(0.12),
                child: Text(
                  student.name.isNotEmpty ? student.name[0] : 'S',
                  style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1C1C1E)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${student.className} • NISN: ${student.nisn} • Wali: ${student.parentName}',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),

              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: statusColor),
                ),
              ),
            ],
          ),

          // Show Alasan / Notes if Sakit / Izin / Alfa
          if (notes.isNotEmpty || (status == 'Hadir' && scanTime != null)) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(
                    status == 'Hadir' ? Icons.access_time_rounded : Icons.info_outline_rounded,
                    size: 13,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      status == 'Hadir' ? 'Waktu Scan: $scanTime' : 'Alasan: $notes',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Quick Action Buttons (Khusus Wali Kelas dan Admin, tidak untuk Kepsek & TU)
          if (canEditStatus) ...[
            const SizedBox(height: 10),
            const Divider(height: 1, thickness: 0.6),
            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ubah Status:',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey.shade600),
                ),
                Row(
                  children: [
                    _buildQuickBtn(provider, student.id, 'Hadir', 'H', const Color(0xFF34C759), status == 'Hadir'),
                    const SizedBox(width: 6),
                    _buildQuickBtn(provider, student.id, 'Sakit', 'S', const Color(0xFF007AFF), status == 'Sakit'),
                    const SizedBox(width: 6),
                    _buildQuickBtn(provider, student.id, 'Izin', 'I', const Color(0xFFFF9500), status == 'Izin'),
                    const SizedBox(width: 6),
                    _buildQuickBtn(provider, student.id, 'Alfa', 'A', const Color(0xFFFF3B30), status == 'Alfa'),
                    const SizedBox(width: 8),
                    // Edit note button
                    GestureDetector(
                      onTap: () => _showEditNoteModal(context, provider, student, status, notes),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F2F7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.edit_note_rounded, size: 16, color: Color(0xFF1C1C1E)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickBtn(
    SchoolProvider provider,
    int studentId,
    String status,
    String label,
    Color color,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () {
        provider.markAttendance(studentId, status, date: _formattedDateString);
        setState(() {});
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: isSelected ? color : const Color(0xFFF2F2F7),
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(color: color.withOpacity(0.35), blurRadius: 4, offset: const Offset(0, 2)),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // Modal Input Manual Izin / Sakit (MaoneArt Glassmorphism standard)
  void _showManualAttendanceModal(BuildContext context, SchoolProvider provider) {
    int selectedStudentId = provider.students.isNotEmpty ? provider.students.first.id : 1;
    String selectedStatus = 'Sakit';
    DateTime targetDate = _selectedDate;
    final notesCtrl = TextEditingController(text: 'Sakit demam surat dokter');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (mCtx, setMState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Input Presensi Manual Wali Kelas',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1C1C1E)),
              ),
              const SizedBox(height: 4),
              const Text(
                'Catat murid sakit, izin acara, atau alfa dengan tanggal fleksibel.',
                style: TextStyle(fontSize: 12, color: Color(0xFF8E8E93)),
              ),
              const SizedBox(height: 16),

              // Tanggal Picker
              const Text('Tanggal Presensi', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: targetDate,
                    firstDate: DateTime(2024),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) {
                    setMState(() => targetDate = picked);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F2F7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${targetDate.day}/${targetDate.month}/${targetDate.year}",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const Icon(Icons.edit_calendar_rounded, size: 18, color: Color(0xFF00B14F)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Pilih Siswa
              const Text('Pilih Siswa / Murid / Siswa', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F2F7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: selectedStudentId,
                    isExpanded: true,
                    items: provider.students.map((s) {
                      return DropdownMenuItem<int>(
                        value: s.id,
                        child: Text('${s.name} (${s.className})', style: const TextStyle(fontSize: 13)),
                      );
                    }).toList(),
                    onChanged: (v) {
                      if (v != null) setMState(() => selectedStudentId = v);
                    },
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Status Selector
              const Text('Status Kehadiran', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Row(
                children: ['Sakit', 'Izin', 'Alfa', 'Hadir'].map((st) {
                  final isSelected = selectedStatus == st;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: GestureDetector(
                        onTap: () => setMState(() => selectedStatus = st),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF00B14F) : const Color(0xFFF2F2F7),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            st,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 12),

              // Keterangan / Alasan
              const Text('Keterangan / Alasan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F2F7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: notesCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Contoh: Sakit flu surat dokter, Izin acara keluarga...',
                    hintStyle: TextStyle(fontSize: 12, color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // MaoneArt 100% Symmetrical 2-column Grid Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      child: const Text('Batal', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF8E8E93))),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final dateStr = "${targetDate.year}-${targetDate.month.toString().padLeft(2, '0')}-${targetDate.day.toString().padLeft(2, '0')}";
                        provider.markAttendance(
                          selectedStudentId,
                          selectedStatus,
                          notes: notesCtrl.text.trim(),
                          date: dateStr,
                        );
                        Navigator.pop(ctx);
                        setState(() {
                          _selectedDate = targetDate;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Presensi $selectedStatus berhasil dicatat untuk tanggal $dateStr!'),
                            backgroundColor: const Color(0xFF00B14F),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00B14F),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Simpan Presensi', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Modal Edit Alasan / Keterangan
  void _showEditNoteModal(
    BuildContext context,
    SchoolProvider provider,
    Student student,
    String currentStatus,
    String currentNotes,
  ) {
    final noteCtrl = TextEditingController(text: currentNotes);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Keterangan Presensi: ${student.name}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: noteCtrl,
                decoration: const InputDecoration(
                  hintText: 'Tuliskan alasan sakit / izin / surat dokter...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(12),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Batal'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      provider.markAttendance(
                        student.id,
                        currentStatus,
                        notes: noteCtrl.text.trim(),
                        date: _formattedDateString,
                      );
                      Navigator.pop(ctx);
                      setState(() {});
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00B14F),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Simpan', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // VIEW KHUSUS WALI MURID (HANYA ANAKNYA)
  // ==========================================
  Widget _buildWaliMuridAttendanceView(BuildContext context, SchoolProvider provider, Student? myChild) {
    if (myChild == null) {
      return Container(
        padding: const EdgeInsets.all(32),
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Column(
          children: [
            Icon(Icons.person_off_rounded, size: 50, color: Colors.grey.shade400),
            const SizedBox(height: 10),
            const Text('Data Siswa Tidak Ditemukan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 4),
            Text('Akun wali murid belum ditautkan dengan siswa.', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
          ],
        ),
      );
    }

    final att = provider.getStudentAttendance(myChild.id, date: _formattedDateString);
    final status = att?.status ?? 'Belum Presensi';
    final scanTime = att?.scanTime;
    final notes = att?.notes ?? '';

    Color statusColor = const Color(0xFF8E8E93);
    IconData statusIcon = Icons.hourglass_top_rounded;
    if (status == 'Hadir') {
      statusColor = const Color(0xFF34C759);
      statusIcon = Icons.check_circle_rounded;
    } else if (status == 'Sakit') {
      statusColor = const Color(0xFF007AFF);
      statusIcon = Icons.local_hospital_rounded;
    } else if (status == 'Izin') {
      statusColor = const Color(0xFFFF9500);
      statusIcon = Icons.assignment_late_rounded;
    } else if (status == 'Alfa') {
      statusColor = const Color(0xFFFF3B30);
      statusIcon = Icons.cancel_rounded;
    }

    // Hitung akumulasi kehadiran siswa ini
    final allAtts = provider.attendances.where((a) => a.studentId == myChild.id).toList();
    final hadirTot = allAtts.where((a) => a.status == 'Hadir').length;
    final sakitTot = allAtts.where((a) => a.status == 'Sakit').length;
    final izinTot = allAtts.where((a) => a.status == 'Izin').length;
    final alfaTot = allAtts.where((a) => a.status == 'Alfa').length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Kartu Kehadiran Hari/Tanggal Terpilih
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 3)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'STATUS KEHADIRAN',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.grey.shade500, letterSpacing: 0.5),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, color: statusColor, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            status.toUpperCase(),
                            style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  myChild.name,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1C1C1E)),
                ),
                Text(
                  '${myChild.className} • NISN: ${myChild.nisn}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const Divider(height: 24),
                Row(
                  children: [
                    Icon(Icons.schedule_rounded, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 6),
                    Text(
                      'Waktu Presensi: ${scanTime ?? "-"}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1C1C1E)),
                    ),
                  ],
                ),
                if (notes.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.note_alt_outlined, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Keterangan: $notes',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontStyle: FontStyle.italic),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Bento Rekap Kehadiran Siswa
          const Text(
            'Rekap Kehadiran Siswa',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1C1C1E)),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildMiniBentoPill('Hadir', '$hadirTot', const Color(0xFF34C759)),
              const SizedBox(width: 8),
              _buildMiniBentoPill('Sakit', '$sakitTot', const Color(0xFF007AFF)),
              const SizedBox(width: 8),
              _buildMiniBentoPill('Izin', '$izinTot', const Color(0xFFFF9500)),
              const SizedBox(width: 8),
              _buildMiniBentoPill('Alfa', '$alfaTot', const Color(0xFFFF3B30)),
            ],
          ),

          const SizedBox(height: 18),

          // Action Card: Kirim Surat Izin / Keterangan Sakit
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF008A3D), Color(0xFF00B14F)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: const Color(0xFF00B14F).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                  child: const Icon(Icons.assignment_outlined, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Izin Tidak Masuk Sekolah?',
                        style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Kirim surat izin atau sakit langsung ke Wali Kelas.',
                        style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 11),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _showParentLeaveModal(context, provider, myChild),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF008A3D),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                  child: const Text('Buat Izin', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniBentoPill(String title, String count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.25)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          children: [
            Text(count, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 2),
            Text(title, style: TextStyle(fontSize: 10, color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  // Modal Surat Izin Siswa dari Wali Murid
  void _showParentLeaveModal(BuildContext context, SchoolProvider provider, Student? myChild) {
    if (myChild == null) return;
    DateTime targetDate = _selectedDate;
    String selectedStatus = 'Sakit';
    final notesCtrl = TextEditingController(text: 'Sakit demam surat dokter terlampir');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (mCtx, setMState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Kirim Keterangan Izin / Sakit Siswa',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1C1C1E)),
              ),
              const SizedBox(height: 4),
              Text(
                'Siswa: ${myChild.name} • Wali Kelas: ${myChild.className}',
                style: const TextStyle(fontSize: 12, color: Color(0xFF8E8E93)),
              ),
              const SizedBox(height: 16),

              // Tanggal Picker
              const Text('Tanggal', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: targetDate,
                    firstDate: DateTime(2024),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) {
                    setMState(() => targetDate = picked);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F2F7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${targetDate.day}/${targetDate.month}/${targetDate.year}",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const Icon(Icons.edit_calendar_rounded, size: 18, color: Color(0xFF00B14F)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Pilihan Sakit / Izin
              const Text('Kategori', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Row(
                children: ['Sakit', 'Izin'].map((st) {
                  final isSel = selectedStatus == st;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setMState(() {
                        selectedStatus = st;
                        if (st == 'Sakit' && notesCtrl.text.contains('acara')) {
                          notesCtrl.text = 'Sakit demam / istirahat';
                        } else if (st == 'Izin' && notesCtrl.text.contains('demam')) {
                          notesCtrl.text = 'Izin keperluan keluarga mendesak';
                        }
                      }),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSel ? const Color(0xFF00B14F) : const Color(0xFFF2F2F7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          st,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isSel ? Colors.white : const Color(0xFF1C1C1E),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 12),

              // Keterangan / Alasan
              const Text('Alasan / Keterangan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              TextField(
                controller: notesCtrl,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Tuliskan alasan izin atau diagnosis sakit siswa...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: const Color(0xFFF2F2F7),
                ),
              ),

              const SizedBox(height: 20),

              // Tombol Simpan 2 Kolom Grid
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Batal'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final formattedDate = "${targetDate.year}-${targetDate.month.toString().padLeft(2, '0')}-${targetDate.day.toString().padLeft(2, '0')}";
                        provider.submitChildAbsence(
                          date: formattedDate,
                          status: selectedStatus,
                          notes: notesCtrl.text.trim(),
                        );
                        Navigator.pop(ctx);
                        setState(() {});
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Surat keterangan $selectedStatus berhasil dikirim ke Wali Kelas!'),
                            backgroundColor: const Color(0xFF00B14F),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00B14F),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Kirim ke Wali Kelas', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

