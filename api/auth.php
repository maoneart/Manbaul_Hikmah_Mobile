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

        $stmt = $db->prepare("UPDATE users SET name = ?, phone = ?, address = ?, email = ?, nik = ? WHERE id = ?");
        $stmt->execute([$name, $phone, $address, $email, $nik, $userId]);

        // Return updated user
        $stmt = $db->prepare("SELECT id, username, email, name, role, phone, address, nik, assigned_class, student_id FROM users WHERE id = ? LIMIT 1");
        $stmt->execute([$userId]);
        $updatedUser = $stmt->fetch();

        sendJsonResponse(true, 'Profil pengguna berhasil disimpan', $updatedUser);
        break;

    default:
        sendJsonResponse(false, 'Aksi tidak didukung', null, 400);
}
