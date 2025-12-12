<?php
// api_contacts.php - API complète pour gérer les contacts

// ==================== CONFIGURATION ====================
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

// Gérer les requêtes OPTIONS (preflight)
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Configuration de la base de données
define('DB_HOST', 'localhost');
define('DB_USER', 'root');
define('DB_PASS', '');
define('DB_NAME', 'contact_app');

// Fonction pour envoyer une réponse JSON
function sendResponse($success, $message, $data = null, $statusCode = 200) {
    http_response_code($statusCode);
    $response = [
        'success' => $success,
        'message' => $message
    ];
    
    if ($data !== null) {
        $response['data'] = $data;
    }
    
    echo json_encode($response, JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT);
    exit();
}

// ==================== CONNEXION DB ====================
class Database {
    private $host = DB_HOST;
    private $user = DB_USER;
    private $pass = DB_PASS;
    private $dbname = DB_NAME;
    private $conn;

    public function connect() {
        $this->conn = null;

        try {
            $this->conn = new PDO(
                "mysql:host={$this->host};dbname={$this->dbname};charset=utf8mb4",
                $this->user,
                $this->pass,
                [
                    PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                    PDO::ATTR_EMULATE_PREPARES => false
                ]
            );
        } catch(PDOException $e) {
            error_log('Connection Error: ' . $e->getMessage());
            sendResponse(false, 'Database connection failed', null, 500);
        }

        return $this->conn;
    }
}

// ==================== FONCTIONS CRUD ====================

// 1. GET ALL CONTACTS
function getAllContacts($db) {
    try {
        $query = "SELECT 
                    c.id as contact_id,
                    c.date_ajout,
                    p.id as personne_id,
                    p.nom,
                    p.prenom,
                    p.telephone,
                    p.email,
                    p.image_url
                  FROM contact c
                  INNER JOIN personne p ON c.personne_id = p.id
                  ORDER BY c.date_ajout DESC";
        
        $stmt = $db->prepare($query);
        $stmt->execute();
        
        $contacts = [];
        while ($row = $stmt->fetch()) {
            $contacts[] = [
                'id' => (int)$row['contact_id'],
                'personne' => [
                    'id' => (int)$row['personne_id'],
                    'nom' => $row['nom'],
                    'prenom' => $row['prenom'],
                    'telephone' => $row['telephone'],
                    'email' => $row['email'],
                    'imageUrl' => $row['image_url']
                ],
                'dateAjout' => $row['date_ajout']
            ];
        }
        
        sendResponse(true, 'Contacts récupérés avec succès', $contacts);
    } catch (Exception $e) {
        error_log('getAllContacts Error: ' . $e->getMessage());
        sendResponse(false, 'Erreur lors de la récupération des contacts', null, 500);
    }
}

// 2. GET CONTACT BY ID
function getContactById($db, $id) {
    try {
        $query = "SELECT 
                    c.id as contact_id,
                    c.date_ajout,
                    p.id as personne_id,
                    p.nom,
                    p.prenom,
                    p.telephone,
                    p.email,
                    p.image_url
                  FROM contact c
                  INNER JOIN personne p ON c.personne_id = p.id
                  WHERE c.id = :id";
        
        $stmt = $db->prepare($query);
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->execute();
        
        if ($row = $stmt->fetch()) {
            $contact = [
                'id' => (int)$row['contact_id'],
                'personne' => [
                    'id' => (int)$row['personne_id'],
                    'nom' => $row['nom'],
                    'prenom' => $row['prenom'],
                    'telephone' => $row['telephone'],
                    'email' => $row['email'],
                    'imageUrl' => $row['image_url']
                ],
                'dateAjout' => $row['date_ajout']
            ];
            sendResponse(true, 'Contact trouvé', $contact);
        } else {
            sendResponse(false, 'Contact non trouvé', null, 404);
        }
    } catch (Exception $e) {
        error_log('getContactById Error: ' . $e->getMessage());
        sendResponse(false, 'Erreur lors de la recherche du contact', null, 500);
    }
}

