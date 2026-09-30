# 🎓 Manbaul Hikmah Mobile
### Smart School & Pesantren Management System
Aplikasi presensi berbasis QR Code Name Tag, pencatatan buku tabungan santri/siswa, dan warta pengumuman resmi Kepala Sekolah dengan antarmuka modern **ala SuperApp Gojek**.

---

## 🌟 Fitur Unggulan

### 1. Dashboard Interaktif Ala Gojek (SuperApp Style)
- **Top Header**: Salam personalisasi, logo sekolah, identitas akun, dan tombol alih peran (**Wali Kelas**, **Kepala Sekolah**, **Wali Murid**).
- **EduPay & Presensi Card** (Gaya Kartu GoPay):
  - Ringkasan total tabungan siswa (dilengkapi tombol mata sensor/sembunyikan saldo).
  - Ringkasan kehadiran siswa hari ini (persentase & jumlah hadir real-time).
  - 4 Tombol Aksi Cepat: **Scan QR**, **Setor Tabungan**, **Name Tag**, dan **Export CSV**.
- **8 Grid Layanan Sekolah**:
  1. 📷 **Presensi QR** (Scanner kamera otomatis & input kehadiran instan)
  2. 👥 **Data Siswa** (Kelola data murid, NISN, wali murid, dan kontak WhatsApp)
  3. 🪪 **Kartu QR** (Generator kartu name tag ber-QR Code resolusi tinggi siap cetak)
  4. 💰 **Tabungan Siswa** (Catat setoran, penarikan, dan buku mutasi saldo)
  5. 📢 **Pengumuman Kepsek** (Jalur komunikasi resmi berjenjang ke Guru / Wali Murid)
  6. 📅 **Kalender Presensi** (Monitoring kehadiran bulanan per tanggal)
  7. 📊 **Rekap & Export** (Unduh laporan presensi & tabungan ke format CSV/Excel)
  8. ⚙️ **Pengaturan** (Backup/restore data sistem via JSON)
- **Warta Manbaul Hikmah**: Carousel banner pengumuman dan kegiatan sekolah.
- **Aktivitas Terbaru**: Feed transaksi tabungan dan log absensi terkini.

### 2. Presensi Siswa Berbasis Name Tag QR Code
- **Cetak Name Tag**: Setiap siswa otomatis memiliki kartu tanda pengenal digital dengan foto, identitas lengkap, dan kode QR unik.
- **Scanner Kamera Real-Time**: Guru cukup mengarahkan kamera ke name tag siswa, sistem otomatis menandai siswa **HADIR** dan mencatat jam scan secara akurat.
- **Simulasi Scan Cepat**: Tersedia tombol simulasi untuk pengujian cepat di laptop/browser tanpa perlu mencetak kartu fisik terlebih dahulu.
- **Input Manual (H/S/I/A)**: Guru dapat mengubah status siswa yang berhalangan menjadi **Sakit (S)**, **Izin (I)**, atau **Alfa (A)** secara instan.

### 3. Buku Tabungan Digital Santri & Siswa
- **Setor & Tarik Tunai**: Pencatatan uang saku dan tabungan santri dilengkapi tombol nominal instan (10rb, 20rb, 50rb, 100rb).
- **Buku Mutasi**: Setiap siswa memiliki catatan buku tabungan digital yang merekam debit, kredit, sisa saldo, serta keterangan transaksi.
- **Export Laporan Tabungan**: Rekapitulasi kas tabungan dapat diunduh dalam format spreadsheet.

### 4. Pengumuman Kepala Sekolah Berjenjang
- Kepala Sekolah dapat mempublikasikan pengumuman dengan menyaring target pembaca:
  - **Khusus Dewan Guru & Wali Kelas**
  - **Khusus Wali Murid / Siswa**
  - **Semua Pihak**

---

## 🚀 Panduan Menjalankan di Laragon (Web)

1. Pastikan folder berada di:
   ```
   C:\laragon\www\Manbaul_Hikmah_Mobile
   ```
2. Buka aplikasi **Laragon**, lalu klik tombol **Start All** (Apache & MySQL).
3. Buka **phpMyAdmin** (`http://localhost/phpmyadmin`) atau HeidiSQL, lalu import file `database.sql`.
4. Buka aplikasi di browser melalui URL:
   ```
   http://localhost/Manbaul_Hikmah_Mobile/
   ```
5. Aplikasi web siap digunakan dengan fitur lengkap, scanner kamera, kartu name tag, tabungan, dan ekspor data!

---

## 📱 Build APK Android di GitHub Actions

Repositori ini telah dilengkapi pipeline otomatis **GitHub Actions** (`.github/workflows/build_apk.yml`):
1. Setiap kali kode di-push ke GitHub, GitHub Actions otomatis mem-build file installer Android:
   `app-release.apk`
2. **Cara Mengunduh APK**:
   - Buka tab **Actions** di repositori GitHub Anda: `https://github.com/maoneart/Manbaul_Hikmah_Mobile/actions`
   - Klik workflow build terbaru yang bertanda centang hijau.
   - Gulir ke bagian **Artifacts** di bagian bawah.
   - Klik **Manbaul-Hikmah-Release-APK** untuk mengunduh file APK dan install di HP Android Anda!

---

## 📂 Struktur Proyek

```
C:\laragon\www\Manbaul_Hikmah_Mobile\
├── .github/
│   └── workflows/
│       └── build_apk.yml             # Pipeline Auto-Build Android APK & Flutter Web
├── api/                              # REST API PHP untuk Mobile & Web
│   ├── attendance.php                # Endpoint presensi QR & manual
│   ├── students.php                  # Endpoint data siswa & name tag QR
│   ├── savings.php                   # Endpoint tabungan (setor/tarik/mutasi)
│   ├── announcements.php             # Endpoint pengumuman kepsek
│   └── auth.php                      # Endpoint login & role
├── config/
│   └── database.php                  # Koneksi PDO MySQL Laragon
├── database.sql                      # Skema tabel MySQL + Data awal (Seed)
├── index.php                         # Web Dashboard Utama (Tampilan Ala Gojek)
├── views/                            # Komponen Antarmuka Web
│   ├── header.php                    # Header & GoPay style card
│   ├── beranda.php                   # Layanan grid 8 menu & banner
│   ├── presensi.php                  # Scanner kamera web & tabel kehadiran
│   ├── nametag.php                   # Pembuat kartu name tag QR siap cetak
│   ├── tabungan.php                  # Buku tabungan & mutasi siswa
│   ├── pengumuman.php                # Feed & input pengumuman kepsek
│   ├── siswa.php                     # Direktori siswa
│   ├── kalender.php                  # Kalender presensi bulanan
│   ├── rekap.php                     # Ekspor CSV
│   └── modals.php                    # Popup dialog interaktif
├── assets/
│   └── js/
│       └── app.js                    # Core client engine (offline-first & sound chime)
├── flutter_manbaul_hikmah/           # Proyek Lengkap Flutter
│   ├── pubspec.yaml
│   ├── lib/
│   │   ├── main.dart
│   │   ├── models/                   # Student, Attendance, Savings, Announcement
│   │   ├── theme/app_theme.dart      # Gojek Green & Clean UI
│   │   ├── providers/                # State management reaktif
│   │   ├── screens/                  # Dashboard, Presensi, QR Scanner, Tabungan, dll
│   │   └── widgets/                  # Gojek Header, Wallet Card, Grid Icons, dll
└── README.md
```

---
*Dikembangkan dengan penuh dedikasi untuk kemajuan digitalisasi SMP & Pesantren Manbaul Hikmah.*
