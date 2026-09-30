import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/schedule.dart';
import '../../providers/school_provider.dart';
import '../../theme/app_theme.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final List<String> _days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];
  late String _selectedDay;
  String _selectedClass = '';

  final List<String> _teacherOptions = [
    'Ustadzah Fatimah, S.Pd.',
    'Ustadzah Nurul Hidayah, S.Pd.',
    'Ustadzah Maryam, S.Pd.',
    'Ustadz Ahmad Fauzan, S.Pd.I.',
    'Ustadzah Khadijah, S.Pd.',
    'Ustadz Zainal Abidin, S.Pd.',
    'Ustadz Ridwan Kamil, S.Pd.',
    'Ustadzah Aisyah, S.Pd.I.',
    'Ustadz Luqman Hakim, S.Pd.',
    'Ustadz Hendra Pratama, S.Pd.',
    'Ustadzah Dewi Sartika, S.Pd.',
    'Ustadz Hasan Basri, S.Pd.I.',
    'Ustadz Budi Santoso, S.Pd.',
    'Ustadzah Siti Aminah, S.Pd.I.',
    'Ustadz Yusuf Mansur, S.Pd.',
    'Ustadz Abdullah Syafi\'i, M.Pd.',
    'Ustadzah Halimah, S.Pd.',
    'Ustadz Ali Ridho, S.Pd.I.',
    'KH. Ahmad Syafei, M.Pd.',
  ];

  final List<String> _subjectOptions = [
    'Tahfidz Al-Qur\'an Juz Amma',
    'Tajwid & Makharijul Huruf',
    'Aqidah Akhlak',
    'Fiqih Ibadah & Amaliyah',
    'Hadits Arbain Nawawi',
    'Bahasa Arab Dasar',
    'Nahwu & Shorof Dasar',
    'Sejarah Kebudayaan Islam',
    'Pendidikan Agama Islam (PAI)',
    'Matematika Terpadu',
    'Bahasa Indonesia',
    'Ilmu Pengetahuan Alam (IPA)',
    'Ilmu Pengetahuan Sosial (IPS)',
    'Pendidikan Pancasila & PKn',
    'Pendidikan Jasmani & Olahraga (PJOK)',
    'Seni Budaya & Prakarya',
    'Bahasa Inggris Dasar',
    'Muhadharah / Khitobah Siswa',
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    switch (now.weekday) {
      case 1:
        _selectedDay = 'Senin';
        break;
      case 2:
        _selectedDay = 'Selasa';
        break;
      case 3:
        _selectedDay = 'Rabu';
        break;
      case 4:
        _selectedDay = 'Kamis';
        break;
      case 5:
        _selectedDay = 'Jumat';
        break;
      case 6:
        _selectedDay = 'Sabtu';
        break;
      default:
        _selectedDay = 'Senin';
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SchoolProvider>(context);
    final role = provider.currentRole;
    final user = provider.currentUser;

    if (_selectedClass.isEmpty) {
      _selectedClass = user?['assigned_class'] ?? provider.activeClass;
    }

    final isGuru = role == 'guru';
    final isMuridOrtu = role == 'wali_murid';
    final isWaliKelas = role == 'wali_kelas';
    final canManageSchedule = role == 'staff' || role == 'admin' || role == 'kepsek';

    // Filter schedules
    List<SchoolSchedule> daySchedules = provider.schedules.where((s) {
      if (s.day != _selectedDay) return false;

      if (isGuru) {
        final teacherName = user?['name'] ?? '';
        return s.teacherName.toLowerCase().contains(teacherName.toLowerCase()) ||
            teacherName.toLowerCase().contains(s.teacherName.toLowerCase());
      } else if (isMuridOrtu || isWaliKelas) {
        return s.className == _selectedClass;
      } else {
        return _selectedClass == 'Semua' || s.className == _selectedClass;
      }
    }).toList();

    daySchedules.sort((a, b) => a.startTime.compareTo(b.startTime));

    String title = 'Jadwal Pelajaran';
    if (isGuru) {
      title = 'Jadwal Mengajar Guru';
    } else if (isMuridOrtu) {
      title = 'Jadwal Pelajaran Siswa';
    }

    final availableClasses = ['Semua', ...provider.classes.map((c) => c.name)];

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7), // iOS Grouped Background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.chevron_back, color: Color(0xFF1C1C1E), size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF1C1C1E),
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.4,
              ),
            ),
            Text(
              isGuru
                  ? (user?['name'] ?? 'Guru Pengajar')
                  : 'Rombel: $_selectedClass',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        centerTitle: false,
        actions: [
          if (canManageSchedule)
            IconButton(
              icon: const Icon(Icons.add_circle_outline_rounded, color: Color(0xFF00B14F), size: 26),
              tooltip: 'Input Jadwal Baru',
              onPressed: () => _showAddScheduleModal(context, provider),
            ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list_rounded, color: Color(0xFF007AFF)),
            tooltip: 'Filter Rombel Kelas',
            onSelected: (val) {
              setState(() => _selectedClass = val);
            },
            itemBuilder: (ctx) {
              return availableClasses.map((c) {
                return PopupMenuItem(
                  value: c,
                  child: Text(c, style: TextStyle(fontWeight: _selectedClass == c ? FontWeight.bold : FontWeight.normal)),
                );
              }).toList();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // 1. Day Selector Chips (iOS Segmented Style)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: _days.map((day) {
                  final isSelected = day == _selectedDay;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedDay = day),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF00B14F) : const Color(0xFFF2F2F7),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFF00B14F).withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ]
                              : null,
                        ),
                        child: Text(
                          day,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                            color: isSelected ? Colors.white : const Color(0xFF8E8E93),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // 2. Schedule Card List
          Expanded(
            child: daySchedules.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.event_busy_rounded, size: 56, color: Colors.grey.shade400),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Tidak Ada Jadwal di Hari $_selectedDay',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1C1C1E),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          isGuru
                              ? 'Tidak ada jam mengajar untuk Anda di hari ini.'
                              : (canManageSchedule
                                  ? 'Klik tombol + di atas untuk menambahkan jadwal pelajaran baru.'
                                  : 'Tidak ada kegiatan belajar mengajar terjadwal.'),
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    itemCount: daySchedules.length,
                    itemBuilder: (context, index) {
                      final schedule = daySchedules[index];
                      return _buildScheduleCard(context, provider, schedule, isGuru, canManageSchedule);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: canManageSchedule
          ? FloatingActionButton.extended(
              backgroundColor: const Color(0xFF00B14F),
              onPressed: () => _showAddScheduleModal(context, provider),
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: const Text('Input Jadwal', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            )
          : null,
    );
  }

  Widget _buildScheduleCard(
    BuildContext context,
    SchoolProvider provider,
    SchoolSchedule schedule,
    bool isGuru,
    bool canManage,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Time badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF00B14F).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.access_time_filled_rounded, size: 18, color: Color(0xFF00B14F)),
                    const SizedBox(height: 4),
                    Text(
                      schedule.startTime,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF008A3D),
                      ),
                    ),
                    Text(
                      schedule.endTime,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 14),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF007AFF).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            schedule.className,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF007AFF),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            schedule.room,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      schedule.subject,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1C1C1E),
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          isGuru ? Icons.class_outlined : Icons.person_outline_rounded,
                          size: 14,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            isGuru ? 'Kelas: ${schedule.className}' : schedule.teacherName,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (canManage) ...[
            const Divider(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _showEditScheduleModal(context, provider, schedule),
                  icon: const Icon(Icons.edit_rounded, size: 14, color: Color(0xFF007AFF)),
                  label: const Text('Edit', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF007AFF))),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => _confirmDeleteSchedule(context, provider, schedule),
                  icon: const Icon(Icons.delete_outline_rounded, size: 14, color: Color(0xFFFF3B30)),
                  label: const Text('Hapus', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFFF3B30))),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // MODAL TAMBAH JADWAL (STAFF TU)
  void _showAddScheduleModal(BuildContext context, SchoolProvider provider) {
    String selectedSubject = _subjectOptions.first;
    String selectedClass = provider.classes.isNotEmpty ? provider.classes.first.name : 'Kelas 1A';
    String selectedTeacher = _teacherOptions.first;
    String selectedDay = _selectedDay;
    final startCtrl = TextEditingController(text: '07:30');
    final endCtrl = TextEditingController(text: '09:00');
    final roomCtrl = TextEditingController(text: 'Ruang $selectedClass');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Input Jadwal Pelajaran Baru',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1C1C1E)),
                ),
                const SizedBox(height: 4),
                Text(
                  'Penugasan mata pelajaran dan ustadz pengampu di kelas.',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 16),

                // Mata Pelajaran
                const Text('Mata Pelajaran', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(color: const Color(0xFFF2F2F7), borderRadius: BorderRadius.circular(12)),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedSubject,
                      isExpanded: true,
                      items: _subjectOptions.map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 12)))).toList(),
                      onChanged: (v) {
                        if (v != null) setModalState(() => selectedSubject = v);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Rombel & Hari
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Rombel Kelas', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(color: const Color(0xFFF2F2F7), borderRadius: BorderRadius.circular(12)),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: selectedClass,
                                isExpanded: true,
                                items: provider.classes.map((c) => DropdownMenuItem(value: c.name, child: Text(c.name, style: const TextStyle(fontSize: 12)))).toList(),
                                onChanged: (v) {
                                  if (v != null) {
                                    setModalState(() {
                                      selectedClass = v;
                                      roomCtrl.text = 'Ruang $v';
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Hari Mengajar', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(color: const Color(0xFFF2F2F7), borderRadius: BorderRadius.circular(12)),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: selectedDay,
                                isExpanded: true,
                                items: _days.map((d) => DropdownMenuItem(value: d, child: Text(d, style: const TextStyle(fontSize: 12)))).toList(),
                                onChanged: (v) {
                                  if (v != null) setModalState(() => selectedDay = v);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Guru Pengampu
                const Text('Ustadz / Guru Pengampu', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(color: const Color(0xFFF2F2F7), borderRadius: BorderRadius.circular(12)),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedTeacher,
                      isExpanded: true,
                      items: _teacherOptions.map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 12)))).toList(),
                      onChanged: (v) {
                        if (v != null) setModalState(() => selectedTeacher = v);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Jam Mulai, Selesai, Ruang
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Jam Mulai', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          TextField(
                            controller: startCtrl,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xFFF2F2F7),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Jam Selesai', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          TextField(
                            controller: endCtrl,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xFFF2F2F7),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Ruangan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          TextField(
                            controller: roomCtrl,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xFFF2F2F7),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Batal', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          final newSchedule = SchoolSchedule(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            day: selectedDay,
                            subject: selectedSubject,
                            className: selectedClass,
                            teacherName: selectedTeacher,
                            startTime: startCtrl.text.trim(),
                            endTime: endCtrl.text.trim(),
                            room: roomCtrl.text.trim(),
                          );
                          provider.addSchedule(newSchedule);
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Jadwal $selectedSubject untuk $selectedClass berhasil disimpan!'),
                              backgroundColor: const Color(0xFF00B14F),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00B14F),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Simpan Jadwal', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // MODAL EDIT JADWAL (STAFF TU)
  void _showEditScheduleModal(BuildContext context, SchoolProvider provider, SchoolSchedule s) {
    String selectedSubject = _subjectOptions.contains(s.subject) ? s.subject : _subjectOptions.first;
    String selectedClass = s.className;
    String selectedTeacher = _teacherOptions.contains(s.teacherName) ? s.teacherName : _teacherOptions.first;
    String selectedDay = s.day;
    final startCtrl = TextEditingController(text: s.startTime);
    final endCtrl = TextEditingController(text: s.endTime);
    final roomCtrl = TextEditingController(text: s.room);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Edit Jadwal Pelajaran', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                const Text('Mata Pelajaran', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(color: const Color(0xFFF2F2F7), borderRadius: BorderRadius.circular(12)),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedSubject,
                      isExpanded: true,
                      items: _subjectOptions.map((sub) => DropdownMenuItem(value: sub, child: Text(sub, style: const TextStyle(fontSize: 12)))).toList(),
                      onChanged: (v) {
                        if (v != null) setModalState(() => selectedSubject = v);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Rombel Kelas', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(color: const Color(0xFFF2F2F7), borderRadius: BorderRadius.circular(12)),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: selectedClass,
                                isExpanded: true,
                                items: provider.classes.map((c) => DropdownMenuItem(value: c.name, child: Text(c.name, style: const TextStyle(fontSize: 12)))).toList(),
                                onChanged: (v) {
                                  if (v != null) setModalState(() => selectedClass = v);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Hari Mengajar', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(color: const Color(0xFFF2F2F7), borderRadius: BorderRadius.circular(12)),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: selectedDay,
                                isExpanded: true,
                                items: _days.map((d) => DropdownMenuItem(value: d, child: Text(d, style: const TextStyle(fontSize: 12)))).toList(),
                                onChanged: (v) {
                                  if (v != null) setModalState(() => selectedDay = v);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text('Ustadz / Guru Pengampu', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(color: const Color(0xFFF2F2F7), borderRadius: BorderRadius.circular(12)),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedTeacher,
                      isExpanded: true,
                      items: _teacherOptions.map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 12)))).toList(),
                      onChanged: (v) {
                        if (v != null) setModalState(() => selectedTeacher = v);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Jam Mulai', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          TextField(
                            controller: startCtrl,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xFFF2F2F7),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Jam Selesai', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          TextField(
                            controller: endCtrl,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xFFF2F2F7),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Ruangan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          TextField(
                            controller: roomCtrl,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xFFF2F2F7),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Batal', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          final updated = SchoolSchedule(
                            id: s.id,
                            day: selectedDay,
                            subject: selectedSubject,
                            className: selectedClass,
                            teacherName: selectedTeacher,
                            startTime: startCtrl.text.trim(),
                            endTime: endCtrl.text.trim(),
                            room: roomCtrl.text.trim(),
                          );
                          provider.updateSchedule(updated);
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Jadwal pelajaran berhasil diperbarui!'), backgroundColor: Color(0xFF007AFF)),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF007AFF),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Perbarui Jadwal', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // KONFIRMASI HAPUS JADWAL
  void _confirmDeleteSchedule(BuildContext context, SchoolProvider provider, SchoolSchedule s) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Jadwal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Text('Apakah Anda yakin ingin menghapus jadwal ${s.subject} di ${s.className} (${s.day})?'),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Batal'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    provider.deleteSchedule(s.id);
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Jadwal berhasil dihapus.'), backgroundColor: Color(0xFFFF3B30)),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF3B30),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Hapus Jadwal'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
