ARG BUILD_FROM
FROM $BUILD_FROM

# Installation des dépendances
RUN apk add --no-cache \
    nginx \
    openjdk21-jre \
    python3 \
    py3-pip \
    dos2unix \
    gcc \
    musl-dev \
    python3-dev \
    linux-headers \
    py3-psutil

# Copie des fichiers
COPY rootfs /

# Conversion des fins de ligne
RUN find /etc/services.d -type f -exec dos2unix {} \; && \
    find /etc/cont-init.d -type f -exec dos2unix {} \; && \
    find /usr/bin -type f -exec dos2unix {} \;

# Permissions
RUN chmod +x /usr/bin/minecraft_api.py && \
    find /etc/services.d -type f -name run -exec chmod +x {} + || true && \
    find /etc/cont-init.d -type f -exec chmod +x {} + || true

# Ports
EXPOSE 8099 25565

# Labels
LABEL \
    io.hass.name="Minecraft Manager" \
    io.hass.description="Gestionnaire de serveur Minecraft pour Home Assistant" \
    io.hass.type="addon" \
    io.hass.version="1.0.0"

# Point d'entrée S6
ENTRYPOINT ["/init"] 