// 3. CREATE CONTACT
function createContact($db, $data) {
    // Validation des données
    if (!isset($data['personne']) || 
        !isset($data['personne']['nom']) || 
        !isset($data['personne']['prenom']) || 
        !isset($data['personne']['telephone'])) {
        sendResponse(false, 'Données incomplètes', null, 400);
    }
    
    $db->beginTransaction();
    
    try {
        // Email par défaut si non fourni
        $email = isset($data['personne']['email']) && !empty($data['personne']['email']) 
                ? $data['personne']['email']
                : strtolower($data['personne']['prenom']) . '.' . strtolower($data['personne']['nom']) . '@email.com';
        
        // Image par défaut si non fournie
        $imageUrl = $data['personne']['imageUrl'] ?? null;
        
        // Insérer la personne
        $queryPersonne = "INSERT INTO personne (nom, prenom, telephone, email, image_url) 
                          VALUES (:nom, :prenom, :telephone, :email, :image_url)";
        
        $stmtPersonne = $db->prepare($queryPersonne);
        $stmtPersonne->bindParam(':nom', $data['personne']['nom']);
        $stmtPersonne->bindParam(':prenom', $data['personne']['prenom']);
        $stmtPersonne->bindParam(':telephone', $data['personne']['telephone']);
        $stmtPersonne->bindParam(':email', $email);
        $stmtPersonne->bindParam(':image_url', $imageUrl);
        $stmtPersonne->execute();
        
        $personneId = $db->lastInsertId();
        
        // Insérer le contact
        $dateAjout = date('Y-m-d H:i:s');
        $queryContact = "INSERT INTO contact (personne_id, date_ajout) 
                         VALUES (:personne_id, :date_ajout)";
        
        $stmtContact = $db->prepare($queryContact);
        $stmtContact->bindParam(':personne_id', $personneId, PDO::PARAM_INT);
        $stmtContact->bindParam(':date_ajout', $dateAjout);
        $stmtContact->execute();
        
        $contactId = $db->lastInsertId();
        
        $db->commit();
        
        $newContact = [
            'id' => (int)$contactId,
            'personne' => [
                'id' => (int)$personneId,
                'nom' => $data['personne']['nom'],
                'prenom' => $data['personne']['prenom'],
                'telephone' => $data['personne']['telephone'],
                'email' => $email,
                'imageUrl' => $imageUrl
            ],
            'dateAjout' => $dateAjout
        ];
        
        sendResponse(true, 'Contact créé avec succès', $newContact, 201);
        
    } catch (Exception $e) {
        $db->rollBack();
        error_log('Create Contact Error: ' . $e->getMessage());
        sendResponse(false, 'Erreur lors de la création du contact', null, 500);
    }
}

// 4. UPDATE CONTACT
function updateContact($db, $id, $data) {
    if (!isset($data['personne'])) {
        sendResponse(false, 'Données incomplètes', null, 400);
    }
    
    $db->beginTransaction();
    
    try {
        // Récupérer l'ID de la personne associée au contact
        $queryGetPersonne = "SELECT personne_id FROM contact WHERE id = :id";
        $stmtGet = $db->prepare($queryGetPersonne);
        $stmtGet->bindParam(':id', $id, PDO::PARAM_INT);
        $stmtGet->execute();
        $result = $stmtGet->fetch();
        
        if (!$result) {
            $db->rollBack();
            sendResponse(false, 'Contact non trouvé', null, 404);
        }
        
        $personneId = $result['personne_id'];
        
        // Mettre à jour la personne
        $queryUpdatePersonne = "UPDATE personne SET 
                                nom = :nom,
                                prenom = :prenom,
                                telephone = :telephone,
                                email = :email,
                                image_url = :image_url
                                WHERE id = :id";
        
        $stmtPersonne = $db->prepare($queryUpdatePersonne);
        $stmtPersonne->bindParam(':nom', $data['personne']['nom']);
        $stmtPersonne->bindParam(':prenom', $data['personne']['prenom']);
        $stmtPersonne->bindParam(':telephone', $data['personne']['telephone']);
        $stmtPersonne->bindParam(':email', $data['personne']['email']);
        $imageUrl = $data['personne']['imageUrl'] ?? null;
        $stmtPersonne->bindParam(':image_url', $imageUrl);
        $stmtPersonne->bindParam(':id', $personneId, PDO::PARAM_INT);
        $stmtPersonne->execute();
        
        // Mettre à jour la date si fournie
        if (isset($data['dateAjout'])) {
            $queryUpdateContact = "UPDATE contact SET date_ajout = :date_ajout WHERE id = :id";
            $stmtContact = $db->prepare($queryUpdateContact);
            $stmtContact->bindParam(':date_ajout', $data['dateAjout']);
            $stmtContact->bindParam(':id', $id, PDO::PARAM_INT);
            $stmtContact->execute();
        }
        
        $db->commit();
        
        sendResponse(true, 'Contact mis à jour avec succès', [
            'id' => (int)$id,
            'personne' => $data['personne']
        ]);
        
    } catch (Exception $e) {
        $db->rollBack();
        error_log('Update Contact Error: ' . $e->getMessage());
        sendResponse(false, 'Erreur lors de la mise à jour du contact', null, 500);
    }
}

