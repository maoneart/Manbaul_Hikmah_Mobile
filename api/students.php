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

        // Generate unique QR Code token
        $qrToken = 'MH-STD-' . $nisn;

        $stmt = $db->prepare("INSERT INTO students (nisn, name, gender, class_name, parent_name, parent_phone, balance, qr_code_token) 
                              VALUES (?, ?, ?, ?, ?, ?, ?, ?)");
        $saved = $stmt->execute([$nisn, $name, $gender, $className, $parentName, $parentPhone, $balance, $qrToken]);

        if ($saved) {
            $newId = $db->lastInsertId();
            $getNew = $db->prepare("SELECT * FROM students WHERE id = ?");
            $getNew->execute([$newId]);
            sendJsonResponse(true, 'Siswa berhasil ditambahkan', $getNew->fetch(), 201);
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

        $stmt = $db->prepare("UPDATE students SET name = ?, gender = ?, class_name = ?, parent_name = ?, parent_phone = ? WHERE id = ?");
        $stmt->execute([
            $input['name'],
            $input['gender'] ?? 'L',
            $input['class_name'],
            $input['parent_name'],
            $input['parent_phone'],
            $id
        ]);

        sendJsonResponse(true, 'Data siswa berhasil diperbarui', null);
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
