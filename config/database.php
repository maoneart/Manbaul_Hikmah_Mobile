<?php
/**
 * Database Connection & Security Engine for Manbaul Hikmah Mobile
 */
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With, X-App-Key, X-Api-Key');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// ==========================================
// SECURITY LAYER: BLOCK PUBLIC BROWSER ACCESS (403 FORBIDDEN)
// ==========================================
define('MANBAUL_APP_KEY', 'MH-SECURE-API-2026-MAONEART');

$isHosting = (strpos($_SERVER['HTTP_HOST'] ?? '', 'maoneart.my.id') !== false) || 
             (strpos(__DIR__, 'maonear1') !== false);

// Check if request is to an API file
$requestPath = $_SERVER['SCRIPT_NAME'] ?? '';
$isApiEndpoint = strpos($requestPath, '/api/') !== false;

if ($isHosting && $isApiEndpoint) {
    $clientKey = $_SERVER['HTTP_X_APP_KEY'] ?? $_SERVER['HTTP_X_API_KEY'] ?? '';
    
    // Check Authorization header (Bearer token)
    $authHeader = $_SERVER['HTTP_AUTHORIZATION'] ?? $_SERVER['REDIRECT_HTTP_AUTHORIZATION'] ?? '';
    if (empty($clientKey) && !empty($authHeader)) {
        if (preg_match('/Bearer\s+(.*)$/i', $authHeader, $matches)) {
            $clientKey = trim($matches[1]);
        }
    }

    if ($clientKey !== MANBAUL_APP_KEY) {
        http_response_code(403);
        echo json_encode([
            'status' => false,
            'message' => '403 Forbidden: Akses publik ditolak. Data dilindungi dan hanya dapat diakses melalui aplikasi resmi Manbaul Hikmah Mobile.',
            'error_code' => 'UNAUTHORIZED_PUBLIC_ACCESS',
            'timestamp' => date('Y-m-d H:i:s')
        ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
        exit();
    }
}

class Database {
    private $host;
    private $db_name;
    private $username;
    private $password;
    public $conn;

    public function __construct() {
        $isHosting = (strpos($_SERVER['HTTP_HOST'] ?? '', 'maoneart.my.id') !== false) || 
                     (strpos(__DIR__, 'maonear1') !== false);

        if ($isHosting) {
            $this->host = "127.0.0.1";
            $this->db_name = "maonear1_manbaul";
            $this->username = "maonear1_manbaul";
            $this->password = "Manbaul#MaoneArt2026!";
        } else {
            $this->host = "127.0.0.1";
            $this->db_name = "manbaul_hikmah_db";
            $this->username = "root";
            $this->password = "";
        }
    }

    public function getConnection() {
        $this->conn = null;
        try {
            $this->conn = new PDO(
                "mysql:host=" . $this->host . ";dbname=" . $this->db_name . ";charset=utf8mb4",
                $this->username,
                $this->password,
                [
                    PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                    PDO::ATTR_EMULATE_PREPARES => false,
                ]
            );
        } catch(PDOException $e) {
            $this->conn = null;
        }
        return $this->conn;
    }
}

function sendJsonResponse($status, $message, $data = null, $httpCode = 200) {
    http_response_code($httpCode);
    echo json_encode([
        'status' => $status,
        'message' => $message,
        'data' => $data,
        'timestamp' => date('Y-m-d H:i:s')
    ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
    exit();
}
