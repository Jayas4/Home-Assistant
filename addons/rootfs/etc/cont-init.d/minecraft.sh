#!/bin/sh

# Fonction pour obtenir les configurations depuis les variables d'environnement
get_config() {
    case $1 in
        'max_memory')
            echo "${MAX_MEMORY:-2G}"
            ;;
        'min_memory')
            echo "${MIN_MEMORY:-1G}"
            ;;
        'minecraft_version')
            echo "${MINECRAFT_VERSION:-1.21.5}"
            ;;
    esac
}

# Fonction pour le logging
log() {
    echo "[$(date +%T)] $1: $2"
}

# Obtenir les configurations
MAX_MEMORY=$(get_config 'max_memory')
MIN_MEMORY=$(get_config 'min_memory')
MINECRAFT_VERSION=$(get_config 'minecraft_version')

log "INFO" "Configuration du serveur Minecraft..."
log "INFO" "Version Minecraft: ${MINECRAFT_VERSION}"
log "INFO" "Mémoire Max: ${MAX_MEMORY}"
log "INFO" "Mémoire Min: ${MIN_MEMORY}"

# Créer les répertoires nécessaires
mkdir -p /data/minecraft
mkdir -p /share/minecraft_manager
chmod -R 755 /share/minecraft_manager

cd /data/minecraft || exit 1

# Afficher le contenu des répertoires pour le débogage
log "DEBUG" "Création et vérification des répertoires..."
log "DEBUG" "Contenu du répertoire /share:"
ls -la /share

log "DEBUG" "Contenu du répertoire /share/minecraft_manager:"
ls -la /share/minecraft_manager

log "DEBUG" "Contenu du répertoire /data/minecraft:"
ls -la /data/minecraft

# Vérifier si server.jar existe dans /share/minecraft_manager
if [ -f "/share/minecraft_manager/server.jar" ]; then
    log "INFO" "server.jar trouvé dans /share/minecraft_manager, copie en cours..."
    cp /share/minecraft_manager/server.jar /data/minecraft/server.jar
    chmod 644 /data/minecraft/server.jar
    # Supprimer le fichier d'attente s'il existe
    rm -f /data/minecraft/.waiting_for_jar
else
    log "WARNING" "server.jar non trouvé!"
    log "INFO" "Pour installer le serveur Minecraft:"
    log "INFO" "1. Allez dans le dossier 'share' de votre Home Assistant"
    log "INFO" "2. Créez un dossier nommé 'minecraft_manager' s'il n'existe pas"
    log "INFO" "3. Téléchargez le fichier server.jar de Minecraft ${MINECRAFT_VERSION}"
    log "INFO" "4. Placez le fichier server.jar dans le dossier share/minecraft_manager"
    log "INFO" "5. Redémarrez l'addon"
    touch /data/minecraft/.waiting_for_jar
    exit 0
fi

# Créer le script de démarrage
log "INFO" "Création du script de démarrage..."
cat > /data/minecraft/start.sh << EOL
#!/bin/sh
cd /data/minecraft
exec java -Xmx${MAX_MEMORY} -Xms${MIN_MEMORY} -jar server.jar nogui
EOL

chmod +x /data/minecraft/start.sh

# Accepter l'EULA si ce n'est pas déjà fait
if [ ! -f "eula.txt" ] || ! grep -q "eula=true" "eula.txt"; then
    echo "eula=true" > eula.txt
fi

# Configuration du serveur
if [ ! -f "server.properties" ]; then
    log "INFO" "Création de la configuration du serveur..."
    cat > server.properties << EOL
server-port=25565
enable-command-block=true
spawn-protection=0
max-tick-time=60000
query.port=25565
generator-settings=
sync-chunk-writes=true
force-gamemode=false
allow-nether=true
enforce-whitelist=false
gamemode=survival
broadcast-console-to-ops=true
enable-query=false
player-idle-timeout=0
difficulty=easy
spawn-monsters=true
broadcast-rcon-to-ops=true
op-permission-level=4
pvp=true
entity-broadcast-range-percentage=100
snooper-enabled=true
level-type=default
hardcore=false
enable-status=true
enable-command-block=true
max-players=20
network-compression-threshold=256
resource-pack-sha1=
max-world-size=29999984
function-permission-level=2
rcon.port=25575
server-port=25565
debug=false
server-ip=
spawn-npcs=true
allow-flight=false
level-name=world
view-distance=10
resource-pack=
spawn-animals=true
white-list=false
rcon.password=
generate-structures=true
max-build-height=256
online-mode=true
level-seed=
prevent-proxy-connections=false
enable-rcon=false
motd=Serveur Minecraft géré par Home Assistant
EOL
fi

log "INFO" "Initialisation terminée!"
exit 0 
