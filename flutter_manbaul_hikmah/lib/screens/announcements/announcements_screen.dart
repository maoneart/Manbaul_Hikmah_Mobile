import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/school_provider.dart';
import '../../theme/app_theme.dart';

class AnnouncementsScreen extends StatefulWidget {
  final VoidCallback? onNavigateHome;
  const AnnouncementsScreen({super.key, this.onNavigateHome});

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  String _selectedFilter = 'all'; // 'all', 'teachers', 'walikelas', 'parents'

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SchoolProvider>(context);
    final isLeader = provider.currentRole == 'kepsek' || provider.currentRole == 'admin';

    var filtered = provider.announcements;
    if (isLeader && _selectedFilter != 'all') {
      filtered = filtered.where((a) => a.targetAudience == _selectedFilter).toList();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        leading: (Navigator.canPop(context) || widget.onNavigateHome != null)
            ? IconButton(
                icon: const Icon(CupertinoIcons.chevron_back, color: Colors.white, size: 28),
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
        title: const Text('Pengumuman Sekolah', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.gojekGreen,
        actions: [
          if (provider.canCreateAnnouncement || isLeader)
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              tooltip: 'Buat Pengumuman',
              onPressed: () => _showCreateAnnouncementDialog(context, provider),
            ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips (Only for Kepsek & Admin who have multi-audience view)
          if (isLeader)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: Colors.white,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _buildFilterChip('all', 'Semua Audiens'),
                    const SizedBox(width: 8),
                    _buildFilterChip('teachers', 'Dewan Guru'),
                    const SizedBox(width: 8),
                    _buildFilterChip('walikelas', 'Wali Kelas'),
                    const SizedBox(width: 8),
                    _buildFilterChip('parents', 'Wali Murid'),
                  ],
                ),
              ),
            ),
          const Divider(height: 1),

          // Total Count Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'PENGUMUMAN RESMI (${filtered.length})',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8E8E93),
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  isLeader ? 'Akses: Penuh (Kepsek)' : 'Hak Akses: Khusus Akun',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00B14F),
                  ),
                ),
              ],
            ),
          ),

          // Announcement List
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.campaign_outlined, size: 54, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text(
                          'Tidak ada pengumuman saat ini',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Pengumuman resmi dari Kepala Sekolah akan muncul di sini.',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    physics: const BouncingScrollPhysics(),
                    itemCount: filtered.length,
                    itemBuilder: (context, idx) {
                      final a = filtered[idx];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: a.isUrgent
                                          ? const Color(0xFFFF2D55).withOpacity(0.12)
                                          : const Color(0xFF007AFF).withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      a.category,
                                      style: TextStyle(
                                        color: a.isUrgent ? const Color(0xFFFF2D55) : const Color(0xFF007AFF),
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF2F2F7),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      _getTargetLabel(a.targetAudience),
                                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(a.date, style: const TextStyle(fontSize: 10.5, color: Colors.grey)),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                a.title,
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1C1C1E)),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                a.content,
                                style: const TextStyle(fontSize: 12.5, color: Color(0xFF3C3C43), height: 1.45),
                              ),
                              const Divider(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.verified_user_rounded, size: 14, color: Color(0xFF00B14F)),
                                      const SizedBox(width: 4),
                                      Text(
                                        a.author,
                                        style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.black87),
                                      ),
                                    ],
                                  ),
                                  const Text(
                                    'Pemberitahuan Resmi',
                                    style: TextStyle(fontSize: 11, color: Color(0xFF00B14F), fontWeight: FontWeight.bold),
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
      floatingActionButton: (provider.canCreateAnnouncement || isLeader)
          ? FloatingActionButton.extended(
              backgroundColor: const Color(0xFF00B14F),
              onPressed: () => _showCreateAnnouncementDialog(context, provider),
              icon: const Icon(Icons.campaign, color: Colors.white),
              label: const Text('Buat Pengumuman', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          : null,
    );
  }

  String _getTargetLabel(String target) {
    switch (target) {
      case 'teachers':
        return 'Dewan Guru';
      case 'walikelas':
        return 'Khusus Wali Kelas';
      case 'parents':
        return 'Khusus Wali Murid';
      default:
        return 'Semua (Umum)';
    }
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _selectedFilter == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00B14F) : const Color(0xFFF2F2F7),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF3C3C43),
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
    bool isUrgent = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (c, setS) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          title: const Text('Buat Pengumuman Sekolah', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  value: target,
                  decoration: const InputDecoration(labelText: 'Target Audiens (Terpisah)'),
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('Semua (Umum)')),
                    DropdownMenuItem(value: 'teachers', child: Text('Khusus Dewan Guru')),
                    DropdownMenuItem(value: 'walikelas', child: Text('Khusus Wali Kelas')),
                    DropdownMenuItem(value: 'parents', child: Text('Khusus Seluruh Wali Murid')),
                  ],
                  onChanged: (val) => setS(() => target = val!),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: category,
                  decoration: const InputDecoration(labelText: 'Kategori'),
                  items: const [
                    DropdownMenuItem(value: 'Akademik', child: Text('Akademik & Rapor')),
                    DropdownMenuItem(value: 'Kegiatan', child: Text('Kegiatan Sekolah / Sekolah')),
                    DropdownMenuItem(value: 'Libur', child: Text('Informasi Libur')),
                  ],
                  onChanged: (val) => setS(() => category = val!),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(labelText: 'Judul Pengumuman'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: contentCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Isi Pengumuman'),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Checkbox(
                      value: isUrgent,
                      activeColor: const Color(0xFFFF2D55),
                      onChanged: (v) => setS(() => isUrgent = v ?? false),
                    ),
                    const Text('Tandai sebagai Pengumuman Mendesak/Penting', style: TextStyle(fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          actions: [
            // MaoneArt 100% Symmetrical 2-Column Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    child: Text('Batal', style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (titleCtrl.text.trim().isNotEmpty && contentCtrl.text.trim().isNotEmpty) {
                        provider.addAnnouncement(
                          titleCtrl.text.trim(),
                          contentCtrl.text.trim(),
                          target,
                          category,
                          isUrgent: isUrgent,
                        );
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Pengumuman resmi berhasil disiarkan!'),
                            backgroundColor: Color(0xFF00B14F),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00B14F),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text('Siarkan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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

