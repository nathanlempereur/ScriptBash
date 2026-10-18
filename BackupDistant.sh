#!/bin/bash

# --- Configuration ---
REMOTE_USER="ton_utilisateur"
REMOTE_HOST="192.168.1.100"
REMOTE_TARGET="/var/www/html"   # Le dossier à sauvegarder sur le serveur
LOCAL_DEST="/backups"           # Le dossier de stockage sur ta machine locale

# Couleurs
valid='\e[32m'
erreur='\e[31m'
blanc='\e[0m'

echo -e "${valid}
**************************************************************************
********* Sauvegarde DISTANTE (${REMOTE_HOST}) vers LOCAL **********
**************************************************************************${blanc}"

# Vérification/Création du dossier local si nécessaire
if [[ ! -d "$LOCAL_DEST" ]]; then
    echo "Création du dossier local $LOCAL_DEST..."
    mkdir -p "$LOCAL_DEST"
fi

# Préparation du nom de l'archive
date_sauvegarde=$(date +"%d-%m-%Y_%H-%M")
nom_archive="backup_www_${date_sauvegarde}.tgz"

echo "Connexion à ${REMOTE_HOST} et compression du dossier ${REMOTE_TARGET}..."

# Explication de la commande :
# 1. On se connecte en SSH
# 2. On lance 'tar' sur le serveur distant
# 3. Le '-' à la fin de tar envoie le flux vers la sortie standard (stdout)
# 4. Le '>' redirige ce flux vers un fichier sur TA machine locale
ssh "${REMOTE_USER}@${REMOTE_HOST}" "tar -czf - -C $(dirname "$REMOTE_TARGET") $(basename "$REMOTE_TARGET")" > "${LOCAL_DEST}/${nom_archive}"

# Vérification du succès
if [[ $? -eq 0 && -s "${LOCAL_DEST}/${nom_archive}" ]]; then
    echo -e "${valid}
*************************************************************************************
*************************** Backup rapatrié avec succès ! ***************************
*************************************************************************************${blanc}"
    echo -e "Fichier : ${LOCAL_DEST}/${nom_archive}"
    echo -e "Taille  : $(du -h "${LOCAL_DEST}/${nom_archive}" | cut -f1)"
else
    echo -e "${erreur}
*************************************************************************************
************************* Erreur lors de la récupération du backup ******************
*************************************************************************************${blanc}"
    # Supprime le fichier s'il est vide ou corrompu suite à l'erreur
    rm -f "${LOCAL_DEST}/${nom_archive}"
    exit 1
fi
