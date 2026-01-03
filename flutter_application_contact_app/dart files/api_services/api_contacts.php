<?php
// api_contacts.php - Updated API with account support

require_once 'config.php';

// ==================== CONTACT FUNCTIONS ====================

// 1. GET ALL CONTACTS FOR AN ACCOUNT
function getAllContacts($db, $accountId) {
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
                  WHERE c.account_id = :account_id
                  ORDER BY c.date_ajout DESC";
        
        $stmt = $db->prepare($query);
        $stmt->bindParam(':account_id', $accountId, PDO::PARAM_INT);
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
function getContactById($db, $id, $accountId) {
    try {
        $query = "SELECT 
                    c.id as contact_id,
                    c.date_ajout,
                    c.account_id,
                    p.id as personne_id,
                    p.nom,
                    p.prenom,
                    p.telephone,
                    p.email,
                    p.image_url
                  FROM contact c
                  INNER JOIN personne p ON c.personne_id = p.id
                  WHERE c.id = :id AND c.account_id = :account_id";
        
        $stmt = $db->prepare($query);
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->bindParam(':account_id', $accountId, PDO::PARAM_INT);
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
function createContact($db, $data, $accountId) {
    if (!isset($data['personne']) || 
        !isset($data['personne']['nom']) || 
        !isset($data['personne']['prenom']) || 
        !isset($data['personne']['telephone'])) {
        sendResponse(false, 'Données incomplètes', null, 400);
    }
    
    $db->beginTransaction();
    
    try {
        // Generate email if not provided
        $email = isset($data['personne']['email']) && !empty($data['personne']['email']) 
                ? $data['personne']['email']
                : strtolower($data['personne']['prenom']) . '.' . 
                  strtolower($data['personne']['nom']) . '@email.com';
        
        $imageUrl = $data['personne']['imageUrl'] ?? null;
        
        // Insert person
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
        
        // Insert contact with account_id
        $dateAjout = date('Y-m-d H:i:s');
        $queryContact = "INSERT INTO contact (account_id, personne_id, date_ajout) 
                         VALUES (:account_id, :personne_id, :date_ajout)";
        
        $stmtContact = $db->prepare($queryContact);
        $stmtContact->bindParam(':account_id', $accountId, PDO::PARAM_INT);
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
function updateContact($db, $id, $data, $accountId) {
    if (!isset($data['personne'])) {
        sendResponse(false, 'Données incomplètes', null, 400);
    }
    
    $db->beginTransaction();
    
    try {
        // Check if contact belongs to account
        $queryCheck = "SELECT personne_id FROM contact 
                       WHERE id = :id AND account_id = :account_id";
        $stmtCheck = $db->prepare($queryCheck);
        $stmtCheck->bindParam(':id', $id, PDO::PARAM_INT);
        $stmtCheck->bindParam(':account_id', $accountId, PDO::PARAM_INT);
        $stmtCheck->execute();
        $result = $stmtCheck->fetch();
        
        if (!$result) {
            $db->rollBack();
            sendResponse(false, 'Contact non trouvé ou non autorisé', null, 404);
        }
        
        $personneId = $result['personne_id'];
        
        // Update person
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
function deleteContact($db, $id, $accountId) {
    try {
        // Check if contact belongs to account
        $queryGet = "SELECT personne_id FROM contact 
                     WHERE id = :id AND account_id = :account_id";
        $stmtGet = $db->prepare($queryGet);
        $stmtGet->bindParam(':id', $id, PDO::PARAM_INT);
        $stmtGet->bindParam(':account_id', $accountId, PDO::PARAM_INT);
        $stmtGet->execute();
        $result = $stmtGet->fetch();
        
        if (!$result) {
            sendResponse(false, 'Contact non trouvé ou non autorisé', null, 404);
        }
        
        $personneId = $result['personne_id'];
        
        // Delete contact (will cascade delete SIM cards)
        $queryDeleteContact = "DELETE FROM contact WHERE id = :id";
        $stmtContact = $db->prepare($queryDeleteContact);
        $stmtContact->bindParam(':id', $id, PDO::PARAM_INT);
        $stmtContact->execute();
        
        // Delete person
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
function searchContacts($db, $query, $accountId) {
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
                WHERE c.account_id = :account_id
                  AND (p.nom LIKE :search 
                   OR p.prenom LIKE :search 
                   OR p.telephone LIKE :search
                   OR p.email LIKE :search)
                ORDER BY c.date_ajout DESC";
        
        $stmt = $db->prepare($sql);
        $stmt->bindParam(':account_id', $accountId, PDO::PARAM_INT);
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

// ==================== ROUTER ====================

$database = new Database();
$db = $database->connect();

$method = $_SERVER['REQUEST_METHOD'];
$input = json_decode(file_get_contents('php://input'), true);

$action = isset($_GET['action']) ? $_GET['action'] : (isset($input['action']) ? $input['action'] : null);
$id = isset($_GET['id']) ? $_GET['id'] : (isset($input['id']) ? $input['id'] : null);
$accountId = isset($_GET['accountId']) ? $_GET['accountId'] : (isset($input['accountId']) ? $input['accountId'] : null);

// Account ID is required for all operations
if (!$accountId && $method !== 'OPTIONS') {
    sendResponse(false, 'Account ID requis', null, 401);
}

try {
    if ($method === 'GET') {
        switch($action) {
            case 'getById':
                if ($id) {
                    getContactById($db, $id, $accountId);
                } else {
                    sendResponse(false, 'ID du contact requis', null, 400);
                }
                break;
            case 'search':
                if (isset($_GET['q'])) {
                    searchContacts($db, $_GET['q'], $accountId);
                } else {
                    sendResponse(false, 'Terme de recherche requis', null, 400);
                }
                break;
            default:
                getAllContacts($db, $accountId);
                break;
        }
    } 
    else if ($method === 'POST') {
        if ($action === 'create' && isset($input['contact'])) {
            createContact($db, $input['contact'], $accountId);
        } else {
            sendResponse(false, 'Action ou données invalides', null, 400);
        }
    } 
    else if ($method === 'PUT') {
        if ($action === 'update' && $id && isset($input['contact'])) {
            updateContact($db, $id, $input['contact'], $accountId);
        } else {
            sendResponse(false, 'Action, ID ou données invalides', null, 400);
        }
    } 
    else if ($method === 'DELETE') {
        if ($id) {
            deleteContact($db, $id, $accountId);
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
