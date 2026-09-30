class SchoolClass {
  final int id;
  final String name; // e.g. 'Kelas 1A'
  final String gradeLevel; // e.g. '1'
  String homeroomTeacherName; // e.g. 'Ustadz Abdullah, S.Pd.'
  int capacity;
  bool isActive;

  SchoolClass({
    required this.id,
    required this.name,
    required this.gradeLevel,
    this.homeroomTeacherName = '',
    this.capacity = 30,
    this.isActive = true,
  });

  factory SchoolClass.fromJson(Map<String, dynamic> json) {
    return SchoolClass(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] ?? '',
      gradeLevel: json['grade_level']?.toString() ?? '',
      homeroomTeacherName: json['homeroom_teacher_name'] ?? json['homeroom_teacher'] ?? '',
      capacity: json['capacity'] is int ? json['capacity'] : int.tryParse(json['capacity'].toString()) ?? 30,
      isActive: json['is_active'] == 1 || json['is_active'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'grade_level': gradeLevel,
      'homeroom_teacher_name': homeroomTeacherName,
      'capacity': capacity,
      'is_active': isActive ? 1 : 0,
    };
  }
}
