<?php
require_once __DIR__ . '/../config/database.php';

$database = new Database();
$db = $database->getConnection();

if (!$db) {
    sendJsonResponse(false, 'Koneksi database MySQL gagal.', null, 500);
}

// Auto-migration: ensure 'Terlambat' is supported in status ENUM
try {
    $db->exec("ALTER TABLE attendances MODIFY COLUMN status ENUM('Hadir', 'Terlambat', 'Sakit', 'Izin', 'Alfa') NOT NULL DEFAULT 'Alfa'");
} catch (Exception $e) {}

$action = $_GET['action'] ?? 'today';
$today = date('Y-m-d');

switch ($action) {
    // 1. SCAN QR CODE PRESENSI (SOP Jam Masuk: Batas 07:00 WIB)
    case 'scan':
        $raw = file_get_contents('php://input');
        $input = json_decode($raw, true) ?: $_POST;

        $qrToken = trim($input['qr_token'] ?? '');
        $recordedBy = trim($input['recorded_by'] ?? 'Scan QR Kamera');

        if (empty($qrToken)) {
            sendJsonResponse(false, 'Data QR Code tidak valid atau kosong', null, 400);
        }

        // Find student by qr_code_token or NISN
        $stmt = $db->prepare("SELECT * FROM students WHERE qr_code_token = ? OR nisn = ? LIMIT 1");
        $stmt->execute([$qrToken, $qrToken]);
        $student = $stmt->fetch();

        if (!$student) {
            sendJsonResponse(false, 'Kartu / QR Code Siswa tidak terdaftar di sistem', null, 404);
        }

        $studentId = $student['id'];
        $className = $student['class_name'];
        $currentTime = date('H:i:s');
        $schoolCutoffTime = '07:00:00';
        $isLate = ($currentTime > $schoolCutoffTime);
        $calculatedStatus = $isLate ? 'Terlambat' : 'Hadir';
        $calculatedNote = $isLate ? ('Terlambat (Pukul ' . substr($currentTime, 0, 5) . ' WIB)') : 'Tepat Waktu via QR';

        // Check if attendance already recorded today
        $check = $db->prepare("SELECT * FROM attendances WHERE student_id = ? AND attendance_date = ?");
        $check->execute([$studentId, $today]);
        $existing = $check->fetch();

        if ($existing) {
            if ($existing['status'] === 'Hadir' || $existing['status'] === 'Terlambat') {
                sendJsonResponse(true, $student['name'] . ' SUDAH tercatat ' . strtoupper($existing['status']) . ' hari ini pada ' . substr($existing['scan_time'], 0, 5) . ' WIB', [
                    'student' => $student,
                    'status' => $existing['status'],
                    'scan_time' => $existing['scan_time'],
                    'already_scanned' => true
                ]);
            } else {
                // Update from Sakit/Izin/Alfa to Hadir/Terlambat because student scanned
                $update = $db->prepare("UPDATE attendances SET status = ?, scan_time = ?, recorded_by = ?, notes = ? WHERE id = ?");
                $update->execute([$calculatedStatus, $currentTime, $recordedBy, $calculatedNote, $existing['id']]);
                sendJsonResponse(true, "✅ Status presensi diperbarui menjadi $calculatedStatus untuk " . $student['name'], [
                    'student' => $student,
                    'status' => $calculatedStatus,
                    'scan_time' => $currentTime,
                    'already_scanned' => false
                ]);
            }
        }

        // Insert new record
        $insert = $db->prepare("INSERT INTO attendances (student_id, class_name, attendance_date, status, scan_time, recorded_by, notes) 
                                VALUES (?, ?, ?, ?, ?, ?, ?)");
        $insert->execute([$studentId, $className, $today, $calculatedStatus, $currentTime, $recordedBy, $calculatedNote]);

        $feedbackMsg = $isLate 
            ? "⚠️ Presensi TERLAMBAT: " . $student['name'] . " (" . substr($currentTime, 0, 5) . " WIB)" 
            : "✅ Absen HADIR Tepat Waktu: " . $student['name'] . " (" . $className . ")";

        sendJsonResponse(true, $feedbackMsg, [
            'student' => $student,
            'status' => $calculatedStatus,
            'scan_time' => $currentTime,
            'already_scanned' => false
        ]);
        break;

    // 2. MANUAL STATUS INPUT (Hadir, Terlambat, Sakit, Izin, Alfa)
    case 'manual':
        $raw = file_get_contents('php://input');
        $input = json_decode($raw, true) ?: $_POST;

        $studentId = intval($input['student_id'] ?? 0);
        $date = !empty($input['date']) ? $input['date'] : $today;
        $status = trim($input['status'] ?? 'Hadir');
        $notes = trim($input['notes'] ?? '');
        $recordedBy = trim($input['recorded_by'] ?? 'Wali Kelas (Manual)');

        if ($studentId <= 0) {
            sendJsonResponse(false, 'Student ID wajib disertakan', null, 400);
        }

        // Get student class
        $stmtStudent = $db->prepare("SELECT * FROM students WHERE id = ?");
        $stmtStudent->execute([$studentId]);
        $student = $stmtStudent->fetch();
        if (!$student) {
            sendJsonResponse(false, 'Siswa tidak ditemukan', null, 404);
        }

        $scanTime = ($status === 'Hadir' || $status === 'Terlambat') ? date('H:i:s') : null;

        // Upsert attendance
        $check = $db->prepare("SELECT id FROM attendances WHERE student_id = ? AND attendance_date = ?");
        $check->execute([$studentId, $date]);
        $existing = $check->fetch();

        if ($existing) {
            $stmt = $db->prepare("UPDATE attendances SET status = ?, scan_time = ?, notes = ?, recorded_by = ? WHERE id = ?");
            $stmt->execute([$status, $scanTime, $notes, $recordedBy, $existing['id']]);
        } else {
            $stmt = $db->prepare("INSERT INTO attendances (student_id, class_name, attendance_date, status, scan_time, notes, recorded_by) 
                                  VALUES (?, ?, ?, ?, ?, ?, ?)");
            $stmt->execute([$studentId, $student['class_name'], $date, $status, $scanTime, $notes, $recordedBy]);
        }

        sendJsonResponse(true, 'Status presensi ' . $student['name'] . ' berhasil diubah menjadi ' . $status, [
            'student_id' => $studentId,
            'status' => $status,
            'notes' => $notes
        ]);
        break;

    // 3. TODAY ATTENDANCE PER CLASS WITH STATS
    case 'today':
        $className = $_GET['class'] ?? 'Semua';
        $targetDate = $_GET['date'] ?? $today;

        // Fetch all students (or in specific class) joined with attendance for target date
        $params = [$targetDate];
        $whereClass = "";
        if (!empty($className) && $className !== 'Semua') {
            $whereClass = "WHERE s.class_name = ?";
            $params[] = $className;
        }

        $query = "SELECT s.id as student_id, s.nisn, s.name, s.gender, s.class_name, s.parent_name, s.parent_phone, s.qr_code_token,
                         a.id as attendance_id, a.status, a.scan_time, a.notes, a.recorded_by
                  FROM students s
                  LEFT JOIN attendances a ON s.id = a.student_id AND a.attendance_date = ?
                  $whereClass
                  ORDER BY s.class_name ASC, s.name ASC";
        $stmt = $db->prepare($query);
        $stmt->execute($params);
        $rows = $stmt->fetchAll();

        // Calculate statistics
        $totalStudents = count($rows);
        $hadir = 0;
        $terlambat = 0;
        $sakit = 0;
        $izin = 0;
        $alfa = 0;
        $belumScan = 0;

        foreach ($rows as &$row) {
            if (empty($row['status'])) {
                $row['status'] = 'Belum Absen';
                $belumScan++;
            } elseif ($row['status'] === 'Hadir') {
                $hadir++;
            } elseif ($row['status'] === 'Terlambat') {
                $terlambat++;
            } elseif ($row['status'] === 'Sakit') {
                $sakit++;
            } elseif ($row['status'] === 'Izin') {
                $izin++;
            } elseif ($row['status'] === 'Alfa') {
                $alfa++;
            }
        }

        sendJsonResponse(true, 'Data presensi hari ini berhasil dimuat', [
            'date' => $targetDate,
            'class_name' => $className,
            'stats' => [
                'total_students' => $totalStudents,
                'hadir' => $hadir,
                'terlambat' => $terlambat,
                'sakit' => $sakit,
                'izin' => $izin,
                'alfa' => $alfa,
                'belum_absen' => $belumScan,
                'percentage_hadir' => $totalStudents > 0 ? round((($hadir + $terlambat) / $totalStudents) * 100, 1) : 0
            ],
            'students' => $rows
        ]);
        break;

    // 4. SOP KUNCI PRESENSI (AUTO-ALFA UNTUK SISWA BELUM ABSEN)
    case 'lock':
    case 'auto_alfa':
        $raw = file_get_contents('php://input');
        $input = json_decode($raw, true) ?: $_POST;

        $targetDate = !empty($input['date']) ? $input['date'] : $today;
        $className = !empty($input['class']) ? $input['class'] : ($_GET['class'] ?? 'Semua');
        $recordedBy = !empty($input['recorded_by']) ? $input['recorded_by'] : 'SOP Kunci Presensi (Wali Kelas)';

        $params = [$targetDate];
        $whereClass = "";
        if (!empty($className) && $className !== 'Semua') {
            $whereClass = "AND s.class_name = ?";
            $params[] = $className;
        }

        // Cari siswa yang belum memiliki record presensi pada tanggal terkait
        $query = "SELECT s.id, s.name, s.class_name 
                  FROM students s
                  WHERE s.id NOT IN (SELECT student_id FROM attendances WHERE attendance_date = ?)
                  $whereClass";
        $stmt = $db->prepare($query);
        $stmt->execute($params);
        $missingStudents = $stmt->fetchAll();

        $countLocked = 0;
        if (!empty($missingStudents)) {
            $ins = $db->prepare("INSERT INTO attendances (student_id, class_name, attendance_date, status, scan_time, recorded_by, notes) 
                                 VALUES (?, ?, ?, 'Alfa', NULL, ?, 'Presensi Ditutup (Auto-Alfa SOP)')");
            foreach ($missingStudents as $ms) {
                $ins->execute([$ms['id'], $ms['class_name'], $targetDate, $recordedBy]);
                $countLocked++;
            }
        }

        sendJsonResponse(true, "✅ SOP Kunci Presensi Berhasil: $countLocked siswa yang belum hadir otomatis tercatat ALFA.", [
            'date' => $targetDate,
            'class_name' => $className,
            'locked_count' => $countLocked
        ]);
        break;

    // 5. CALENDAR SUMMARY (Per month / date range)
    case 'calendar':
        $className = $_GET['class'] ?? 'Kelas 7A';
        $month = $_GET['month'] ?? date('Y-m'); // e.g. 2026-09

        $query = "SELECT attendance_date, 
                         COUNT(CASE WHEN status = 'Hadir' THEN 1 END) as hadir_count,
                         COUNT(CASE WHEN status = 'Sakit' THEN 1 END) as sakit_count,
                         COUNT(CASE WHEN status = 'Izin' THEN 1 END) as izin_count,
                         COUNT(CASE WHEN status = 'Alfa' THEN 1 END) as alfa_count,
                         COUNT(*) as total_recorded
                  FROM attendances
                  WHERE class_name = ? AND attendance_date LIKE ?
                  GROUP BY attendance_date
                  ORDER BY attendance_date ASC";
        $stmt = $db->prepare($query);
        $stmt->execute([$className, "$month%"]);
        $calendarData = $stmt->fetchAll();

        sendJsonResponse(true, 'Data kalender presensi', [
            'month' => $month,
            'class_name' => $className,
            'records' => $calendarData
        ]);
        break;

    // 5. EXPORT CSV
    case 'export':
        $className = $_GET['class'] ?? 'Kelas 7A';
        $startDate = $_GET['start_date'] ?? date('Y-m-01');
        $endDate = $_GET['end_date'] ?? date('Y-m-d');

        $query = "SELECT a.attendance_date, s.nisn, s.name, a.class_name, a.status, a.scan_time, a.notes, a.recorded_by
                  FROM attendances a
                  JOIN students s ON a.student_id = s.id
                  WHERE a.class_name = ? AND a.attendance_date BETWEEN ? AND ?
                  ORDER BY a.attendance_date DESC, s.name ASC";
        $stmt = $db->prepare($query);
        $stmt->execute([$className, $startDate, $endDate]);
        $records = $stmt->fetchAll();

        // Output as CSV directly if requested via browser
        if (isset($_GET['format']) && $_GET['format'] === 'csv') {
            header('Content-Type: text/csv; charset=utf-8');
            header('Content-Disposition: attachment; filename="Rekap_Absensi_' . str_replace(' ', '_', $className) . '_' . date('Ymd') . '.csv"');
            $output = fopen('php://output', 'w');
            fputcsv($output, ['No', 'Tanggal', 'NISN', 'Nama Siswa', 'Kelas', 'Status Kehadiran', 'Jam Scan', 'Catatan', 'Pencatat']);
            $no = 1;
            foreach ($records as $r) {
                fputcsv($output, [
                    $no++,
                    $r['attendance_date'],
                    $r['nisn'],
                    $r['name'],
                    $r['class_name'],
                    $r['status'],
                    $r['scan_time'] ?: '-',
                    $r['notes'] ?: '-',
                    $r['recorded_by']
                ]);
            }
            fclose($output);
            exit();
        }

        sendJsonResponse(true, 'Data export absensi siap', $records);
        break;

    default:
        sendJsonResponse(false, 'Aksi tidak dikenali', null, 400);
}
