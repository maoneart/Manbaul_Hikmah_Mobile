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
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  DateTime _selectedDate = DateTime.now();
  String _selectedStatusFilter = 'Semua'; // 'Semua', 'Hadir', 'Sakit', 'Izin', 'Alfa'

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

    // List of students for active class
    final students = provider.students;

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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Presensi & Kehadiran Santri',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1C1C1E)),
            ),
            Text(
              'Kelas: ${provider.activeClass} • ${students.length} Siswa',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        actions: [
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
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showManualAttendanceModal(context, provider),
        backgroundColor: const Color(0xFF00B14F),
        icon: const Icon(Icons.edit_calendar_rounded, color: Colors.white),
        label: const Text('Input Izin / Sakit', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
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

            // 2. Bento Quick Scan Bar
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
                    _buildStatusChip('Alfa', alfa, const Color(0xFFFF3B30)),
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

                        return _buildStudentAttendanceCard(context, provider, student, status, notes, scanTime);
                      },
                    ),
            ),
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
                      'NISN: ${student.nisn} • Wali: ${student.parentName}',
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

          const SizedBox(height: 10),
          const Divider(height: 1, thickness: 0.6),
          const SizedBox(height: 8),

          // Quick Action Buttons: H, S, I, A + Detail Note
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
              const Text('Pilih Santri / Siswa', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
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
}
