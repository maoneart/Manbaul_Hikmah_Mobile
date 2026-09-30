<?php
require_once __DIR__ . '/../config/database.php';

$database = new Database();
$db = $database->getConnection();

if (!$db) {
    sendJsonResponse(false, 'Koneksi database MySQL gagal.', null, 500);
}

$stmt = $db->query("SELECT c.*, COUNT(s.id) as student_count, SUM(s.balance) as total_savings
                    FROM classes c
                    LEFT JOIN students s ON c.name = s.class_name
                    GROUP BY c.id
                    ORDER BY c.name ASC");
$classes = $stmt->fetchAll();

sendJsonResponse(true, 'Daftar kelas', $classes);
