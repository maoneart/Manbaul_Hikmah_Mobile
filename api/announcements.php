<?php
require_once __DIR__ . '/../config/database.php';

$database = new Database();
$db = $database->getConnection();

if (!$db) {
    sendJsonResponse(false, 'Koneksi database MySQL gagal.', null, 500);
}

$method = $_SERVER['REQUEST_METHOD'];

switch ($method) {
    case 'GET':
        $target = $_GET['target'] ?? 'all'; // 'all', 'teachers', 'parents'
        
        $query = "SELECT * FROM announcements WHERE 1=1";
        $params = [];

        if ($target === 'teachers') {
            $query .= " AND (target_audience = 'teachers' OR target_audience = 'all')";
        } elseif ($target === 'parents') {
            $query .= " AND (target_audience = 'parents' OR target_audience = 'all')";
        } elseif ($target === 'walikelas') {
            $query .= " AND (target_audience = 'walikelas' OR target_audience = 'all')";
        }

        $query .= " ORDER BY is_urgent DESC, created_at DESC";

        $stmt = $db->prepare($query);
        $stmt->execute($params);
        $announcements = $stmt->fetchAll();

        sendJsonResponse(true, 'Pengumuman sekolah berhasil dimuat', $announcements);
        break;

    case 'POST':
        $raw = file_get_contents('php://input');
        $input = json_decode($raw, true) ?: $_POST;

        $title = trim($input['title'] ?? '');
        $content = trim($input['content'] ?? '');
        $authorName = trim($input['author_name'] ?? 'KH. Ahmad Syafei, M.Pd.');
        $authorRole = trim($input['author_role'] ?? 'Kepala Sekolah');
        $targetAudience = trim($input['target_audience'] ?? 'all'); // 'all', 'teachers', 'parents'
        $category = trim($input['category'] ?? 'Akademik');
        $isUrgent = !empty($input['is_urgent']) ? 1 : 0;

        if (empty($title) || empty($content)) {
            sendJsonResponse(false, 'Judul dan isi pengumuman wajib diisi', null, 400);
        }

        $stmt = $db->prepare("INSERT INTO announcements (title, content, author_name, author_role, target_audience, category, is_urgent) 
                              VALUES (?, ?, ?, ?, ?, ?, ?)");
        $saved = $stmt->execute([$title, $content, $authorName, $authorRole, $targetAudience, $category, $isUrgent]);

        if ($saved) {
            $id = $db->lastInsertId();
            $get = $db->prepare("SELECT * FROM announcements WHERE id = ?");
            $get->execute([$id]);
            sendJsonResponse(true, 'Pengumuman Kepsek berhasil dipublikasikan!', $get->fetch(), 201);
        } else {
            sendJsonResponse(false, 'Gagal mempublikasikan pengumuman', null, 500);
        }
        break;

    default:
        sendJsonResponse(false, 'Method tidak didukung', null, 405);
}
