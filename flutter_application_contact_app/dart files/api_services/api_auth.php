<?php
// api_auth.php - Authentication API

require_once 'config.php';

// ==================== AUTHENTICATION FUNCTIONS ====================

// 1. LOGIN
function login($db, $username, $password) {
    try {
        // Get account with person details
        $query = "SELECT 
                    a.id as account_id,
                    a.username,
                    a.password,
                    a.is_active,
                    a.personne_id,
                    p.nom,
                    p.prenom,
                    p.telephone,
                    p.email,
                    p.image_url
                  FROM account a
                  INNER JOIN personne p ON a.personne_id = p.id
                  WHERE a.username = :username";
        
        $stmt = $db->prepare($query);
        $stmt->bindParam(':username', $username);
        $stmt->execute();
        
        $account = $stmt->fetch();
        
        if (!$account) {
            sendResponse(false, 'Nom d\'utilisateur ou mot de passe incorrect', null, 401);
        }
        
        // Check if account is active
        if (!$account['is_active']) {
            sendResponse(false, 'Compte désactivé', null, 403);
        }
        
        // Verify password
        if (!password_verify($password, $account['password'])) {
            sendResponse(false, 'Nom d\'utilisateur ou mot de passe incorrect', null, 401);
        }
        
        // Update last login
        $updateQuery = "UPDATE account SET last_login = NOW() WHERE id = :id";
        $updateStmt = $db->prepare($updateQuery);
        $updateStmt->bindParam(':id', $account['account_id']);
        $updateStmt->execute();
        
        // Generate simple token (in production, use JWT)
        $token = bin2hex(random_bytes(32));
        
        // Return user data without password
        $userData = [
            'account' => [
                'id' => (int)$account['account_id'],
                'username' => $account['username'],
                'personneId' => (int)$account['personne_id'],
                'createdAt' => date('Y-m-d H:i:s')
            ],
            'personne' => [
                'id' => (int)$account['personne_id'],
                'nom' => $account['nom'],
                'prenom' => $account['prenom'],
                'telephone' => $account['telephone'],
                'email' => $account['email'],
                'imageUrl' => $account['image_url']
            ],
            'token' => $token
        ];
        
        sendResponse(true, 'Connexion réussie', $userData);
        
    } catch (Exception $e) {
        error_log('Login Error: ' . $e->getMessage());
        sendResponse(false, 'Erreur lors de la connexion', null, 500);
    }
}

// 2. REGISTER
function register($db, $data) {
    // Validate input
    if (!isset($data['username']) || 
        !isset($data['password']) || 
        !isset($data['personne']['nom']) || 
        !isset($data['personne']['prenom']) || 
        !isset($data['personne']['telephone'])) {
        sendResponse(false, 'Données incomplètes', null, 400);
    }
    
    // Check username length
    if (strlen($data['username']) < 3) {
        sendResponse(false, 'Le nom d\'utilisateur doit contenir au moins 3 caractères', null, 400);
    }
    
    // Check password length
    if (strlen($data['password']) < 6) {
        sendResponse(false, 'Le mot de passe doit contenir au moins 6 caractères', null, 400);
    }
    
    $db->beginTransaction();
    
    try {
        // Check if username already exists
        $checkQuery = "SELECT id FROM account WHERE username = :username";
        $checkStmt = $db->prepare($checkQuery);
        $checkStmt->bindParam(':username', $data['username']);
        $checkStmt->execute();
        
        if ($checkStmt->fetch()) {
            $db->rollBack();
            sendResponse(false, 'Ce nom d\'utilisateur existe déjà', null, 409);
        }
        
        // Generate email if not provided
        $email = isset($data['personne']['email']) && !empty($data['personne']['email'])
                ? $data['personne']['email']
                : strtolower($data['personne']['prenom']) . '.' . 
                  strtolower($data['personne']['nom']) . '@email.com';
        
        $imageUrl = $data['personne']['imageUrl'] ?? null;
        
        // Insert person
        $personQuery = "INSERT INTO personne (nom, prenom, telephone, email, image_url) 
                        VALUES (:nom, :prenom, :telephone, :email, :image_url)";
        
        $personStmt = $db->prepare($personQuery);
        $personStmt->bindParam(':nom', $data['personne']['nom']);
        $personStmt->bindParam(':prenom', $data['personne']['prenom']);
        $personStmt->bindParam(':telephone', $data['personne']['telephone']);
        $personStmt->bindParam(':email', $email);
        $personStmt->bindParam(':image_url', $imageUrl);
        $personStmt->execute();
        
        $personneId = $db->lastInsertId();
        
        // Hash password
        $hashedPassword = password_hash($data['password'], PASSWORD_DEFAULT);
        
        // Insert account
        $accountQuery = "INSERT INTO account (username, password, personne_id) 
                         VALUES (:username, :password, :personne_id)";
        
        $accountStmt = $db->prepare($accountQuery);
        $accountStmt->bindParam(':username', $data['username']);
        $accountStmt->bindParam(':password', $hashedPassword);
        $accountStmt->bindParam(':personne_id', $personneId);
        $accountStmt->execute();
        
        $accountId = $db->lastInsertId();
        
        $db->commit();
        
        $newUser = [
            'account' => [
                'id' => (int)$accountId,
                'username' => $data['username'],
                'personneId' => (int)$personneId,
                'createdAt' => date('Y-m-d H:i:s')
            ],
            'personne' => [
                'id' => (int)$personneId,
                'nom' => $data['personne']['nom'],
                'prenom' => $data['personne']['prenom'],
                'telephone' => $data['personne']['telephone'],
                'email' => $email,
                'imageUrl' => $imageUrl
            ]
        ];
        
        sendResponse(true, 'Compte créé avec succès', $newUser, 201);
        
    } catch (Exception $e) {
        $db->rollBack();
        error_log('Register Error: ' . $e->getMessage());
        sendResponse(false, 'Erreur lors de la création du compte', null, 500);
    }
}

