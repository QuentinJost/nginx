#!/bin/bash

# Chemin vers le fichier généré (montré dans le volume monté dans le conteneur nginx)
OUTPUT_FILE="/etc/nginx/conf.d/generated.conf"
SITES_AVAILABLE="/etc/nginx/conf.d/sites"
# Initialiser le fichier de configuration
echo "# Configuration générée automatiquement" > "$OUTPUT_FILE"

# Liste des conteneurs actifs ayant le label 'app.virtual_host'
containers=$(docker ps --filter "network=${NETWORK_NAME}" -q)
echo "Containers found: $(docker ps --filter "label=app.virtual_host" -q)"
# Pour chaque conteneur trouvé, récupérer les labels et générer un bloc serveur
for container in $containers; do
     # Récupérer le nom du conteneur qui correspond au hostname interne (supprimer le "/" initial)
    container_name=$(docker inspect --format='{{ .Name }}' "$container" | sed 's/^\///')

    if [ -d "$SITES_AVAILABLE/${container_name}" ]; then
        echo "#Configuration files for $container_name" >> "$OUTPUT_FILE"
        for file in "$SITES_AVAILABLE/${container_name}"/*; do
            if [ -f "$file" ]; then
                cat "$file" >> "$OUTPUT_FILE"
            fi
            echo "" >> "$OUTPUT_FILE"
        done
    else
        echo "No directory found for $container_name"
    fi
done