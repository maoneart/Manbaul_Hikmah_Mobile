class Announcement {
  final int id;
  final String title;
  final String content;
  final String targetAudience; // 'all', 'teachers', 'parents'
  final String category;
  final String author;
  final String date;
  final bool isUrgent;

  Announcement({
    required this.id,
    required this.title,
    required this.content,
    required this.targetAudience,
    required this.category,
    required this.author,
    required this.date,
    this.isUrgent = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'target_audience': targetAudience,
    'category': category,
    'author': author,
    'date': date,
    'is_urgent': isUrgent,
  };

  factory Announcement.fromJson(Map<String, dynamic> json) => Announcement(
    id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
    title: json['title'] ?? '',
    content: json['content'] ?? '',
    targetAudience: json['target_audience'] ?? json['target'] ?? 'all',
    category: json['category'] ?? 'Akademik',
    author: json['author'] ?? json['author_name'] ?? 'Kepala Sekolah',
    date: json['date'] ?? json['created_at'] ?? '',
    isUrgent: json['is_urgent'] == true || json['is_urgent'] == 1,
  );
}
