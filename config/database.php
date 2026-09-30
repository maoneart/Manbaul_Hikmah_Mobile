<?php
/**
 * Database Connection for Manbaul Hikmah Mobile
 */
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
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
            // Return null if connection fails
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