// 5. DELETE CONTACT
function deleteContact($db, $id) {
    try {
        // Récupérer l'ID de la personne avant suppression
        $queryGetPersonne = "SELECT personne_id FROM contact WHERE id = :id";
        $stmtGet = $db->prepare($queryGetPersonne);
        $stmtGet->bindParam(':id', $id, PDO::PARAM_INT);
        $stmtGet->execute();
        $result = $stmtGet->fetch();
        
        if (!$result) {
            sendResponse(false, 'Contact non trouvé', null, 404);
        }
        
        $personneId = $result['personne_id'];
        
        // Supprimer le contact
        $queryDeleteContact = "DELETE FROM contact WHERE id = :id";
        $stmtContact = $db->prepare($queryDeleteContact);
        $stmtContact->bindParam(':id', $id, PDO::PARAM_INT);
        $stmtContact->execute();
        
        // Supprimer la personne associée
        $queryDeletePersonne = "DELETE FROM personne WHERE id = :id";
        $stmtPersonne = $db->prepare($queryDeletePersonne);
        $stmtPersonne->bindParam(':id', $personneId, PDO::PARAM_INT);
        $stmtPersonne->execute();
        
        sendResponse(true, 'Contact supprimé avec succès');
        
    } catch (Exception $e) {
        error_log('Delete Contact Error: ' . $e->getMessage());
        sendResponse(false, 'Erreur lors de la suppression du contact', null, 500);
    }
}

// 6. SEARCH CONTACTS
function searchContacts($db, $query) {
    try {
        $searchTerm = "%$query%";
        $sql = "SELECT 
                    c.id as contact_id,
                    c.date_ajout,
                    p.id as personne_id,
                    p.nom,
                    p.prenom,
                    p.telephone,
                    p.email,
                    p.image_url
                FROM contact c
                INNER JOIN personne p ON c.personne_id = p.id
                WHERE p.nom LIKE :search 
                   OR p.prenom LIKE :search 
                   OR p.telephone LIKE :search
                   OR p.email LIKE :search
                ORDER BY c.date_ajout DESC";
        
        $stmt = $db->prepare($sql);
        $stmt->bindParam(':search', $searchTerm);
        $stmt->execute();
        
        $contacts = [];
        while ($row = $stmt->fetch()) {
            $contacts[] = [
                'id' => (int)$row['contact_id'],
                'personne' => [
                    'id' => (int)$row['personne_id'],
                    'nom' => $row['nom'],
                    'prenom' => $row['prenom'],
                    'telephone' => $row['telephone'],
                    'email' => $row['email'],
                    'imageUrl' => $row['image_url']
                ],
                'dateAjout' => $row['date_ajout']
            ];
        }
        
        sendResponse(true, 'Résultats de recherche', $contacts);
    } catch (Exception $e) {
        error_log('Search Contacts Error: ' . $e->getMessage());
        sendResponse(false, 'Erreur lors de la recherche', null, 500);
    }
}

// ==================== ROUTEUR PRINCIPAL ====================

$database = new Database();
$db = $database->connect();

$method = $_SERVER['REQUEST_METHOD'];
$input = json_decode(file_get_contents('php://input'), true);

// Récupérer l'action depuis GET ou POST
$action = isset($_GET['action']) ? $_GET['action'] : (isset($input['action']) ? $input['action'] : null);
$id = isset($_GET['id']) ? $_GET['id'] : (isset($input['id']) ? $input['id'] : null);

try {
    if ($method === 'GET') {
        switch($action) {
            case 'getById':
                if ($id) {
                    getContactById($db, $id);
                } else {
                    sendResponse(false, 'ID du contact requis', null, 400);
                }
                break;
            case 'search':
                if (isset($_GET['q'])) {
                    searchContacts($db, $_GET['q']);
                } else {
                    sendResponse(false, 'Terme de recherche requis', null, 400);
                }
                break;
            default:
                getAllContacts($db);
                break;
        }
    } 
    else if ($method === 'POST') {
        if ($action === 'create' && isset($input['contact'])) {
            createContact($db, $input['contact']);
        } else {
            sendResponse(false, 'Action ou données invalides', null, 400);
        }
    } 
    else if ($method === 'PUT') {
        if ($action === 'update' && $id && isset($input['contact'])) {
            updateContact($db, $id, $input['contact']);
        } else {
            sendResponse(false, 'Action, ID ou données invalides', null, 400);
        }
    } 
    else if ($method === 'DELETE') {
        if ($id) {
            deleteContact($db, $id);
        } else {
            sendResponse(false, 'ID du contact requis', null, 400);
        }
    } 
    else {
        sendResponse(false, 'Méthode HTTP non supportée', null, 405);
    }
} catch (Exception $e) {
    error_log('API Router Error: ' . $e->getMessage());
    sendResponse(false, 'Erreur interne du serveur', null, 500);
}
?>