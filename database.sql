SET FOREIGN_KEY_CHECKS = 0;
-- ========================================================
-- Database Schema & Seed Data for SDIT Manbaul Hikmah Mobile
-- Aplikasi Presensi QR, Tabungan Siswa, Tagihan SPP, dan Pengumuman
-- ========================================================

-- 1. Table: Classes
DROP TABLE IF EXISTS `classes`;
CREATE TABLE `classes` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(50) NOT NULL,
  `wali_kelas_name` VARCHAR(100) NOT NULL,
  `academic_year` VARCHAR(20) DEFAULT '2026/2027',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 2. Table: Users
DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `username` VARCHAR(50) UNIQUE NOT NULL,
  `password` VARCHAR(255) NOT NULL,
  `name` VARCHAR(100) NOT NULL,
  `role` ENUM('admin', 'kepsek', 'staff', 'wali_kelas', 'guru', 'wali_murid') NOT NULL,
  `phone` VARCHAR(20),
  `nik` VARCHAR(20) DEFAULT '',
  `assigned_class` VARCHAR(50) DEFAULT NULL,
  `student_id` INT DEFAULT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 3. Table: Students
DROP TABLE IF EXISTS `students`;
CREATE TABLE `students` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `nisn` VARCHAR(20) UNIQUE NOT NULL,
  `student_nik` VARCHAR(20) DEFAULT '',
  `name` VARCHAR(120) NOT NULL,
  `gender` ENUM('L', 'P') NOT NULL DEFAULT 'L',
  `class_name` VARCHAR(50) NOT NULL,
  `entry_year` VARCHAR(10) DEFAULT '2024',
  `admission_date` VARCHAR(30) DEFAULT '',
  `status` ENUM('Aktif', 'Lulus', 'Pindah') DEFAULT 'Aktif',
  `graduation_date` VARCHAR(30) DEFAULT '',
  `address` VARCHAR(255) DEFAULT '',
  `birth_place_date` VARCHAR(100) DEFAULT '',
  `parent_name` VARCHAR(100) NOT NULL,
  `parent_phone` VARCHAR(20) NOT NULL,
  `parent_nik` VARCHAR(20) DEFAULT '',
  `balance` DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  `qr_code_token` VARCHAR(100) UNIQUE NOT NULL,
  `photo_url` VARCHAR(255) DEFAULT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 4. Table: Attendances
DROP TABLE IF EXISTS `attendances`;
CREATE TABLE `attendances` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `student_id` INT NOT NULL,
  `class_name` VARCHAR(50) NOT NULL,
  `attendance_date` DATE NOT NULL,
  `status` ENUM('Hadir', 'Terlambat', 'Sakit', 'Izin', 'Alfa') NOT NULL DEFAULT 'Alfa',
  `scan_time` TIME DEFAULT NULL,
  `recorded_by` VARCHAR(100) DEFAULT 'Wali Kelas',
  `notes` VARCHAR(255) DEFAULT '',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY `unique_student_date` (`student_id`, `attendance_date`),
  CONSTRAINT `fk_att_student` FOREIGN KEY (`student_id`) REFERENCES `students` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 5. Table: Savings Transactions
DROP TABLE IF EXISTS `savings_transactions`;
CREATE TABLE `savings_transactions` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `student_id` INT NOT NULL,
  `transaction_type` ENUM('setor', 'tarik') NOT NULL,
  `amount` DECIMAL(12,2) NOT NULL,
  `balance_after` DECIMAL(12,2) NOT NULL,
  `receipt_no` VARCHAR(50) DEFAULT '',
  `notes` VARCHAR(255) DEFAULT 'Tabungan Siswa',
  `recorded_by` VARCHAR(100) DEFAULT 'Wali Kelas',
  `transaction_date` DATETIME DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT `fk_savings_student` FOREIGN KEY (`student_id`) REFERENCES `students` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 6. Table: Announcements
