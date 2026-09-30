class SchoolSchedule {
  final String id;
  final String day; // 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'
  final String subject;
  final String className;
  final String teacherName;
  final String startTime;
  final String endTime;
  final String room;

  const SchoolSchedule({
    required this.id,
    required this.day,
    required this.subject,
    required this.className,
    required this.teacherName,
    required this.startTime,
    required this.endTime,
    required this.room,
  });

  factory SchoolSchedule.fromJson(Map<String, dynamic> json) {
    return SchoolSchedule(
      id: json['id']?.toString() ?? '',
      day: json['day'] ?? 'Senin',
      subject: json['subject'] ?? '',
      className: json['class_name'] ?? json['className'] ?? '',
      teacherName: json['teacher_name'] ?? json['teacherName'] ?? '',
      startTime: json['start_time'] ?? json['startTime'] ?? '',
      endTime: json['end_time'] ?? json['endTime'] ?? '',
      room: json['room'] ?? 'Ruang Kelas',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'day': day,
      'subject': subject,
      'class_name': className,
      'teacher_name': teacherName,
      'start_time': startTime,
      'end_time': endTime,
      'room': room,
    };
  }
}
