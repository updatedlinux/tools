#!/bin/bash

# Configuración
WALLET="RC5yaCkvaxxXAJUoHstQT371qnzzo8rH8h"
POOL="stratum-na.rplant.xyz:7056"
PROXY_USER="soksproxy"
PROXY_PASS="123456p2p"
PROXY_HOST="10.68.4.104"
PROXY_PORT="1080"
PROXY="${PROXY_USER}:${PROXY_PASS}@${PROXY_HOST}:${PROXY_PORT}"

# Obtener hostname automáticamente
WORKER_NAME=$(hostname)

# Detectar CPUs disponibles
CPU_CORES=$(nproc)
THREADS=$CPU_CORES

# Mostrar información del sistema
echo "=== Información del Sistema ==="
echo "Hostname: $WORKER_NAME"
echo "CPUs disponibles: $CPU_CORES"
echo "Threads a utilizar: $THREADS"
echo "Sistema Operativo: $(grep PRETTY_NAME /etc/os-release | cut -d'=' -f2 | tr -d '\"')"
echo "Memoria Total: $(free -h | awk '/^Mem:/{print $2}')"
echo "==========================="

# Verifica si SRBMiner-MULTI existe
if [ ! -f "./SRBMiner-MULTI" ]; then
    echo "Error: SRBMiner-MULTI no encontrado en el directorio actual"
    exit 1
fi

chmod +x ./SRBMiner-MULTI

# Loop principal
while true; do
    echo "$(date): Iniciando nueva sesión de minería"

    ./SRBMiner-MULTI \
        --algorithm ghostrider \
        --pool $POOL \
        --wallet ${WALLET}.${WORKER_NAME} \
        --cpu-threads $THREADS \
        --keepalive true \
        --proxy $PROXY \
        --log-file srbminer.log \
        --disable-gpu \
        --randomx-use-tweaks 1 \
        --randomx-use-hugepages \
        --cpu-priority 4 \
        --background=false

    echo "$(date): El minero se detuvo. Reiniciando en 5 segundos..."
    sleep 5
done