DROP TABLE IF EXISTS `announcements`;
CREATE TABLE `announcements` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `title` VARCHAR(200) NOT NULL,
  `content` TEXT NOT NULL,
  `author_name` VARCHAR(100) NOT NULL DEFAULT 'Kepala Sekolah',
  `author_role` VARCHAR(50) NOT NULL DEFAULT 'Kepala Sekolah',
  `target_audience` ENUM('all', 'teachers', 'parents', 'walikelas') NOT NULL DEFAULT 'all',
  `category` VARCHAR(50) DEFAULT 'Akademik',
  `is_urgent` TINYINT(1) DEFAULT 0,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 7. Table: Payment Bills (SPP & Biaya Pendidikan)
DROP TABLE IF EXISTS `payment_bills`;
CREATE TABLE `payment_bills` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `student_id` INT NOT NULL,
  `student_name` VARCHAR(120) NOT NULL,
  `class_name` VARCHAR(50) NOT NULL,
  `category` VARCHAR(100) NOT NULL DEFAULT 'SPP Bulanan',
  `month` VARCHAR(20) DEFAULT NULL,
  `academic_year` VARCHAR(20) DEFAULT '2026/2027',
  `amount` DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  `paid_amount` DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  `status` ENUM('Belum Lunas', 'Menunggu Verifikasi', 'Lunas') NOT NULL DEFAULT 'Belum Lunas',
  `due_date` VARCHAR(30) DEFAULT '10 Setiap Bulan',
  `paid_date` VARCHAR(30) DEFAULT NULL,
  `payment_method` VARCHAR(50) DEFAULT NULL,
  `invoice_number` VARCHAR(50) DEFAULT '',
  `verified_by` VARCHAR(100) DEFAULT NULL,
  `notes` VARCHAR(255) DEFAULT '',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX (`student_id`),
  INDEX (`class_name`),
  INDEX (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 8. Table: School Profile (Identitas Lembaga, Kontak WA TU, Rekening Resmi)
DROP TABLE IF EXISTS `school_profile`;
CREATE TABLE `school_profile` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `school_name` VARCHAR(150) NOT NULL DEFAULT 'SDIT Manbaul Hikmah',
  `npsn` VARCHAR(20) NOT NULL DEFAULT '20260001',
  `address` TEXT NOT NULL,
  `phone` VARCHAR(30) DEFAULT '021-88997766',
  `tu_whatsapp` VARCHAR(30) NOT NULL DEFAULT '6281234567890',
  `bank_name` VARCHAR(80) NOT NULL DEFAULT 'Bank Syariah Indonesia (BSI)',
  `bank_account_number` VARCHAR(50) NOT NULL DEFAULT '7188299102',
  `bank_account_holder` VARCHAR(100) NOT NULL DEFAULT 'Yayasan Manbaul Hikmah',
  `bank_name_2` VARCHAR(80) DEFAULT 'Bank Mandiri',
  `bank_account_number_2` VARCHAR(50) DEFAULT '1560012345678',
  `bank_account_holder_2` VARCHAR(100) DEFAULT 'Yayasan Manbaul Hikmah',
  `kepsek_name` VARCHAR(120) NOT NULL DEFAULT 'KH. Ahmad Syafei, M.Pd.',
  `kepsek_nip` VARCHAR(50) DEFAULT '197508122002121003',
  `tu_name` VARCHAR(120) NOT NULL DEFAULT 'Ustadzah Halimah, S.E.',
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `school_profile` (`id`, `school_name`, `npsn`, `address`, `phone`, `tu_whatsapp`, `bank_name`, `bank_account_number`, `bank_account_holder`, `bank_name_2`, `bank_account_number_2`, `bank_account_holder_2`, `kepsek_name`, `kepsek_nip`, `tu_name`) VALUES
(1, 'SDIT Manbaul Hikmah', '20260001', 'Jl. KH. Noer Ali No. 45, Karang Satria, Tambun Utara, Bekasi, Jawa Barat 17510', '021-88997766', '6281234567890', 'Bank Syariah Indonesia (BSI)', '7188299102', 'Yayasan Manbaul Hikmah', 'Bank Mandiri', '1560012345678', 'Yayasan Manbaul Hikmah', 'KH. Ahmad Syafei, M.Pd.', '197508122002121003', 'Ustadzah Halimah, S.E.');

-- ========================================================
-- SEED DATA (DATA AWAL LENGKAP & KONSISTEN)
-- ========================================================

-- Classes
INSERT INTO `classes` (`name`, `wali_kelas_name`, `academic_year`) VALUES
('Kelas 1A', 'Ustadzah Fatimah, S.Pd.', '2026/2027'),
('Kelas 1B', 'Ustadzah Halimah, S.Pd.', '2026/2027'),
('Kelas 1C', 'Ustadz Ridwan, S.Pd.I.', '2026/2027'),
('Kelas 2A', 'Ustadzah Aminah, S.Pd.', '2026/2027'),
('Kelas 2B', 'Ustadz Fauzan, S.Pd.I.', '2026/2027'),
('Kelas 2C', 'Ustadzah Wardah, S.Pd.', '2026/2027'),
('Kelas 3A', 'Ustadz Budi Santoso, S.Pd.', '2026/2027'),
('Kelas 3B', 'Ustadzah Siti Aminah, S.Pd.I.', '2026/2027'),
('Kelas 3C', 'Ustadz Ahmad Dahlan, S.Pd.', '2026/2027'),
('Kelas 4A', 'Ustadz Hendra Pratama, S.Pd.', '2026/2027'),
('Kelas 4B', 'Ustadzah Nurul Hidayati, M.Pd.', '2026/2027'),
('Kelas 4C', 'Ustadz M. Ilyas, S.Pd.', '2026/2027'),
('Kelas 5A', 'Ustadz Zulkifli, S.Pd.I.', '2026/2027'),
('Kelas 5B', 'Ustadzah Mariam, S.Pd.', '2026/2027'),
('Kelas 5C', 'Ustadz Syamsul, S.Pd.', '2026/2027'),
('Kelas 6A', 'Ustadz Drs. H. Mansyur', '2026/2027'),
('Kelas 6B', 'Ustadzah Dra. Hj. Maryam', '2026/2027'),
('Kelas 6C', 'Ustadz Abdullah, M.Pd.', '2026/2027'),
('Kelas 7A', 'Ustadz Budi Santoso, S.Pd.', '2026/2027'),
('Kelas 7B', 'Ustadzah Siti Aminah, S.Pd.I.', '2026/2027');

-- Users
INSERT INTO `users` (`username`, `password`, `name`, `role`, `phone`, `assigned_class`, `student_id`) VALUES
('admin', MD5('admin123'), 'Hermawan (Super Admin)', 'admin', '081299999999', NULL, NULL),
('kepsek', MD5('kepsek123'), 'KH. Ahmad Syafei, M.Pd.', 'kepsek', '081234567890', NULL, NULL),
('staff', MD5('staff123'), 'Hj. Maryam, S.E. (Staff TU)', 'staff', '081298765432', NULL, NULL),
('walikelas1a', MD5('guru123'), 'Ustadzah Fatimah, S.Pd.', 'wali_kelas', '081234567894', 'Kelas 1A', NULL),
('walikelas7a', MD5('guru123'), 'Ustadz Budi Santoso, S.Pd.', 'wali_kelas', '081234567891', 'Kelas 7A', NULL),
('walikelas7b', MD5('guru123'), 'Ustadzah Siti Aminah, S.Pd.I.', 'wali_kelas', '081234567892', 'Kelas 7B', NULL),
('guru', MD5('guru123'), 'Ustadz Hendra Pratama, S.Pd.', 'guru', '081234567895', NULL, NULL),
('ortu_ahmad', MD5('ortu123'), 'Bpk. H. Rahmat (Wali Murid)', 'wali_murid', '081234567893', 'Kelas 1A', 1);

-- Students (SDIT Manbaul Hikmah)
INSERT INTO `students` (`id`, `nisn`, `name`, `gender`, `class_name`, `entry_year`, `status`, `address`, `birth_place_date`, `parent_name`, `parent_phone`, `balance`, `qr_code_token`) VALUES
(1, '0081234561', 'Ahmad Fauzi', 'L', 'Kelas 1A', '2024', 'Aktif', 'Jl. KH. Noer Ali No. 12', 'Bekasi, 12 Jan 2018', 'H. Rahmat', '081234567893', 150000.00, 'MH-STD-0081234561'),
(2, '0081234562', 'Fatimah Az-Zahra', 'P', 'Kelas 1A', '2024', 'Aktif', 'Perum Graha Indah Blok B3', 'Bekasi, 23 Mar 2018', 'M. Yusuf', '081234567894', 275000.00, 'MH-STD-0081234562'),
(11, '0081234569', 'Siti Rahma Fauziah', 'P', 'Kelas 1A', '2024', 'Aktif', 'Jl. KH. Noer Ali No. 12', 'Bekasi, 14 Mei 2018', 'H. Rahmat', '081234567893', 220000.00, 'MH-STD-0081234569'),
(3, '0081234563', 'Muhammad Bilal', 'L', 'Kelas 1B', '2024', 'Aktif', 'Jl. Sekolah Karang Satria', 'Bekasi, 05 Feb 2018', 'Drs. Supriyanto', '081234567895', 85000.00, 'MH-STD-0081234563'),
(4, '0081234564', 'Aisyah Humaira', 'P', 'Kelas 2A', '2023', 'Aktif', 'Kp. Gabus Tengah RT 01/02', 'Bekasi, 18 Jul 2017', 'Agus Salim', '081234567896', 320000.00, 'MH-STD-0081234564'),
(5, '0081234565', 'Zaid bin Tsabit', 'L', 'Kelas 3A', '2022', 'Aktif', 'Jl. Raya Tambun No. 45', 'Bekasi, 09 Sep 2016', 'Heri Irawan', '081234567897', 60000.00, 'MH-STD-0081234565'),
(6, '0081234566', 'Khadijah Al-Kubro', 'P', 'Kelas 5A', '2020', 'Aktif', 'Villa Mutiara Gading 1', 'Bekasi, 11 Des 2014', 'Bambang Sudiro', '081234567898', 190000.00, 'MH-STD-0081234566'),
(7, '0081234567', 'Umar Al-Faruq', 'L', 'Kelas 6A', '2019', 'Aktif', 'Kp. Kebalen RT 04/05', 'Bekasi, 02 Agu 2013', 'H. Mansyur', '081234567899', 110000.00, 'MH-STD-0081234567'),
(8, '0081234568', 'Maryam Syafira', 'P', 'Kelas 6A', '2019', 'Aktif', 'Perum Puri Cendana Blok C', 'Bekasi, 19 Nov 2013', 'Suryono', '081234567800', 450000.00, 'MH-STD-0081234568'),
(9, '0081234571', 'Ali Murtadho', 'L', 'Kelas 7A', '2024', 'Aktif', 'Jl. Bahagia No. 8', 'Bekasi, 14 Apr 2012', 'Dedi Mulyadi', '081234567801', 95000.00, 'MH-STD-0081234571'),
(10, '0081234572', 'Zahra Amelia', 'P', 'Kelas 7B', '2024', 'Aktif', 'Perum Bekasi Jaya Indah', 'Bekasi, 28 Okt 2012', 'Joko Widodo', '081234567802', 175000.00, 'MH-STD-0081234572');

-- Attendances (Today - Kelas 1A)
INSERT INTO `attendances` (`student_id`, `class_name`, `attendance_date`, `status`, `scan_time`, `recorded_by`, `notes`) VALUES
(1, 'Kelas 1A', CURDATE(), 'Hadir', '06:55:12', 'Scan QR Kamera', 'Tepat Waktu via QR'),
(2, 'Kelas 1A', CURDATE(), 'Hadir', '07:02:40', 'Scan QR Kamera', 'Tepat Waktu via QR'),
(11, 'Kelas 1A', CURDATE(), 'Hadir', '06:58:20', 'Scan QR Kamera', 'Tepat Waktu via QR');

-- Savings Transactions (Wali Kelas)
INSERT INTO `savings_transactions` (`student_id`, `transaction_type`, `amount`, `balance_after`, `notes`, `recorded_by`, `transaction_date`) VALUES
(1, 'setor', 50000.00, 150000.00, 'Uang saku mingguan', 'Ustadzah Fatimah, S.Pd.', NOW() - INTERVAL 1 DAY),
(2, 'setor', 100000.00, 275000.00, 'Setoran bulanan siswa', 'Ustadzah Fatimah, S.Pd.', NOW() - INTERVAL 2 DAY),
(11, 'setor', 70000.00, 220000.00, 'Tabungan siswi', 'Ustadzah Fatimah, S.Pd.', NOW() - INTERVAL 1 DAY);

-- Announcements
INSERT INTO `announcements` (`title`, `content`, `author_name`, `author_role`, `target_audience`, `category`, `is_urgent`, `created_at`) VALUES
('Pengumuman Pelaksanaan Penilaian Tengah Semester (PTS)', 'Assalamu’alaikum Wr. Wb. Diberitahukan kepada seluruh Bapak/Ibu Dewan Guru bahwa pelaksanaan PTS Ganjil akan dimulai pekan depan. Mohon persiapan naskah soal dan rekap kehadiran siswa disiapkan.', 'KH. Ahmad Syafei, M.Pd.', 'Kepala Sekolah', 'teachers', 'Akademik', 1, NOW() - INTERVAL 2 DAY),
('Himbauan Menabung Siswa & Pembagian Kartu Name Tag QR', 'Assalamu’alaikum Wr. Wb. Kepada Yth. Seluruh Wali Murid SDIT Manbaul Hikmah, sekolah telah meluncurkan Kartu Digital Siswa dengan QR Code untuk presensi mandiri dan program gemar menabung di sekolah. Harap kartu selalu dibawa setiap hari.', 'KH. Ahmad Syafei, M.Pd.', 'Kepala Sekolah', 'parents', 'Kegiatan', 0, NOW() - INTERVAL 1 DAY),
('Libur Peringatan Hari Besar Islam', 'Assalamu’alaikum Wr. Wb. Kegiatan belajar mengajar diliburkan menyambut peringatan Maulid Nabi Muhammad SAW di Masjid Utama Sekolah.', 'KH. Ahmad Syafei, M.Pd.', 'Kepala Sekolah', 'all', 'Libur', 0, NOW());

-- Payment Bills (Tagihan SPP & Keuangan Sekolah)
INSERT INTO `payment_bills` (`student_id`, `student_name`, `class_name`, `category`, `month`, `amount`, `paid_amount`, `status`, `due_date`, `paid_date`, `payment_method`, `invoice_number`) VALUES
(1, 'Ahmad Fauzi', 'Kelas 1A', 'SPP Bulanan', 'Oktober', 250000.00, 0.00, 'Belum Lunas', '10 Okt 2026', NULL, NULL, 'MH-BILL-001'),
(1, 'Ahmad Fauzi', 'Kelas 1A', 'SPP Bulanan', 'September', 250000.00, 250000.00, 'Lunas', '10 Sep 2026', '08 Sep 2026 08:30', 'EduPay Tabungan', 'INV-MH-202609-001'),
(1, 'Ahmad Fauzi', 'Kelas 1A', 'Uang Gedung / Infaq', NULL, 1500000.00, 1500000.00, 'Lunas', '15 Jul 2026', '12 Jul 2026 10:15', 'Transfer Bank', 'INV-MH-202607-005'),
(1, 'Ahmad Fauzi', 'Kelas 1A', 'Buku & Modul', NULL, 350000.00, 350000.00, 'Lunas', '20 Jul 2026', '18 Jul 2026 11:00', 'Tunai di TU', 'INV-MH-202607-012'),
(2, 'Fatimah Az-Zahra', 'Kelas 1A', 'SPP Bulanan', 'Oktober', 250000.00, 0.00, 'Belum Lunas', '10 Okt 2026', NULL, NULL, 'MH-BILL-002'),
(2, 'Fatimah Az-Zahra', 'Kelas 1A', 'SPP Bulanan', 'September', 250000.00, 250000.00, 'Lunas', '10 Sep 2026', '09 Sep 2026 10:00', 'Tunai di TU', 'INV-MH-202609-002'),
(11, 'Siti Rahma Fauziah', 'Kelas 1A', 'SPP Bulanan', 'Oktober', 250000.00, 0.00, 'Belum Lunas', '10 Okt 2026', NULL, NULL, 'MH-BILL-003'),
(11, 'Siti Rahma Fauziah', 'Kelas 1A', 'SPP Bulanan', 'September', 250000.00, 250000.00, 'Lunas', '10 Sep 2026', '10 Sep 2026 07:45', 'EduPay Tabungan', 'INV-MH-202609-003');
SET FOREIGN_KEY_CHECKS = 1;
