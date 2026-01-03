<?php
// api_simcard.php - SIM Card Management API

require_once 'config.php';

// ==================== SIM CARD FUNCTIONS ====================

// 1. GET ALL SIM CARDS FOR A CONTACT
function getSimCardsByContact($db, $contactId) {
    try {
        $query = "SELECT * FROM sim_card WHERE contact_id = :contact_id ORDER BY date_ajout DESC";
        
        $stmt = $db->prepare($query);
        $stmt->bindParam(':contact_id', $contactId, PDO::PARAM_INT);
        $stmt->execute();
        
        $simCards = [];
        while ($row = $stmt->fetch()) {
            $simCards[] = [
                'id' => (int)$row['id'],
                'contactId' => (int)$row['contact_id'],
                'operateur' => $row['operateur'],
                'numero' => $row['numero'],
                'dateAjout' => $row['date_ajout']
            ];
        }
        
        sendResponse(true, 'Cartes SIM récupérées', $simCards);
        
    } catch (Exception $e) {
        error_log('Get SIM Cards Error: ' . $e->getMessage());
        sendResponse(false, 'Erreur lors de la récupération des cartes SIM', null, 500);
    }
}

// 2. GET SIM CARD BY ID
function getSimCardById($db, $id) {
    try {
        $query = "SELECT * FROM sim_card WHERE id = :id";
        
        $stmt = $db->prepare($query);
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->execute();
        
        if ($row = $stmt->fetch()) {
            $simCard = [
                'id' => (int)$row['id'],
                'contactId' => (int)$row['contact_id'],
                'operateur' => $row['operateur'],
                'numero' => $row['numero'],
                'dateAjout' => $row['date_ajout']
            ];
            sendResponse(true, 'Carte SIM trouvée', $simCard);
        } else {
            sendResponse(false, 'Carte SIM non trouvée', null, 404);
        }
        
    } catch (Exception $e) {
        error_log('Get SIM Card Error: ' . $e->getMessage());
        sendResponse(false, 'Erreur lors de la récupération de la carte SIM', null, 500);
    }
}

// 3. CREATE SIM CARD
function createSimCard($db, $data) {
    // Validate input
    if (!isset($data['contactId']) || 
        !isset($data['operateur']) || 
        !isset($data['numero'])) {
        sendResponse(false, 'Données incomplètes', null, 400);
    }
    
    // Validate operator
    $validOperators = ['Ooredoo', 'Mobilis', 'Djezzy'];
    if (!in_array($data['operateur'], $validOperators)) {
        sendResponse(false, 'Opérateur invalide. Choisissez: Ooredoo, Mobilis, ou Djezzy', null, 400);
    }
    
    try {
        // Check if contact exists
        $checkQuery = "SELECT id FROM contact WHERE id = :contact_id";
        $checkStmt = $db->prepare($checkQuery);
        $checkStmt->bindParam(':contact_id', $data['contactId'], PDO::PARAM_INT);
        $checkStmt->execute();
        
        if (!$checkStmt->fetch()) {
            sendResponse(false, 'Contact non trouvé', null, 404);
        }
        
        // Insert SIM card
        $query = "INSERT INTO sim_card (contact_id, operateur, numero, date_ajout) 
                  VALUES (:contact_id, :operateur, :numero, NOW())";
        
        $stmt = $db->prepare($query);
        $stmt->bindParam(':contact_id', $data['contactId'], PDO::PARAM_INT);
        $stmt->bindParam(':operateur', $data['operateur']);
        $stmt->bindParam(':numero', $data['numero']);
        $stmt->execute();
        
        $simCardId = $db->lastInsertId();
        
        $newSimCard = [
            'id' => (int)$simCardId,
            'contactId' => (int)$data['contactId'],
            'operateur' => $data['operateur'],
            'numero' => $data['numero'],
            'dateAjout' => date('Y-m-d H:i:s')
        ];
        
        sendResponse(true, 'Carte SIM ajoutée avec succès', $newSimCard, 201);
        
    } catch (Exception $e) {
        error_log('Create SIM Card Error: ' . $e->getMessage());
        sendResponse(false, 'Erreur lors de l\'ajout de la carte SIM', null, 500);
    }
}

// 4. UPDATE SIM CARD
function updateSimCard($db, $id, $data) {
    if (!isset($data['operateur']) || !isset($data['numero'])) {
        sendResponse(false, 'Données incomplètes', null, 400);
    }
    
    // Validate operator
    $validOperators = ['Ooredoo', 'Mobilis', 'Djezzy'];
    if (!in_array($data['operateur'], $validOperators)) {
        sendResponse(false, 'Opérateur invalide. Choisissez: Ooredoo, Mobilis, ou Djezzy', null, 400);
    }
    
    try {
        // Check if SIM card exists
        $checkQuery = "SELECT id FROM sim_card WHERE id = :id";
        $checkStmt = $db->prepare($checkQuery);
        $checkStmt->bindParam(':id', $id, PDO::PARAM_INT);
        $checkStmt->execute();
        
        if (!$checkStmt->fetch()) {
            sendResponse(false, 'Carte SIM non trouvée', null, 404);
        }
        
        // Update SIM card
        $query = "UPDATE sim_card SET 
                  operateur = :operateur,
                  numero = :numero
                  WHERE id = :id";
        
        $stmt = $db->prepare($query);
        $stmt->bindParam(':operateur', $data['operateur']);
        $stmt->bindParam(':numero', $data['numero']);
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->execute();
        
        sendResponse(true, 'Carte SIM mise à jour avec succès', [
            'id' => (int)$id,
            'operateur' => $data['operateur'],
            'numero' => $data['numero']
        ]);
        
    } catch (Exception $e) {
        error_log('Update SIM Card Error: ' . $e->getMessage());
        sendResponse(false, 'Erreur lors de la mise à jour de la carte SIM', null, 500);
    }
}

