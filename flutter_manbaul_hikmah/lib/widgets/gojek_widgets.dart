import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/school_provider.dart';
import '../screens/attendance/qr_scanner_screen.dart';
import '../screens/students/student_nametag_screen.dart';

class GojekHeader extends StatelessWidget {
  const GojekHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SchoolProvider>(context);
    final user = provider.currentUser;

    String displayName = user?['name'] ?? 'Pengguna Sekolah';
    String roleBadge = _getRoleLabel(provider.currentRole);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          // ==========================================
          // 1. DYNAMIC ISLAND (APPLE STYLE TOP BAR)
          // ==========================================
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFF1C1C1E), // Apple Dark Obsidian
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Live Status Pill
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF34C759), // iOS Green
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF34C759),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'API Sync Active',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),

                // Center School Tag
                const Text(
                  'MANBAUL HIKMAH',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFE5E5EA),
                    letterSpacing: 0.8,
                  ),
                ),

                // Active Class Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    provider.activeClass,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF30D158),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ==========================================
          // 2. iOS GREETING & ROLE SWITCHER AVATAR
          // ==========================================
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Assalamu\'alaikum 👋',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00B14F).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          roleBadge,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF008A3D),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    displayName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1C1C1E),
                      letterSpacing: -0.4,
                    ),
                  ),
                ],
              ),

              // Interactive Avatar Popup
              PopupMenuButton<String>(
                offset: const Offset(0, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                icon: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00B14F), Color(0xFF008A3D)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00B14F).withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      displayName.isNotEmpty ? displayName.substring(0, 1).toUpperCase() : 'M',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                onSelected: (val) => provider.switchRole(val),
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'kepsek', child: Text('👑 Kepala Sekolah')),
                  const PopupMenuItem(value: 'wali_kelas', child: Text('🧑‍🏫 Wali Kelas 7A')),
                  const PopupMenuItem(value: 'guru', child: Text('📖 Guru Pengajar')),
                  const PopupMenuItem(value: 'wali_murid', child: Text('👨‍👩‍👧 Wali Murid / Santri')),
                  const PopupMenuItem(value: 'admin', child: Text('⚡ Super Admin')),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ==========================================
          // 3. APPLE CARD STYLE IRIDESCENT WALLET CARD
          // ==========================================
          const GopayWalletCard(),
        ],
      ),
    );
  }

  static String _getRoleLabel(String role) {
    switch (role) {
      case 'admin':
        return 'SUPER ADMIN';
      case 'kepsek':
        return 'KEPALA SEKOLAH';
      case 'wali_kelas':
        return 'WALI KELAS';
      case 'guru':
        return 'GURU';
      case 'wali_murid':
        return 'WALI MURID';
      default:
        return role.toUpperCase();
    }
  }
}

class GopayWalletCard extends StatelessWidget {
  const GopayWalletCard({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SchoolProvider>(context);

    final balanceText = provider.isBalanceVisible
        ? 'Rp ${provider.totalSavings.toStringAsFixed(0).replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]}.")}'
        : 'Rp ••••••••';

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0D3B2E), // Apple Dark Emerald
            Color(0xFF007A3D),
            Color(0xFF00B14F),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00B14F).withOpacity(0.3),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background Chip & Waves Graphic Accent
          Positioned(
            right: -20,
            top: -20,
            child: Icon(
              Icons.contactless_rounded,
              size: 130,
              color: Colors.white.withOpacity(0.06),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Card Title & Class Tag
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(Icons.credit_card_rounded, color: Colors.white, size: 14),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'EDUPAY SANTRI CARD',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        provider.activeClass,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // Balance Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Saldo Tabungan Siswa',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: () => provider.toggleBalanceVisibility(),
                              child: Icon(
                                provider.isBalanceVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                                color: Colors.white70,
                                size: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          balanceText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),

                    // Attendance Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Kehadiran Hari Ini',
                            style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.7)),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.check_circle_rounded, color: Color(0xFF30D158), size: 12),
                              const SizedBox(width: 4),
                              Text(
                                '${provider.hadirCount}/${provider.students.length} Hadir',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),
                Divider(color: Colors.white.withOpacity(0.15), height: 1),
                const SizedBox(height: 14),

                // 4 Apple Quick Action Squircles
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildQuickAction(
                      icon: Icons.qr_code_scanner_rounded,
                      label: 'Scan QR',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const QrScannerScreen()),
                        );
                      },
                    ),
                    _buildQuickAction(
                      icon: Icons.savings_rounded,
                      label: 'Setor',
                      onTap: () {
                        // Switch to Tabungan tab
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Buka tab Tabungan di navigasi bawah untuk setor/tarik'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                    _buildQuickAction(
                      icon: Icons.badge_rounded,
                      label: 'Name Tag',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const StudentNametagScreen()),
                        );
                      },
                    ),
                    _buildQuickAction(
                      icon: Icons.table_chart_rounded,
                      label: 'Rekap',
                      onTap: () {
                        final csv = provider.exportAttendanceToCsv();
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            title: const Text('Export Rekap Excel', style: TextStyle(fontWeight: FontWeight.bold)),
                            content: Text('Total ${provider.attendances.length} catatan kehadiran siap diekspor ke Excel/CSV.'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Tutup')),
                            ],
                          ),
                        );
                      },
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

  static Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.25), width: 0.8),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}
