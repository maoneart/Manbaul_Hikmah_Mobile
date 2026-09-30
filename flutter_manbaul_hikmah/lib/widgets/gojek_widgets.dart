import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/school_provider.dart';
import '../theme/app_theme.dart';

class GojekHeader extends StatelessWidget {
  const GojekHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SchoolProvider>(context);

    String nameText = 'Ustadz Budi Santoso, S.Pd.';
    String roleBadge = 'Wali Kelas 7A';
    if (provider.currentRole == 'kepsek') {
      nameText = 'KH. Ahmad Syafei, M.Pd.';
      roleBadge = 'Kepala Sekolah';
    } else if (provider.currentRole == 'wali_murid') {
      nameText = 'Bpk. H. Rahmat';
      roleBadge = 'Wali Murid';
    }

    return Container(
      padding: const EdgeInsets.only(left: 18, right: 18, top: 12, bottom: 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.gojekDarkGreen, AppTheme.gojekGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    child: const Icon(Icons.school, color: AppTheme.gojekGreen, size: 28),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          roleBadge.toUpperCase(),
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        nameText,
                        style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        'SMP & Pesantren Manbaul Hikmah',
                        style: TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
              // Role Switcher Popup
              PopupMenuButton<String>(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.swap_horiz, color: Colors.white, size: 20),
                ),
                onSelected: (val) => provider.switchRole(val),
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'wali_kelas', child: Text('🧑‍🏫 Wali Kelas 7A')),
                  const PopupMenuItem(value: 'kepsek', child: Text('👑 Kepala Sekolah')),
                  const PopupMenuItem(value: 'wali_murid', child: Text('👨‍👩‍👧 Wali Murid')),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          const GopayWalletCard(),
        ],
      ),
    );
  }
}
class GopayWalletCard extends StatelessWidget {
  const GopayWalletCard({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SchoolProvider>(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.gopayCard, AppTheme.gopayBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.account_balance_wallet, color: Colors.white70, size: 16),
                  SizedBox(width: 6),
                  Text(
                    'EDUPAY & PRESENSI',
                    style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  provider.activeClass,
                  style: const TextStyle(color: Colors.cyanAccent, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const Divider(color: Colors.white24, height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('Total Tabungan', style: TextStyle(color: Colors.white70, fontSize: 11)),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () => provider.toggleBalanceVisibility(),
                          child: Icon(
                            provider.isBalanceVisible ? Icons.visibility : Icons.visibility_off,
                            color: Colors.white70,
                            size: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      provider.isBalanceVisible
                          ? 'Rp ${provider.totalSavings.toStringAsFixed(0).replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]}.")}'
                          : 'Rp ••••••••',
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 36, color: Colors.white24),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Presensi Hari Ini', style: TextStyle(color: Colors.white70, fontSize: 11)),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          '${provider.hadirCount}/${provider.students.length} Hadir',
                          style: const TextStyle(color: Colors.lightGreenAccent, fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${(provider.students.isNotEmpty ? (provider.hadirCount / provider.students.length * 100).round() : 0)}%',
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
