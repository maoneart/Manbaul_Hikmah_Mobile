-- Database Schema & Seed Data for Manbaul Hikmah Mobile
-- Aplikasi Presensi QR, Tabungan Siswa, dan Pengumuman Sekolah

CREATE DATABASE IF NOT EXISTS `manbaul_hikmah_db` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `manbaul_hikmah_db`;

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
  `role` ENUM('kepsek', 'wali_kelas', 'guru', 'wali_murid') NOT NULL,
  `phone` VARCHAR(20),
  `assigned_class` VARCHAR(50) DEFAULT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 3. Table: Students
DROP TABLE IF EXISTS `students`;
CREATE TABLE `students` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `nisn` VARCHAR(20) UNIQUE NOT NULL,
  `name` VARCHAR(120) NOT NULL,
  `gender` ENUM('L', 'P') NOT NULL DEFAULT 'L',
  `class_name` VARCHAR(50) NOT NULL,
  `parent_name` VARCHAR(100) NOT NULL,
  `parent_phone` VARCHAR(20) NOT NULL,
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
  `status` ENUM('Hadir', 'Sakit', 'Izin', 'Alfa') NOT NULL DEFAULT 'Alfa',
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
  `target_audience` ENUM('all', 'teachers', 'parents') NOT NULL DEFAULT 'all',
  `category` VARCHAR(50) DEFAULT 'Akademik',
  `is_urgent` TINYINT(1) DEFAULT 0,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ========================================================
-- SEED DATA (DATA AWAL LENGKAP & REALISTIS)
-- ========================================================

-- Classes
INSERT INTO `classes` (`name`, `wali_kelas_name`, `academic_year`) VALUES
('Kelas 7A', 'Ustadz Budi Santoso, S.Pd.', '2026/2027'),
('Kelas 7B', 'Ustadzah Siti Aminah, S.Pd.I.', '2026/2027'),
('Kelas 8A', 'Ustadz Hendra Pratama, S.Pd.', '2026/2027'),
('Kelas 9A', 'Ustadzah Nurul Hidayati, M.Pd.', '2026/2027');

-- Users
INSERT INTO `users` (`username`, `password`, `name`, `role`, `phone`, `assigned_class`) VALUES
('kepsek', MD5('kepsek123'), 'KH. Ahmad Syafei, M.Pd.', 'kepsek', '081234567890', NULL),
('walikelas7a', MD5('guru123'), 'Ustadz Budi Santoso, S.Pd.', 'wali_kelas', '081234567891', 'Kelas 7A'),
('walikelas7b', MD5('guru123'), 'Ustadzah Siti Aminah, S.Pd.I.', 'wali_kelas', '081234567892', 'Kelas 7B'),
('ortu_ahmad', MD5('ortu123'), 'Bpk. H. Rahmat (Wali Ahmad)', 'wali_murid', '081234567893', 'Kelas 7A');

-- Students (Kelas 7A)
INSERT INTO `students` (`nisn`, `name`, `gender`, `class_name`, `parent_name`, `parent_phone`, `balance`, `qr_code_token`) VALUES
('0081234561', 'Ahmad Fauzi', 'L', 'Kelas 7A', 'H. Rahmat', '081234567893', 150000.00, 'MH-STD-0081234561'),
('0081234562', 'Fatimah Az-Zahra', 'P', 'Kelas 7A', 'M. Yusuf', '081234567894', 275000.00, 'MH-STD-0081234562'),
('0081234563', 'Muhammad Bilal', 'L', 'Kelas 7A', 'Drs. Supriyanto', '081234567895', 85000.00, 'MH-STD-0081234563'),
('0081234564', 'Aisyah Humaira', 'P', 'Kelas 7A', 'Agus Salim', '081234567896', 320000.00, 'MH-STD-0081234564'),
('0081234565', 'Zaid bin Tsabit', 'L', 'Kelas 7A', 'Heri Irawan', '081234567897', 60000.00, 'MH-STD-0081234565'),
('0081234566', 'Khadijah Al-Kubro', 'P', 'Kelas 7A', 'Bambang Sudiro', '081234567898', 190000.00, 'MH-STD-0081234566'),
('0081234567', 'Umar Al-Faruq', 'L', 'Kelas 7A', 'H. Mansyur', '081234567899', 110000.00, 'MH-STD-0081234567'),
('0081234568', 'Maryam Syafira', 'P', 'Kelas 7A', 'Suryono', '081234567800', 450000.00, 'MH-STD-0081234568');

