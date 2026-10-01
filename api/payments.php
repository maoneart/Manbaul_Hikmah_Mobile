<?php
require_once __DIR__ . '/../config/database.php';

$database = new Database();
$db = $database->getConnection();

if (!$db) {
    sendJsonResponse(false, 'Koneksi database MySQL gagal.', null, 500);
}

// Auto-create payment_bills table if missing
try {
    $db->exec("CREATE TABLE IF NOT EXISTS `payment_bills` (
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
        `verified_by` VARCHAR(100) DEFAULT NULL,
        `invoice_number` VARCHAR(50) DEFAULT '',
        `notes` VARCHAR(255) DEFAULT '',
        `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");

    // Migration for existing tables
    $db->exec("ALTER TABLE `payment_bills` MODIFY COLUMN `status` ENUM('Belum Lunas', 'Menunggu Verifikasi', 'Lunas') NOT NULL DEFAULT 'Belum Lunas'");
    $db->exec("ALTER TABLE `payment_bills` ADD COLUMN IF NOT EXISTS `verified_by` VARCHAR(100) DEFAULT NULL AFTER `payment_method`");
} catch (Exception $e) {}

$action = $_GET['action'] ?? 'bills';

switch ($action) {
    case 'bills':
        $className = $_GET['class'] ?? '';
        $studentId = intval($_GET['student_id'] ?? 0);
        $statusFilter = $_GET['status'] ?? '';

        $query = "SELECT * FROM payment_bills WHERE 1=1";
        $params = [];

        if ($studentId > 0) {
            $query .= " AND student_id = ?";
            $params[] = $studentId;
        } elseif (!empty($className) && $className !== 'Semua') {
            $query .= " AND class_name = ?";
            $params[] = $className;
        }

        if (!empty($statusFilter) && $statusFilter !== 'Semua') {
            $query .= " AND status = ?";
            $params[] = $statusFilter;
        }

        $query .= " ORDER BY CASE status WHEN 'Menunggu Verifikasi' THEN 1 WHEN 'Belum Lunas' THEN 2 WHEN 'Lunas' THEN 3 END ASC, id DESC";
        $stmt = $db->prepare($query);
        $stmt->execute($params);
        $bills = $stmt->fetchAll();

        sendJsonResponse(true, 'Daftar tagihan pembayaran sekolah', $bills);
        break;

    case 'request_verification':
        // Wali murid mengkonfirmasi transfer & mengirim bukti via WhatsApp ke TU
        $raw = file_get_contents('php://input');
        $input = json_decode($raw, true) ?: $_POST;

        $billId = intval($input['bill_id'] ?? 0);
        $method = trim($input['payment_method'] ?? 'Transfer Bank');
        $notes = trim($input['notes'] ?? 'Bukti transfer dikirim via WhatsApp ke TU');

        if ($billId <= 0) {
            sendJsonResponse(false, 'ID tagihan wajib disertakan', null, 400);
        }

        $stmt = $db->prepare("SELECT * FROM payment_bills WHERE id = ?");
        $stmt->execute([$billId]);
        $bill = $stmt->fetch();

        if (!$bill) {
            sendJsonResponse(false, 'Tagihan tidak ditemukan', null, 404);
        }

        if ($bill['status'] === 'Lunas') {
            sendJsonResponse(false, 'Tagihan ini sudah lunas sebelumnya', null, 400);
        }

        // Update status to Menunggu Verifikasi
        $stmtUpdate = $db->prepare("UPDATE payment_bills SET status = 'Menunggu Verifikasi', payment_method = ?, notes = ? WHERE id = ?");
        $stmtUpdate->execute([$method, $notes, $billId]);

        // Get school profile for TU WhatsApp
        $schoolProfile = null;
        try {
            $spStmt = $db->query("SELECT school_name, tu_whatsapp, tu_name, bank_name, bank_account_number, bank_account_holder FROM school_profile WHERE id = 1 LIMIT 1");
            $schoolProfile = $spStmt->fetch();
        } catch (Exception $e) {}

        $tuWa = $schoolProfile['tu_whatsapp'] ?? '6281234567890';
        $tuWaClean = preg_replace('/[^0-9]/', '', $tuWa);
        if (str_starts_with($tuWaClean, '0')) {
            $tuWaClean = '62' . substr($tuWaClean, 1);
        }

        $formattedAmount = number_format($bill['amount'], 0, ',', '.');
        $waMessage = "Assalamu'alaikum Admin TU " . ($schoolProfile['school_name'] ?? 'SDIT Manbaul Hikmah') . ",\n\n"
            . "Saya wali murid dari ananda:\n"
            . "• Nama: *" . $bill['student_name'] . "*\n"
            . "• Kelas: " . $bill['class_name'] . "\n"
            . "• Pembayaran: *" . $bill['category'] . ($bill['month'] ? ' (Bulan ' . $bill['month'] . ')' : '') . "*\n"
            . "• Nominal: *Rp " . $formattedAmount . "*\n\n"
            . "Ingin mengkonfirmasi telah melakukan transfer via " . $method . " ke rekening resmi sekolah. Berikut saya lampirkan foto struk/bukti transfernya. Mohon bantuannya untuk diverifikasi status lunasnya. Terima kasih. Jazakumullah khairan.";

        $waUrl = "https://wa.me/" . $tuWaClean . "?text=" . rawurlencode($waMessage);

        sendJsonResponse(true, 'Permintaan verifikasi berhasil diajukan! Silakan lampirkan bukti ke WhatsApp TU.', [
            'bill_id' => $billId,
            'status' => 'Menunggu Verifikasi',
            'tu_whatsapp' => $tuWaClean,
            'wa_message' => $waMessage,
            'wa_url' => $waUrl
        ]);
        break;

    case 'pay':
        $raw = file_get_contents('php://input');
        $input = json_decode($raw, true) ?: $_POST;

        $billId = intval($input['bill_id'] ?? 0);
        $method = trim($input['payment_method'] ?? 'Tunai di TU');
        $verifiedBy = trim($input['verified_by'] ?? 'Staff Tata Usaha');
        $paidDate = date('d M Y H:i');
        $invoice = 'INV-MH-' . date('Ymd') . '-' . str_pad($billId, 4, '0', STR_PAD_LEFT);

        if ($billId <= 0) {
            sendJsonResponse(false, 'ID tagihan wajib disertakan', null, 400);
        }

        $stmt = $db->prepare("SELECT * FROM payment_bills WHERE id = ?");
        $stmt->execute([$billId]);
        $bill = $stmt->fetch();

        if (!$bill) {
            sendJsonResponse(false, 'Tagihan tidak ditemukan', null, 404);
        }

        // Deduct from savings if EduPay
        if ($method === 'EduPay Tabungan') {
            $stmtStudent = $db->prepare("SELECT balance FROM students WHERE id = ?");
            $stmtStudent->execute([$bill['student_id']]);
            $student = $stmtStudent->fetch();
            if ($student && $student['balance'] < $bill['amount']) {
                sendJsonResponse(false, 'Saldo tabungan tidak mencukupi (Saldo: Rp ' . number_format($student['balance'], 0, ',', '.') . ')', null, 400);
            }

            // Deduct balance
            $newBalance = $student['balance'] - $bill['amount'];
            $db->prepare("UPDATE students SET balance = ? WHERE id = ?")->execute([$newBalance, $bill['student_id']]);

            // Record savings transaction
            $db->prepare("INSERT INTO savings_transactions (student_id, transaction_type, amount, balance_after, notes, recorded_by) 
                          VALUES (?, 'tarik', ?, ?, ?, 'Sistem Pembayaran SPP')")
               ->execute([$bill['student_id'], $bill['amount'], $newBalance, 'Pembayaran ' . $bill['category'] . ' ' . ($bill['month'] ?? '')]);
            
            $verifiedBy = 'Sistem EduPay Tabungan';
        }

        // Update bill to Lunas with verified_by
        $update = $db->prepare("UPDATE payment_bills SET status = 'Lunas', paid_amount = amount, paid_date = ?, payment_method = ?, verified_by = ?, invoice_number = ? WHERE id = ?");
        $update->execute([$paidDate, $method, $verifiedBy, $invoice, $billId]);

        sendJsonResponse(true, '✅ Pembayaran ' . $bill['category'] . ' berhasil diverifikasi & dicatat Lunas!', [
            'bill_id' => $billId,
            'invoice_number' => $invoice,
            'paid_date' => $paidDate,
            'payment_method' => $method,
            'verified_by' => $verifiedBy
        ]);
        break;

    case 'create_bill':
        $raw = file_get_contents('php://input');
        $input = json_decode($raw, true) ?: $_POST;

        $studentId = intval($input['student_id'] ?? 0);
        $category = trim($input['category'] ?? 'SPP Bulanan');
        $month = trim($input['month'] ?? '');
        $amount = floatval($input['amount'] ?? 250000);
        $dueDate = trim($input['due_date'] ?? '10 ' . date('M Y'));

        $stmtStudent = $db->prepare("SELECT name, class_name FROM students WHERE id = ?");
        $stmtStudent->execute([$studentId]);
        $student = $stmtStudent->fetch();

        if (!$student) {
            sendJsonResponse(false, 'Siswa tidak ditemukan', null, 404);
        }

        $invoice = 'MH-BILL-' . rand(1000, 9999);
        $stmt = $db->prepare("INSERT INTO payment_bills (student_id, student_name, class_name, category, month, amount, status, due_date, invoice_number) 
                              VALUES (?, ?, ?, ?, ?, ?, 'Belum Lunas', ?, ?)");
        $stmt->execute([$studentId, $student['name'], $student['class_name'], $category, $month, $amount, $dueDate, $invoice]);

        sendJsonResponse(true, 'Tagihan baru berhasil dibuat', ['id' => $db->lastInsertId()], 201);
        break;

    case 'generate_class_bills':
        $raw = file_get_contents('php://input');
        $input = json_decode($raw, true) ?: $_POST;

        $className = trim($input['class_name'] ?? '');
        $month = trim($input['month'] ?? '');
        $amount = floatval($input['amount'] ?? 250000);
        $dueDate = trim($input['due_date'] ?? '10 ' . date('M Y'));

        if (empty($className)) {
            sendJsonResponse(false, 'Nama kelas wajib diisi', null, 400);
        }

        $stmtStudents = $db->prepare("SELECT id, name, class_name FROM students WHERE class_name = ?");
        $stmtStudents->execute([$className]);
        $students = $stmtStudents->fetchAll();

        $count = 0;
        foreach ($students as $st) {
            $check = $db->prepare("SELECT id FROM payment_bills WHERE student_id = ? AND category = 'SPP Bulanan' AND month = ?");
            $check->execute([$st['id'], $month]);
            if (!$check->fetch()) {
                $invoice = 'MH-SPP-' . date('Ym') . '-' . $st['id'] . '-' . rand(100, 999);
                $insert = $db->prepare("INSERT INTO payment_bills (student_id, student_name, class_name, category, month, amount, status, due_date, invoice_number) 
                                        VALUES (?, ?, ?, 'SPP Bulanan', ?, ?, 'Belum Lunas', ?, ?)");
                $insert->execute([$st['id'], $st['name'], $st['class_name'], $month, $amount, $dueDate, $invoice]);
                $count++;
            }
        }

        sendJsonResponse(true, "Berhasil generate $count tagihan SPP", ['generated_count' => $count]);
        break;

    default:
        sendJsonResponse(false, 'Aksi tidak didukung', null, 400);
}
