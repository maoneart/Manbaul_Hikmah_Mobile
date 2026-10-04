<?php
require_once __DIR__ . '/../config/database.php';

$database = new Database();
$db = $database->getConnection();

if (!$db) {
    sendJsonResponse(false, 'Koneksi database MySQL gagal. Pastikan Laragon MySQL aktif.', null, 500);
}

$method = $_SERVER['REQUEST_METHOD'];

switch ($method) {
    case 'GET':
        // Find single student by QR Code Token
        if (isset($_GET['qr'])) {
            $qr = trim($_GET['qr']);
            $stmt = $db->prepare("SELECT * FROM students WHERE qr_code_token = ? LIMIT 1");
            $stmt->execute([$qr]);
            $student = $stmt->fetch();
            if ($student) {
                sendJsonResponse(true, 'Data siswa ditemukan via QR', $student);
            } else {
                sendJsonResponse(false, 'QR Code tidak terdaftar dalam sistem', null, 404);
            }
        }

        // Find single student by ID
        if (isset($_GET['id'])) {
            $id = intval($_GET['id']);
            $stmt = $db->prepare("SELECT * FROM students WHERE id = ? LIMIT 1");
            $stmt->execute([$id]);
            $student = $stmt->fetch();
            if ($student) {
                sendJsonResponse(true, 'Data siswa ditemukan', $student);
            } else {
                sendJsonResponse(false, 'Siswa tidak ditemukan', null, 404);
            }
        }

        // List students (with optional class and search filters)
        $className = $_GET['class'] ?? '';
        $search = $_GET['search'] ?? '';

        $query = "SELECT * FROM students WHERE 1=1";
        $params = [];

        if (!empty($className) && $className !== 'Semua') {
            $query .= " AND class_name = ?";
            $params[] = $className;
        }

        if (!empty($search)) {
            $query .= " AND (name LIKE ? OR nisn LIKE ?)";
            $params[] = "%$search%";
            $params[] = "%$search%";
        }

        $query .= " ORDER BY class_name ASC, name ASC";

        $stmt = $db->prepare($query);
        $stmt->execute($params);
        $students = $stmt->fetchAll();

        sendJsonResponse(true, 'Daftar siswa berhasil dimuat', $students);
        break;

    case 'POST':
        $raw = file_get_contents('php://input');
        $input = json_decode($raw, true) ?: $_POST;

        $nisn = trim($input['nisn'] ?? '');
        $name = trim($input['name'] ?? '');
        $gender = trim($input['gender'] ?? 'L');
        $className = trim($input['class_name'] ?? 'Kelas 7A');
        $parentName = trim($input['parent_name'] ?? '');
        $parentPhone = trim($input['parent_phone'] ?? '');
        $balance = floatval($input['balance'] ?? 0);

        if (empty($nisn) || empty($name) || empty($className)) {
            sendJsonResponse(false, 'NISN, Nama Siswa, dan Kelas wajib diisi', null, 400);
        }

        // Check if NISN exists
        $check = $db->prepare("SELECT id FROM students WHERE nisn = ?");
        $check->execute([$nisn]);
        if ($check->rowCount() > 0) {
            sendJsonResponse(false, 'NISN ' . $nisn . ' sudah terdaftar', null, 400);
        }

        $address = trim($input['address'] ?? '');
        $entryYear = trim($input['entry_year'] ?? date('Y'));
        $status = trim($input['status'] ?? 'Aktif');
        $birthPlaceDate = trim($input['birth_place_date'] ?? '');
        $studentNik = trim($input['student_nik'] ?? '');
        $parentNik = trim($input['parent_nik'] ?? '');
        $admissionDate = trim($input['admission_date'] ?? '');
        $graduationDate = trim($input['graduation_date'] ?? '');

        // Auto-upgrade columns if missing
        try {
            $db->exec("ALTER TABLE students ADD COLUMN IF NOT EXISTS address VARCHAR(255) DEFAULT ''");
            $db->exec("ALTER TABLE students ADD COLUMN IF NOT EXISTS entry_year VARCHAR(10) DEFAULT '2024'");
            $db->exec("ALTER TABLE students ADD COLUMN IF NOT EXISTS status VARCHAR(20) DEFAULT 'Aktif'");
            $db->exec("ALTER TABLE students ADD COLUMN IF NOT EXISTS birth_place_date VARCHAR(100) DEFAULT ''");
            $db->exec("ALTER TABLE students ADD COLUMN IF NOT EXISTS student_nik VARCHAR(20) DEFAULT ''");
            $db->exec("ALTER TABLE students ADD COLUMN IF NOT EXISTS parent_nik VARCHAR(20) DEFAULT ''");
            $db->exec("ALTER TABLE students ADD COLUMN IF NOT EXISTS admission_date VARCHAR(30) DEFAULT ''");
            $db->exec("ALTER TABLE students ADD COLUMN IF NOT EXISTS graduation_date VARCHAR(30) DEFAULT ''");
        } catch (Exception $e) {}

        // Generate unique QR Code token
        $qrToken = 'MH-STD-' . $nisn;

        try {
            $stmt = $db->prepare("INSERT INTO students (nisn, student_nik, name, gender, class_name, parent_name, parent_phone, parent_nik, balance, qr_code_token, address, entry_year, admission_date, status, graduation_date, birth_place_date) 
                                  VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
            $saved = $stmt->execute([$nisn, $studentNik, $name, $gender, $className, $parentName, $parentPhone, $parentNik, $balance, $qrToken, $address, $entryYear, $admissionDate, $status, $graduationDate, $birthPlaceDate]);
        } catch (Exception $e) {
            $stmt = $db->prepare("INSERT INTO students (nisn, name, gender, class_name, parent_name, parent_phone, balance, qr_code_token, address, entry_year, status, birth_place_date) 
                                  VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
            $saved = $stmt->execute([$nisn, $name, $gender, $className, $parentName, $parentPhone, $balance, $qrToken, $address, $entryYear, $status, $birthPlaceDate]);
        }

        if ($saved) {
            $newId = $db->lastInsertId();

            // TWO-WAY SYNC KE USERS: Tautkan dan sinkronkan akun wali murid jika ada di database
            if (!empty($parentNik) || !empty($parentPhone)) {
                try {
                    $stmtUserSync = $db->prepare("UPDATE users SET student_id = COALESCE(student_id, ?), name = CASE WHEN name = '' THEN ? ELSE name END, phone = CASE WHEN phone = '' THEN ? ELSE phone END, nik = CASE WHEN nik = '' THEN ? ELSE nik END 
                                                  WHERE role = 'wali_murid' AND ((nik != '' AND nik = ?) OR (phone != '' AND phone = ?))");
                    $stmtUserSync->execute([$newId, $parentName, $parentPhone, $parentNik, $parentNik, $parentPhone]);
                } catch (Exception $e) {}
            }

            $getNew = $db->prepare("SELECT * FROM students WHERE id = ?");
            $getNew->execute([$newId]);
            sendJsonResponse(true, 'Siswa berhasil ditambahkan secara real-time', $getNew->fetch(), 201);
        } else {
            sendJsonResponse(false, 'Gagal menyimpan data siswa', null, 500);
        }
        break;

    case 'PUT':
        $raw = file_get_contents('php://input');
        $input = json_decode($raw, true);

        $id = intval($input['id'] ?? 0);
        if ($id <= 0) {
            sendJsonResponse(false, 'ID siswa tidak valid', null, 400);
        }

        $address = trim($input['address'] ?? '');
        $entryYear = trim($input['entry_year'] ?? date('Y'));
        $status = trim($input['status'] ?? 'Aktif');
        $birthPlaceDate = trim($input['birth_place_date'] ?? '');
        $studentNik = trim($input['student_nik'] ?? '');
        $parentNik = trim($input['parent_nik'] ?? '');
        $admissionDate = trim($input['admission_date'] ?? '');
        $graduationDate = trim($input['graduation_date'] ?? '');

        try {
            $stmt = $db->prepare("UPDATE students SET name = ?, gender = ?, class_name = ?, parent_name = ?, parent_phone = ?, parent_nik = ?, student_nik = ?, address = ?, entry_year = ?, admission_date = ?, status = ?, graduation_date = ?, birth_place_date = ? WHERE id = ?");
            $stmt->execute([
                $input['name'],
                $input['gender'] ?? 'L',
                $input['class_name'],
                $input['parent_name'],
                $input['parent_phone'],
                $parentNik,
                $studentNik,
                $address,
                $entryYear,
                $admissionDate,
                $status,
                $graduationDate,
                $birthPlaceDate,
                $id
            ]);
        } catch (Exception $e) {
            $stmt = $db->prepare("UPDATE students SET name = ?, gender = ?, class_name = ?, parent_name = ?, parent_phone = ?, address = ?, entry_year = ?, status = ?, birth_place_date = ? WHERE id = ?");
            $stmt->execute([
                $input['name'],
                $input['gender'] ?? 'L',
                $input['class_name'],
                $input['parent_name'],
                $input['parent_phone'],
                $address,
                $entryYear,
                $status,
                $birthPlaceDate,
                $id
            ]);
        }

        // TWO-WAY SYNC KE USERS: Update data akun wali murid jika data orang tua siswa diedit oleh sekolah
        if (!empty($parentNik) || !empty($input['parent_phone']) || $id > 0) {
            try {
                $pPhone = $input['parent_phone'] ?? '';
                $pName = $input['parent_name'] ?? '';
                $stmtUserSync = $db->prepare("UPDATE users SET name = ?, phone = ?, nik = ?, address = CASE WHEN ? != '' THEN ? ELSE address END 
                                              WHERE role = 'wali_murid' AND ((nik != '' AND nik = ?) OR (student_id = ?) OR (phone != '' AND phone = ?))");
                $stmtUserSync->execute([$pName, $pPhone, $parentNik, $address, $address, $parentNik, $id, $pPhone]);
            } catch (Exception $e) {}
        }

        sendJsonResponse(true, 'Data siswa berhasil diperbarui secara real-time', null);
        break;

    case 'DELETE':
        $id = intval($_GET['id'] ?? 0);
        if ($id <= 0) {
            sendJsonResponse(false, 'ID siswa tidak valid', null, 400);
        }

        $stmt = $db->prepare("DELETE FROM students WHERE id = ?");
        $stmt->execute([$id]);
        sendJsonResponse(true, 'Siswa berhasil dihapus', null);
        break;

    default:
        sendJsonResponse(false, 'Method tidak didukung', null, 405);
}
