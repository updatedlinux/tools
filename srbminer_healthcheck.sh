#!/bin/bash

# Configuración de proxy
export HTTP_PROXY='http://10.64.10.80:3128/'
export http_proxy='http://10.64.10.80:3128/'
export HTTPS_PROXY='http://10.64.10.80:3128/'
export https_proxy='http://10.64.10.80:3128/'

# Configuración de Telegram
TELEGRAM_BOT_TOKEN="7832718953:AAFtQBYIAVNzuHpeHUsWjME5D-JPOJ5kW8Y"
TELEGRAM_CHAT_ID="-1002569751982"
HOSTNAME=$(hostname)
LOG_FILE="/root/SRBMiner-Multi-2-8-5/srbminer.log"

# Función para enviar mensaje a Telegram (modificada para usar proxy explícitamente)
send_telegram() {
    local message="$1"
    curl -s -x "$HTTP_PROXY" \
         -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
         -d chat_id="${TELEGRAM_CHAT_ID}" \
         -d text="${message}" \
         -d parse_mode="Markdown"
}

# Función para obtener las últimas líneas del log
get_last_logs() {
    if [ -f "$LOG_FILE" ]; then
        echo -e "\n📝 *Últimas líneas del log:*\n"
        tail -n 10 "$LOG_FILE" | while read -r line; do
            # Escapar caracteres especiales de Markdown
            line=$(echo "$line" | sed 's/[_*[\]()~`>#+\-=|{}.!]/\\&/g')
            echo "\`$line\`"
        done
    else
        echo -e "\n⚠️ *Archivo de log no encontrado*"
    fi
}
# Obtener timestamp actual
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# Verifica si el proceso está corriendo
if pgrep -f SRBMiner-MULTI > /dev/null; then
    # Preparar mensaje para estado operativo
    MESSAGE="🚧 *NOTIFICACIÓN DE MONITOREO DE MINERIA* ⚠️
📅 Fecha: \`${TIMESTAMP}\`
🖥️  Nodo: \`${HOSTNAME}\` Operativo
✅ Estado: Sistema operando dentro de los parámetros normales"

    # Agregar las últimas líneas del log
    LOG_CONTENT=$(get_last_logs)
    MESSAGE="${MESSAGE}${LOG_CONTENT}"

else
    # Preparar mensaje para estado no operativo
    MESSAGE="🚨 *ALERTA DE MONITOREO DE MINERIA* ⚠️
📅 Fecha: \`${TIMESTAMP}\`
🖥️  Nodo: \`${HOSTNAME}\` *NO* está minando
❌ Estado: *SRBMiner-MULTI no está corriendo*"

    # Agregar las últimas líneas del log (si existen)
    LOG_CONTENT=$(get_last_logs)
    MESSAGE="${MESSAGE}${LOG_CONTENT}"
fi

# Enviar mensaje a Telegram
send_telegram "$MESSAGE"

# Log local para debugging
echo "[$(date)] Mensaje enviado a Telegram" >> /var/log/srbminer_healthcheck.log
