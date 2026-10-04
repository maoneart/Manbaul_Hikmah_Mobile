<?php
require_once __DIR__ . '/../config/database.php';

$database = new Database();
$db = $database->getConnection();

if (!$db) {
    sendJsonResponse(false, 'Koneksi database MySQL gagal.', null, 500);
}

// Ensure schema is up to date
try {
    $db->exec("ALTER TABLE users ADD COLUMN IF NOT EXISTS email VARCHAR(100) DEFAULT '' AFTER username");
    $db->exec("ALTER TABLE users ADD COLUMN IF NOT EXISTS address TEXT AFTER phone");
    $db->exec("ALTER TABLE users ADD COLUMN IF NOT EXISTS nik VARCHAR(20) DEFAULT '' AFTER address");
} catch (Exception $e) {
    // Ignore if already present
}

$action = $_GET['action'] ?? 'users';

switch ($action) {
    case 'users':
        $stmt = $db->query("SELECT id, username, email, name, role, phone, address, nik, assigned_class, student_id FROM users ORDER BY role ASC");
        $users = $stmt->fetchAll();
        sendJsonResponse(true, 'Daftar pengguna', $users);
        break;

    case 'login':
        $raw = file_get_contents('php://input');
        $input = json_decode($raw, true) ?: $_POST;

        $identifier = trim($input['email'] ?? $input['username'] ?? $input['login_id'] ?? '');
        $password = trim($input['password'] ?? '');

        if (empty($identifier) || empty($password)) {
            sendJsonResponse(false, 'Email/Username dan kata sandi wajib diisi', null, 400);
        }

        $stmt = $db->prepare("SELECT * FROM users WHERE email = ? OR username = ? LIMIT 1");
        $stmt->execute([$identifier, $identifier]);
        $user = $stmt->fetch();

        if ($user) {
            $isPasswordValid = (
                md5($password) === $user['password'] ||
                password_verify($password, $user['password'])
            );

            if ($isPasswordValid) {
                unset($user['password']);
                sendJsonResponse(true, 'Login berhasil', $user);
            }
        }

        sendJsonResponse(false, 'Email atau kata sandi tidak sesuai', null, 401);
        break;

    case 'change_password':
        $raw = file_get_contents('php://input');
        $input = json_decode($raw, true) ?: $_POST;

        $userId = intval($input['user_id'] ?? 0);
        $oldPassword = trim($input['old_password'] ?? '');
        $newPassword = trim($input['new_password'] ?? '');

        if (!$userId || empty($newPassword)) {
            sendJsonResponse(false, 'Data user dan password baru wajib disertakan', null, 400);
        }

        $stmt = $db->prepare("SELECT password FROM users WHERE id = ? LIMIT 1");
        $stmt->execute([$userId]);
        $current = $stmt->fetch();

        if (!$current) {
            sendJsonResponse(false, 'Pengguna tidak ditemukan', null, 404);
        }

        // Validate old password
        $isOldValid = (
            md5($oldPassword) === $current['password'] ||
            password_verify($oldPassword, $current['password'])
        );

        if (!$isOldValid) {
            sendJsonResponse(false, 'Kata sandi lama tidak tepat', null, 400);
        }

        $stmt = $db->prepare("UPDATE users SET password = ? WHERE id = ?");
        $stmt->execute([md5($newPassword), $userId]);

        sendJsonResponse(true, 'Kata sandi berhasil diperbarui');
        break;

    case 'reset_password':
        $raw = file_get_contents('php://input');
        $input = json_decode($raw, true) ?: $_POST;

        $userId = intval($input['user_id'] ?? 0);

        if (!$userId) {
            sendJsonResponse(false, 'User ID wajib diisi', null, 400);
        }

        $stmt = $db->prepare("UPDATE users SET password = ? WHERE id = ?");
        $stmt->execute([md5('manbaul111'), $userId]);

        sendJsonResponse(true, 'Kata sandi berhasil di-reset ke default: manbaul111');
        break;

    case 'update_profile':
        $raw = file_get_contents('php://input');
        $input = json_decode($raw, true) ?: $_POST;

        $userId = intval($input['user_id'] ?? 0);
        $name = trim($input['name'] ?? '');
        $phone = trim($input['phone'] ?? '');
        $address = trim($input['address'] ?? '');
        $email = trim($input['email'] ?? '');
        $nik = trim($input['nik'] ?? '');

        if (!$userId) {
            sendJsonResponse(false, 'User ID wajib diisi', null, 400);
        }

        // Get current user details before update
        $stmtCurr = $db->prepare("SELECT role, student_id, nik, phone, name FROM users WHERE id = ? LIMIT 1");
        $stmtCurr->execute([$userId]);
        $currentUser = $stmtCurr->fetch();

        $stmt = $db->prepare("UPDATE users SET name = ?, phone = ?, address = ?, email = ?, nik = ? WHERE id = ?");
        $stmt->execute([$name, $phone, $address, $email, $nik, $userId]);

        // TWO-WAY REALTIME SINKRONISASI: Jika akun adalah wali_murid atau terhubung siswa, update tabel students di hosting
        if ($currentUser) {
            if ($currentUser['role'] === 'wali_murid' || !empty($currentUser['student_id'])) {
                // 1. Update berdasarkan student_id
                if (!empty($currentUser['student_id'])) {
                    $stmtStd = $db->prepare("UPDATE students SET parent_name = ?, parent_phone = ?, parent_nik = ?, address = CASE WHEN ? != '' THEN ? ELSE address END WHERE id = ?");
                    $stmtStd->execute([$name, $phone, $nik, $address, $address, $currentUser['student_id']]);
                }
                // 2. Update berdasarkan NIK orang tua (multi-anak)
                if (!empty($nik)) {
                    $stmtStdNik = $db->prepare("UPDATE students SET parent_name = ?, parent_phone = ?, address = CASE WHEN ? != '' THEN ? ELSE address END WHERE parent_nik = ?");
                    $stmtStdNik->execute([$name, $phone, $address, $address, $nik]);
                }
                // 3. Fallback: jika NIK lama ada dan berubah
                if (!empty($currentUser['nik']) && $currentUser['nik'] !== $nik) {
                    $stmtStdOldNik = $db->prepare("UPDATE students SET parent_name = ?, parent_phone = ?, parent_nik = ? WHERE parent_nik = ?");
                    $stmtStdOldNik->execute([$name, $phone, $nik, $currentUser['nik']]);
                }
            }
        }

        // Return updated user
        $stmt = $db->prepare("SELECT id, username, email, name, role, phone, address, nik, assigned_class, student_id FROM users WHERE id = ? LIMIT 1");
        $stmt->execute([$userId]);
        $updatedUser = $stmt->fetch();

        sendJsonResponse(true, 'Profil berhasil diperbarui secara real-time di server hosting', $updatedUser);
        break;

    default:
        sendJsonResponse(false, 'Aksi tidak didukung', null, 400);
}