-- Students (Kelas 7B)
INSERT INTO `students` (`nisn`, `name`, `gender`, `class_name`, `parent_name`, `parent_phone`, `balance`, `qr_code_token`) VALUES
('0081234571', 'Ali Murtadho', 'L', 'Kelas 7B', 'Dedi Mulyadi', '081234567801', 95000.00, 'MH-STD-0081234571'),
('0081234572', 'Zahra Amelia', 'P', 'Kelas 7B', 'Joko Widodo', '081234567802', 175000.00, 'MH-STD-0081234572');

-- Announcements from Kepsek
INSERT INTO `announcements` (`title`, `content`, `author_name`, `author_role`, `target_audience`, `category`, `is_urgent`, `created_at`) VALUES
('Pengumuman Pelaksanaan Penilaian Tengah Semester (PTS)', 'Assalamu’alaikum Wr. Wb. Diberitahukan kepada seluruh Bapak/Ibu Wali Kelas dan Dewan Guru bahwa pelaksanaan PTS Ganjil akan dimulai pekan depan. Mohon persiapan naskah soal dan rekap kehadiran siswa.', 'KH. Ahmad Syafei, M.Pd.', 'Kepala Sekolah', 'teachers', 'Akademik', 1, NOW() - INTERVAL 2 DAY),
('Himbauan Menabung Siswa & Pembagian Kartu Name Tag QR', 'Assalamu’alaikum Wr. Wb. Kepada Yth. Seluruh Wali Murid Pesantren Manbaul Hikmah, sekolah telah meluncurkan Kartu Digital Siswa dengan QR Code untuk absensi dan program gemar menabung di sekolah. Harap kartu selalu dibawa setiap hari.', 'KH. Ahmad Syafei, M.Pd.', 'Kepala Sekolah', 'parents', 'Kegiatan', 0, NOW() - INTERVAL 1 DAY),
('Libur Peringatan Maulid Nabi Muhammad SAW', 'Assalamu’alaikum Wr. Wb. Kegiatan belajar mengajar diliburkan dalam rangka memperingati Maulid Nabi Muhammad SAW. Santri dan siswa diharapkan mengikuti pengajian di musholla masing-masing.', 'KH. Ahmad Syafei, M.Pd.', 'Kepala Sekolah', 'all', 'Libur', 0, NOW());

-- Initial Attendance Sample for Today (Kelas 7A)
INSERT INTO `attendances` (`student_id`, `class_name`, `attendance_date`, `status`, `scan_time`, `recorded_by`, `notes`) VALUES
(1, 'Kelas 7A', CURDATE(), 'Hadir', '06:55:12', 'Scan QR Kamera', 'Tepat Waktu'),
(2, 'Kelas 7A', CURDATE(), 'Hadir', '07:02:40', 'Scan QR Kamera', 'Tepat Waktu'),
(3, 'Kelas 7A', CURDATE(), 'Sakit', NULL, 'Ustadz Budi Santoso', 'Surat dokter izin sakit flu'),
(4, 'Kelas 7A', CURDATE(), 'Hadir', '07:05:18', 'Scan QR Kamera', 'Tepat Waktu'),
(5, 'Kelas 7A', CURDATE(), 'Izin', NULL, 'Ustadz Budi Santoso', 'Izin acara keluarga'),
(6, 'Kelas 7A', CURDATE(), 'Hadir', '07:11:30', 'Scan QR Kamera', 'Tepat Waktu'),
(7, 'Kelas 7A', CURDATE(), 'Alfa', NULL, 'Sistem Presensi', 'Belum scan name tag'),
(8, 'Kelas 7A', CURDATE(), 'Hadir', '07:14:02', 'Scan QR Kamera', 'Tepat Waktu');

-- Initial Savings Transactions Sample
INSERT INTO `savings_transactions` (`student_id`, `transaction_type`, `amount`, `balance_after`, `notes`, `recorded_by`, `transaction_date`) VALUES
(1, 'setor', 50000.00, 150000.00, 'Setor rutin uang saku mingguan', 'Ustadz Budi Santoso', NOW() - INTERVAL 2 DAY),
(2, 'setor', 100000.00, 275000.00, 'Setoran bulanan santri', 'Ustadz Budi Santoso', NOW() - INTERVAL 1 DAY),
(3, 'tarik', 20000.00, 85000.00, 'Beli modul fiqih & kitab', 'Ustadz Budi Santoso', NOW() - INTERVAL 3 DAY),
(4, 'setor', 50000.00, 320000.00, 'Tabungan santriwati', 'Ustadz Budi Santoso', NOW());