// 3. GET USER PROFILE
function getUserProfile($db, $accountId) {
    try {
        $query = "SELECT 
                    a.id as account_id,
                    a.username,
                    a.is_active,
                    a.created_at,
                    a.last_login,
                    p.id as personne_id,
                    p.nom,
                    p.prenom,
                    p.telephone,
                    p.email,
                    p.image_url
                  FROM account a
                  INNER JOIN personne p ON a.personne_id = p.id
                  WHERE a.id = :id";
        
        $stmt = $db->prepare($query);
        $stmt->bindParam(':id', $accountId);
        $stmt->execute();
        
        $account = $stmt->fetch();
        
        if (!$account) {
            sendResponse(false, 'Compte non trouvé', null, 404);
        }
        
        $userData = [
            'account' => [
                'id' => (int)$account['account_id'],
                'username' => $account['username'],
                'personneId' => (int)$account['personne_id'],
                'createdAt' => $account['created_at'],
                'lastLogin' => $account['last_login']
            ],
            'personne' => [
                'id' => (int)$account['personne_id'],
                'nom' => $account['nom'],
                'prenom' => $account['prenom'],
                'telephone' => $account['telephone'],
                'email' => $account['email'],
                'imageUrl' => $account['image_url']
            ]
        ];
        
        sendResponse(true, 'Profil récupéré', $userData);
        
    } catch (Exception $e) {
        error_log('Get Profile Error: ' . $e->getMessage());
        sendResponse(false, 'Erreur lors de la récupération du profil', null, 500);
    }
}

// 4. UPDATE PASSWORD
function updatePassword($db, $accountId, $oldPassword, $newPassword) {
    try {
        // Get current password
        $query = "SELECT password FROM account WHERE id = :id";
        $stmt = $db->prepare($query);
        $stmt->bindParam(':id', $accountId);
        $stmt->execute();
        
        $account = $stmt->fetch();
        
        if (!$account) {
            sendResponse(false, 'Compte non trouvé', null, 404);
        }
        
        // Verify old password
        if (!password_verify($oldPassword, $account['password'])) {
            sendResponse(false, 'Ancien mot de passe incorrect', null, 401);
        }
        
        // Check new password length
        if (strlen($newPassword) < 6) {
            sendResponse(false, 'Le nouveau mot de passe doit contenir au moins 6 caractères', null, 400);
        }
        
        // Hash new password
        $hashedPassword = password_hash($newPassword, PASSWORD_DEFAULT);
        
        // Update password
        $updateQuery = "UPDATE account SET password = :password, updated_at = NOW() WHERE id = :id";
        $updateStmt = $db->prepare($updateQuery);
        $updateStmt->bindParam(':password', $hashedPassword);
        $updateStmt->bindParam(':id', $accountId);
        $updateStmt->execute();
        
        sendResponse(true, 'Mot de passe mis à jour avec succès');
        
    } catch (Exception $e) {
        error_log('Update Password Error: ' . $e->getMessage());
        sendResponse(false, 'Erreur lors de la mise à jour du mot de passe', null, 500);
    }
}

// ==================== ROUTER ====================

$database = new Database();
$db = $database->connect();

$method = $_SERVER['REQUEST_METHOD'];
$input = json_decode(file_get_contents('php://input'), true);

// Get action
$action = isset($_GET['action']) ? $_GET['action'] : (isset($input['action']) ? $input['action'] : null);

try {
    if ($method === 'POST') {
        switch ($action) {
            case 'login':
                if (isset($input['username']) && isset($input['password'])) {
                    login($db, $input['username'], $input['password']);
                } else {
                    sendResponse(false, 'Nom d\'utilisateur et mot de passe requis', null, 400);
                }
                break;
                
            case 'register':
                register($db, $input);
                break;
                
            case 'updatePassword':
                if (isset($input['accountId']) && isset($input['oldPassword']) && isset($input['newPassword'])) {
                    updatePassword($db, $input['accountId'], $input['oldPassword'], $input['newPassword']);
                } else {
                    sendResponse(false, 'Données incomplètes', null, 400);
                }
                break;
                
            default:
                sendResponse(false, 'Action non reconnue', null, 400);
        }
    } 
    else if ($method === 'GET') {
        if ($action === 'profile' && isset($_GET['accountId'])) {
            getUserProfile($db, $_GET['accountId']);
        } else {
            sendResponse(false, 'Action ou paramètres invalides', null, 400);
        }
    }
    else {
        sendResponse(false, 'Méthode HTTP non supportée', null, 405);
    }
} catch (Exception $e) {
    error_log('Auth API Error: ' . $e->getMessage());
    sendResponse(false, 'Erreur interne du serveur', null, 500);
}
?>
