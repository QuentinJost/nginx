#!/bin/bash
set -e

# Exécuter le script de génération pour récupérer la configuration basée sur les conteneurs actifs
/usr/local/bin/generate_nginx_conf.sh

# Lancer Nginx en remplaçant le processus actuel pour maintenir le conteneur actif
exec "$@"
