import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const String appVersion = '1.0.0';
  static const String appName = 'Manbaul Hikmah Mobile';
  static const String institution = 'Pondok Pesantren & Madrasah Manbaul Hikmah';
  static const String developer = 'MaoneArt (Hermawan)';
  static const String copyright = '© 2026 MaoneArt';

  @override
  Widget build(BuildContext context) {
    const primaryAccent = Color(0xFF00B14F); // Green accent
    const cardBg = Colors.white;
    const borderCol = Color(0xFFE5E5EA);
    const textHead = Color(0xFF1C1C1E);
    const textSub = Color(0xFF8E8E93);

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        title: const Text(
          'Tentang Aplikasi',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 17,
            color: textHead,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            CupertinoIcons.chevron_back,
            color: Color(0xFF007AFF),
            size: 26,
          ),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Kembali',
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // App Icon Container
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00B14F), Color(0xFF007AFF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00B14F).withOpacity(0.25),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.school_rounded,
                        size: 52,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // App Name
                  const Text(
                    appName,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: textHead,
                      letterSpacing: 0.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    institution,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: primaryAccent,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),

                  // Info Card (iOS Grouped Style)
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: borderCol),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildInfoRow(
                          icon: CupertinoIcons.app_badge_fill,
                          iconColor: const Color(0xFF007AFF),
                          label: 'Nama Aplikasi',
                          value: appName,
                          textHead: textHead,
                          textSub: textSub,
                          showDivider: true,
                        ),
                        _buildInfoRow(
                          icon: CupertinoIcons.tag_fill,
                          iconColor: const Color(0xFF00B14F),
                          label: 'Versi Rilis',
                          value: 'Version $appVersion (Official)',
                          textHead: textHead,
                          textSub: textSub,
                          showDivider: true,
                        ),
                        _buildInfoRow(
                          icon: CupertinoIcons.person_crop_circle_fill_badge_checkmark,
                          iconColor: const Color(0xFF8E8E93),
                          label: 'Dikembangkan Oleh',
                          value: developer,
                          textHead: textHead,
                          textSub: textSub,
                          showDivider: true,
                        ),
                        _buildInfoRow(
                          icon: CupertinoIcons.shield_fill,
                          iconColor: const Color(0xFFFF9500),
                          label: 'Ekosistem Sistem',
                          value: 'Presensi QR, Tabungan & Portal Santri',
                          textHead: textHead,
                          textSub: textSub,
                          showDivider: false,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Simple Copyright
                  const Text(
                    copyright,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: textSub,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'All rights reserved. Dedicated to Pesantren & Madrasah.',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: textSub.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required Color textHead,
    required Color textSub,
    required bool showDivider,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: iconColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: textSub,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: textHead,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          const Divider(
            height: 1,
            thickness: 1,
            color: Color(0xFFF2F2F7),
          ),
      ],
    );
  }
}
