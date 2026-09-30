import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/school_provider.dart';
import '../../theme/app_theme.dart';

class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  String _selectedFilter = 'all'; // 'all', 'teachers', 'parents'

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SchoolProvider>(context);

    var filtered = provider.announcements;
    if (_selectedFilter != 'all') {
      filtered = filtered.where((a) => a.targetAudience == _selectedFilter || a.targetAudience == 'all').toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengumuman Kepala Sekolah', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.gojekGreen,
        actions: [
          if (provider.currentRole == 'kepsek')
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () => _showCreateAnnouncementDialog(context, provider),
            ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: Row(
              children: [
                _buildFilterChip('all', 'Semua'),
                const SizedBox(width: 8),
                _buildFilterChip('teachers', 'Khusus Dewan Guru'),
                const SizedBox(width: 8),
                _buildFilterChip('parents', 'Khusus Wali Murid'),
              ],
            ),
          ),
          const Divider(height: 1),

          // Announcement List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filtered.length,
              itemBuilder: (context, idx) {
                final a = filtered[idx];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.rose.shade50,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                a.category,
                                style: TextStyle(color: Colors.rose.shade700, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Target: ' + (a.targetAudience == 'teachers' ? 'Guru' : (a.targetAudience == 'parents' ? 'Wali Murid' : 'Semua')),
                              style: const TextStyle(fontSize: 10, color: Colors.grey),
                            ),
                            const Spacer(),
                            Text(a.date, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          a.title,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          a.content,
                          style: const TextStyle(fontSize: 12, color: AppTheme.textGrey, height: 1.4),
                        ),
                        const Divider(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              a.author,
                              style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.black54),
                            ),
                            const Text(
                              'Resmi',
                              style: TextStyle(fontSize: 11, color: AppTheme.gojekGreen, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: provider.currentRole == 'kepsek'
          ? FloatingActionButton(
              backgroundColor: Colors.rose,
              onPressed: () => _showCreateAnnouncementDialog(context, provider),
              child: const Icon(Icons.campaign, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _selectedFilter == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.gojekGreen : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _showCreateAnnouncementDialog(BuildContext context, SchoolProvider provider) {
    final titleCtrl = TextEditingController();
    final contentCtrl = TextEditingController();
    String target = 'all';
    String category = 'Akademik';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (c, setS) => AlertDialog(
          title: const Text('Buat Pengumuman Baru (Kepsek)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: target,
                  decoration: const InputDecoration(labelText: 'Target Audiens'),
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('Semua (Guru & Wali Murid)')),
                    DropdownMenuItem(value: 'teachers', child: Text('Khusus Dewan Guru')),
                    DropdownMenuItem(value: 'parents', child: Text('Khusus Seluruh Wali Murid')),
                  ],
                  onChanged: (val) => setS(() => target = val!),
                ),
                DropdownButtonFormField<String>(
                  value: category,
                  decoration: const InputDecoration(labelText: 'Kategori'),
                  items: const [
                    DropdownMenuItem(value: 'Akademik', child: Text('Akademik & Ujian')),
                    DropdownMenuItem(value: 'Kegiatan', child: Text('Kegiatan Pesantren / Sekolah')),
                    DropdownMenuItem(value: 'Libur', child: Text('Informasi Libur')),
                  ],
                  onChanged: (val) => setS(() => category = val!),
                ),
                TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Judul Pengumuman')),
                TextField(controller: contentCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'Isi Pengumuman')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () {
                if (titleCtrl.text.isNotEmpty && contentCtrl.text.isNotEmpty) {
                  provider.addAnnouncement(titleCtrl.text.trim(), contentCtrl.text.trim(), target, category);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Pengumuman berhasil disiarkan!')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.rose),
              child: const Text('Siarkan'),
            ),
          ],
        ),
      ),
    );
  }
}
