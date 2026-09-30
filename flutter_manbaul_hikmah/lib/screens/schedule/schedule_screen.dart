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

  @override
  void initState() {
    super.initState();
    // Default to current weekday
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

    // Filter schedules
    List<SchoolSchedule> daySchedules = provider.schedules.where((s) {
      if (s.day != _selectedDay) return false;

      if (isGuru) {
        // Filter by teacher name or if empty
        final teacherName = user?['name'] ?? '';
        return s.teacherName.toLowerCase().contains(teacherName.toLowerCase()) ||
            teacherName.toLowerCase().contains(s.teacherName.toLowerCase());
      } else if (isMuridOrtu || isWaliKelas) {
        return s.className == _selectedClass;
      } else {
        // Admin / Kepsek / Staff can filter by selected class
        return _selectedClass == 'Semua' || s.className == _selectedClass;
      }
    }).toList();

    // Sort by startTime
    daySchedules.sort((a, b) => a.startTime.compareTo(b.startTime));

    String title = 'Jadwal Pelajaran';
    if (isGuru) {
      title = 'Jadwal Mengajar Guru';
    } else if (isMuridOrtu) {
      title = 'Jadwal Pelajaran Siswa';
    }

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
                fontSize: 17,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.4,
              ),
            ),
            Text(
              isGuru
                  ? (user?['name'] ?? 'Guru Pengajar')
                  : 'Kelas: $_selectedClass',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        centerTitle: false,
        actions: [
          if (role == 'admin' || role == 'kepsek' || role == 'staff')
            PopupMenuButton<String>(
              icon: const Icon(Icons.filter_list_rounded, color: Color(0xFF00B14F)),
              tooltip: 'Pilih Kelas',
              onSelected: (val) {
                setState(() => _selectedClass = val);
              },
              itemBuilder: (ctx) {
                final classOptions = ['Semua', 'Kelas 1A', 'Kelas 1B', 'Kelas 2A', 'Kelas 7A', 'Kelas 7B', 'Kelas 8A', 'Kelas 9A'];
                return classOptions.map((c) {
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
                              : 'Tidak ada kegiatan belajar mengajar terjadwal.',
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
                      return _buildScheduleCard(schedule, isGuru);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard(SchoolSchedule schedule, bool isGuru) {
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
      child: Row(
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
                    Text(
                      isGuru ? 'Kelas: ${schedule.className}' : schedule.teacherName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
