#!/bin/bash

# ===============================================
# CONFIGURATION
# ===============================================
# Définition du temps d'attente maximum par port (en secondes)
TIMEOUT_SECONDS=10
# Définition des bornes de la plage de ports à scanner
START_PORT=1
END_PORT=65535

# Couleurs pour l'affichage des résultats
# Assurez-vous que les variables 'valid', 'erreur', et 'blanc' sont définies
# dans 'config.sh' ou définissez-les ici pour l'autonomie du script
# Exemple :
# valid='\033[32m' # Vert
# erreur='\033[31m' # Rouge
# blanc='\033[0m' # Réinitialisation

# Suppression des sources non fournies pour l'autonomie (assurez-vous que config.sh et fonction.sh sont bien accessibles si besoin réel)
# source config.sh
# source fonction.sh

# ===============================================
# FONCTIONS
# ===============================================

# Fonction de validation d'adresse IP simplifiée pour le script
# (Assurez-vous d'avoir une fonction 'validIP' robuste dans votre environnement réel)
validIP() {
    # Vérification basique du format IP : A.B.C.D où chaque partie est entre 0 et 255
    if [[ $1 =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        return 0 # Vrai
    else
        return 1 # Faux
    fi
}

# Fonction pour tester un port TCP avec un timeout
# Paramètres : $1 = IP, $2 = Port
test_port_tcp() {
    local ip=$1
    local port=$2

    # Utilisation de 'timeout' pour limiter le temps d'exécution de la redirection /dev/tcp
    # La redirection est lancée dans un sous-shell ( ) pour isoler les erreurs
    timeout "$TIMEOUT_SECONDS" bash -c "(echo > /dev/tcp/$ip/$port)" 2>/dev/null
    
    # Vérification du code de retour
    local exit_code=$?

    if [ $exit_code -eq 0 ]; then
        # Code 0 : Connexion établie (Port OUVERT)
        echo -e "${valid}Port ${port} : OUVERT${blanc}"
        return 0
    elif [ $exit_code -eq 124 ]; then
        # Code 124 : La commande 'timeout' a expiré (Port FILTRÉ ou très LENT)
        # Ceci est un cas important pour éviter le blocage. Il faut considérer ce port comme inaccessible/filtré.
        echo -e "Port ${port} : FILTRÉ/TIMEOUT (${TIMEOUT_SECONDS}s)"
        return 1
    else
        # Autres codes (ex: 1 si connexion refusée/fermée)
        echo -e "Port ${port} : Fermé"
        return 1
    fi
}

# ===============================================
# LOGIQUE PRINCIPALE DU SCRIPT
# ===============================================

echo "--- Scanner TCP Avancé ---"

# 1. Saisie et Validation de l'Adresse IP
while true; do
    read -rp "Veuillez saisir l'adresse IP cible : " IP
    if validIP "$IP"; then
        break
    else
        echo -e "${erreur}Adresse IP non valide. Veuillez réessayer.${blanc}"
    fi
done

echo "Début du scan TCP sur $IP, ports de $START_PORT à $END_PORT (Timeout/port : ${TIMEOUT_SECONDS}s)"
echo "-------------------------------------"

# 2. Balayage des Ports
# La boucle itère sur l'ensemble des ports définis
for Port in $(seq $START_PORT $END_PORT); do
    # Appel de la fonction de test pour chaque port
    test_port_tcp "$IP" "$Port"
done

echo "-------------------------------------"
echo "Scan terminé."
echo "[Appuyer sur entrer pour continuer]"
read -r