// 5. DELETE SIM CARD
function deleteSimCard($db, $id) {
    try {
        // Check if SIM card exists
        $checkQuery = "SELECT id FROM sim_card WHERE id = :id";
        $checkStmt = $db->prepare($checkQuery);
        $checkStmt->bindParam(':id', $id, PDO::PARAM_INT);
        $checkStmt->execute();
        
        if (!$checkStmt->fetch()) {
            sendResponse(false, 'Carte SIM non trouvée', null, 404);
        }
        
        // Delete SIM card
        $query = "DELETE FROM sim_card WHERE id = :id";
        $stmt = $db->prepare($query);
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->execute();
        
        sendResponse(true, 'Carte SIM supprimée avec succès');
        
    } catch (Exception $e) {
        error_log('Delete SIM Card Error: ' . $e->getMessage());
        sendResponse(false, 'Erreur lors de la suppression de la carte SIM', null, 500);
    }
}

// 6. GET ALL SIM CARDS BY OPERATOR
function getSimCardsByOperator($db, $operateur) {
    try {
        $query = "SELECT s.*, c.id as contact_id, p.nom, p.prenom 
                  FROM sim_card s
                  INNER JOIN contact c ON s.contact_id = c.id
                  INNER JOIN personne p ON c.personne_id = p.id
                  WHERE s.operateur = :operateur
                  ORDER BY s.date_ajout DESC";
        
        $stmt = $db->prepare($query);
        $stmt->bindParam(':operateur', $operateur);
        $stmt->execute();
        
        $simCards = [];
        while ($row = $stmt->fetch()) {
            $simCards[] = [
                'id' => (int)$row['id'],
                'contactId' => (int)$row['contact_id'],
                'operateur' => $row['operateur'],
                'numero' => $row['numero'],
                'dateAjout' => $row['date_ajout'],
                'contactName' => $row['prenom'] . ' ' . $row['nom']
            ];
        }
        
        sendResponse(true, "Cartes SIM $operateur récupérées", $simCards);
        
    } catch (Exception $e) {
        error_log('Get SIM Cards By Operator Error: ' . $e->getMessage());
        sendResponse(false, 'Erreur lors de la récupération des cartes SIM', null, 500);
    }
}

// ==================== ROUTER ====================

$database = new Database();
$db = $database->connect();

$method = $_SERVER['REQUEST_METHOD'];
$input = json_decode(file_get_contents('php://input'), true);

// Get action and parameters
$action = isset($_GET['action']) ? $_GET['action'] : (isset($input['action']) ? $input['action'] : null);
$id = isset($_GET['id']) ? $_GET['id'] : (isset($input['id']) ? $input['id'] : null);
$contactId = isset($_GET['contactId']) ? $_GET['contactId'] : null;
$operateur = isset($_GET['operateur']) ? $_GET['operateur'] : null;

try {
    if ($method === 'GET') {
        switch ($action) {
            case 'getById':
                if ($id) {
                    getSimCardById($db, $id);
                } else {
                    sendResponse(false, 'ID requis', null, 400);
                }
                break;
                
            case 'getByContact':
                if ($contactId) {
                    getSimCardsByContact($db, $contactId);
                } else {
                    sendResponse(false, 'ID du contact requis', null, 400);
                }
                break;
                
            case 'getByOperator':
                if ($operateur) {
                    getSimCardsByOperator($db, $operateur);
                } else {
                    sendResponse(false, 'Opérateur requis', null, 400);
                }
                break;
                
            default:
                sendResponse(false, 'Action non reconnue', null, 400);
        }
    }
    else if ($method === 'POST') {
        if ($action === 'create' && isset($input['simCard'])) {
            createSimCard($db, $input['simCard']);
        } else {
            sendResponse(false, 'Action ou données invalides', null, 400);
        }
    }
    else if ($method === 'PUT') {
        if ($action === 'update' && $id && isset($input['simCard'])) {
            updateSimCard($db, $id, $input['simCard']);
        } else {
            sendResponse(false, 'Action, ID ou données invalides', null, 400);
        }
    }
    else if ($method === 'DELETE') {
        if ($id) {
            deleteSimCard($db, $id);
        } else {
            sendResponse(false, 'ID requis', null, 400);
        }
    }
    else {
        sendResponse(false, 'Méthode HTTP non supportée', null, 405);
    }
} catch (Exception $e) {
    error_log('SIM Card API Error: ' . $e->getMessage());
    sendResponse(false, 'Erreur interne du serveur', null, 500);
}
?>
