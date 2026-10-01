<?php
require_once __DIR__ . '/../config/database.php';

$database = new Database();
$db = $database->getConnection();

if (!$db) {
    sendJsonResponse(false, 'Koneksi database MySQL gagal.', null, 500);
}

// Auto-migration & Seed for School Profile Table
try {
    $db->exec("CREATE TABLE IF NOT EXISTS `school_profile` (
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
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");

    // Check if seeded
    $chk = $db->query("SELECT COUNT(*) FROM school_profile")->fetchColumn();
    if ($chk == 0) {
        $db->exec("INSERT INTO `school_profile` (`id`, `school_name`, `npsn`, `address`, `phone`, `tu_whatsapp`, `bank_name`, `bank_account_number`, `bank_account_holder`, `bank_name_2`, `bank_account_number_2`, `bank_account_holder_2`, `kepsek_name`, `kepsek_nip`, `tu_name`) VALUES
        (1, 'SDIT Manbaul Hikmah', '20260001', 'Jl. KH. Noer Ali No. 45, Karang Satria, Tambun Utara, Bekasi, Jawa Barat 17510', '021-88997766', '6281234567890', 'Bank Syariah Indonesia (BSI)', '7188299102', 'Yayasan Manbaul Hikmah', 'Bank Mandiri', '1560012345678', 'Yayasan Manbaul Hikmah', 'KH. Ahmad Syafei, M.Pd.', '197508122002121003', 'Ustadzah Halimah, S.E.')");
    }
} catch (Exception $e) {}

$action = $_GET['action'] ?? 'get';

switch ($action) {
    case 'get':
        $stmt = $db->query("SELECT * FROM school_profile WHERE id = 1 LIMIT 1");
        $profile = $stmt->fetch();
        if (!$profile) {
            $profile = [
                'id' => 1,
                'school_name' => 'SDIT Manbaul Hikmah',
                'npsn' => '20260001',
                'address' => 'Jl. KH. Noer Ali No. 45, Karang Satria, Tambun Utara, Bekasi, Jawa Barat 17510',
                'phone' => '021-88997766',
                'tu_whatsapp' => '6281234567890',
                'bank_name' => 'Bank Syariah Indonesia (BSI)',
                'bank_account_number' => '7188299102',
                'bank_account_holder' => 'Yayasan Manbaul Hikmah',
                'bank_name_2' => 'Bank Mandiri',
                'bank_account_number_2' => '1560012345678',
                'bank_account_holder_2' => 'Yayasan Manbaul Hikmah',
                'kepsek_name' => 'KH. Ahmad Syafei, M.Pd.',
                'kepsek_nip' => '197508122002121003',
                'tu_name' => 'Ustadzah Halimah, S.E.'
            ];
        }
        sendJsonResponse(true, 'Profil Sekolah Berhasil Dimuat', $profile);
        break;

    case 'update':
        $raw = file_get_contents('php://input');
        $input = json_decode($raw, true) ?: $_POST;

        $userRole = strtolower(trim($input['user_role'] ?? 'staff'));
        if (!in_array($userRole, ['kepsek', 'staff', 'admin', 'super_admin', 'superadmin'])) {
            sendJsonResponse(false, 'Akses Ditolak: Hanya Super Admin, Kepala Sekolah, dan Staff TU yang berhak memperbarui profil sekolah.', null, 403);
        }

        $schoolName = trim($input['school_name'] ?? 'SDIT Manbaul Hikmah');
        $npsn = trim($input['npsn'] ?? '20260001');
        $address = trim($input['address'] ?? '');
        $phone = trim($input['phone'] ?? '');
        $tuWa = preg_replace('/[^0-9]/', '', trim($input['tu_whatsapp'] ?? '6281234567890'));
        $bankName = trim($input['bank_name'] ?? 'Bank Syariah Indonesia (BSI)');
        $bankAccNo = trim($input['bank_account_number'] ?? '');
        $bankHolder = trim($input['bank_account_holder'] ?? 'Yayasan Manbaul Hikmah');
        $bankName2 = trim($input['bank_name_2'] ?? '');
        $bankAccNo2 = trim($input['bank_account_number_2'] ?? '');
        $bankHolder2 = trim($input['bank_account_holder_2'] ?? '');
        $kepsekName = trim($input['kepsek_name'] ?? '');
        $kepsekNip = trim($input['kepsek_nip'] ?? '');
        $tuName = trim($input['tu_name'] ?? '');

        $sql = "UPDATE school_profile SET 
                school_name = ?, npsn = ?, address = ?, phone = ?, tu_whatsapp = ?,
                bank_name = ?, bank_account_number = ?, bank_account_holder = ?,
                bank_name_2 = ?, bank_account_number_2 = ?, bank_account_holder_2 = ?,
                kepsek_name = ?, kepsek_nip = ?, tu_name = ?
                WHERE id = 1";
        $stmt = $db->prepare($sql);
        $stmt->execute([
            $schoolName, $npsn, $address, $phone, $tuWa,
            $bankName, $bankAccNo, $bankHolder,
            $bankName2, $bankAccNo2, $bankHolder2,
            $kepsekName, $kepsekNip, $tuName
        ]);

        sendJsonResponse(true, 'Profil Sekolah & Rekening Resmi Berhasil Diperbarui!');
        break;

    default:
        sendJsonResponse(false, 'Aksi tidak didukung', null, 400);
}
