<?php
require_once __DIR__ . '/../config/database.php';

$database = new Database();
$db = $database->getConnection();

if (!$db) {
    sendJsonResponse(false, 'Koneksi database MySQL gagal.', null, 500);
}

$action = $_GET['action'] ?? 'summary';

switch ($action) {
    // 1. TRANSACTION (SETOR / TARIK)
    case 'transaction':
        $raw = file_get_contents('php://input');
        $input = json_decode($raw, true) ?: $_POST;

        $studentId = intval($input['student_id'] ?? 0);
        $type = strtolower(trim($input['type'] ?? 'setor')); // 'setor' or 'tarik'
        $amount = floatval($input['amount'] ?? 0);
        $notes = trim($input['notes'] ?? 'Setor Tabungan');
        $recordedBy = trim($input['recorded_by'] ?? 'Wali Kelas');

        if ($studentId <= 0 || $amount <= 0) {
            sendJsonResponse(false, 'Data transaksi tidak valid. Jumlah harus lebih dari 0.', null, 400);
        }

        if (!in_array($type, ['setor', 'tarik'])) {
            sendJsonResponse(false, 'Jenis transaksi harus setor atau tarik', null, 400);
        }

        // Get current balance with lock
        $db->beginTransaction();
        try {
            $stmt = $db->prepare("SELECT id, name, class_name, balance FROM students WHERE id = ? FOR UPDATE");
            $stmt->execute([$studentId]);
            $student = $stmt->fetch();

            if (!$student) {
                $db->rollBack();
                sendJsonResponse(false, 'Siswa tidak ditemukan', null, 404);
            }

            $currentBalance = floatval($student['balance']);
            if ($type === 'tarik' && $currentBalance < $amount) {
                $db->rollBack();
                sendJsonResponse(false, 'Saldo tidak mencukupi. Saldo saat ini: Rp ' . number_format($currentBalance, 0, ',', '.'), null, 400);
            }

            $newBalance = ($type === 'setor') ? ($currentBalance + $amount) : ($currentBalance - $amount);

            // Update student balance
            $update = $db->prepare("UPDATE students SET balance = ? WHERE id = ?");
            $update->execute([$newBalance, $studentId]);

            // Insert transaction record
            $ins = $db->prepare("INSERT INTO savings_transactions (student_id, transaction_type, amount, balance_after, notes, recorded_by) 
                                 VALUES (?, ?, ?, ?, ?, ?)");
            $ins->execute([$studentId, $type, $amount, $newBalance, $notes, $recordedBy]);
            $transId = $db->lastInsertId();

            $db->commit();

            sendJsonResponse(true, 'Transaksi ' . strtoupper($type) . ' sebesar Rp ' . number_format($amount, 0, ',', '.') . ' untuk ' . $student['name'] . ' berhasil!', [
                'transaction_id' => $transId,
                'student_id' => $studentId,
                'student_name' => $student['name'],
                'type' => $type,
                'amount' => $amount,
                'previous_balance' => $currentBalance,
                'new_balance' => $newBalance,
                'date' => date('Y-m-d H:i:s')
            ]);
        } catch (Exception $e) {
            $db->rollBack();
            sendJsonResponse(false, 'Gagal memproses transaksi: ' . $e->getMessage(), null, 500);
        }
        break;

    // 2. STUDENT PASSBOOK / RIWAYAT MUTASI
    case 'passbook':
        $studentId = intval($_GET['student_id'] ?? 0);
        if ($studentId <= 0) {
            sendJsonResponse(false, 'Student ID wajib disertakan', null, 400);
        }

        $stmtStudent = $db->prepare("SELECT id, nisn, name, class_name, balance, parent_phone FROM students WHERE id = ?");
        $stmtStudent->execute([$studentId]);
        $student = $stmtStudent->fetch();

        if (!$student) {
            sendJsonResponse(false, 'Siswa tidak ditemukan', null, 404);
        }

        $stmtTrans = $db->prepare("SELECT * FROM savings_transactions WHERE student_id = ? ORDER BY transaction_date DESC");
        $stmtTrans->execute([$studentId]);
        $history = $stmtTrans->fetchAll();

        sendJsonResponse(true, 'Buku tabungan siswa', [
            'student' => $student,
            'history' => $history
        ]);
        break;

    // 3. CLASS / SCHOOL SAVINGS SUMMARY
    case 'summary':
        $className = $_GET['class'] ?? '';
        $queryStudents = "SELECT SUM(balance) as total_savings, COUNT(*) as total_students, AVG(balance) as avg_savings FROM students";
        $params = [];
        if (!empty($className) && $className !== 'Semua') {
            $queryStudents .= " WHERE class_name = ?";
            $params[] = $className;
        }
        $stmt = $db->prepare($queryStudents);
        $stmt->execute($params);
        $summary = $stmt->fetch();

        // Recent transactions
        $queryRecent = "SELECT t.*, s.name as student_name, s.class_name, s.nisn 
                        FROM savings_transactions t
                        JOIN students s ON t.student_id = s.id";
        if (!empty($className) && $className !== 'Semua') {
            $queryRecent .= " WHERE s.class_name = ?";
        }
        $queryRecent .= " ORDER BY t.transaction_date DESC LIMIT 15";

        $stmtRecent = $db->prepare($queryRecent);
        $stmtRecent->execute($params);
        $recent = $stmtRecent->fetchAll();

        sendJsonResponse(true, 'Ringkasan data tabungan', [
            'total_savings' => floatval($summary['total_savings'] ?? 0),
            'total_students' => intval($summary['total_students'] ?? 0),
            'avg_savings' => floatval($summary['avg_savings'] ?? 0),
            'recent_transactions' => $recent
        ]);
        break;

    default:
        sendJsonResponse(false, 'Aksi tabungan tidak dikenali', null, 400);
}
