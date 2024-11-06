#!/bin/bash

# Variables
SOURCE_DB_NAME=Base de donnée source à exporter
DEST_DB_HOST=Machine de destination de la base de donnée
DEST_USER_HOST=Utilisateur de la machine de destination
DEST_DB_NAME=Base de donnée de destination
DEST_SITE_NAME=Nom du site web du GLPI de destination

# Dump et transfert de la base de donnée
echo "Starting database dump and transfer..."

# Dump et transfert avec utilisation du fichier .my.cnf pour les identifiants
mysqldump --add-drop-table "$SOURCE_DB_NAME" | ssh "$DEST_USER_HOST"@"$DEST_DB_HOST" "cat - | mysql ${DEST_DB_NAME}"

# Vérification des erreurs de dump et transfert
if [ $? -eq 0 ]; then
    echo "Database transfer successful!"
else
    echo "Error during database transfer."
    exit 1
fi

## Mise à jour de l'URL du site web de destination dans la base SQL

# Commande SQL d'update
SQL_QUERY="UPDATE glpi_configs SET value='$DEST_SITE_NAME' WHERE id=33;"

# Exécution de la commande SQL
ssh "$DEST_USER_HOST"@"$DEST_DB_HOST" "mysql -D $DEST_DB_NAME -e \"$SQL_QUERY\""

# Vérification de l'exécution
if [ $? -eq 0 ]; then
    echo "La mise à jour a été effectuée avec succès."
else
    echo "Erreur lors de la mise à jour de la base de données."
    exit 1
fi


# Vidage du cache GLPI
echo "Vidage du cache GLPI..."
/var/www/html/glpi/bin/console cache:clear

# Vérification de la commande de vidage du cache
if [ $? -eq 0 ]; then
    echo "Le cache GLPI a été vidé avec succès."
else
    echo "Erreur lors du vidage du cache GLPI."
    exit 1
fi

