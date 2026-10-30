#!/bin/bash

echo "🧼 Forzando limpieza de conexiones colgadas de iOS..."
killall maestro idb 2>/dev/null
xcrun simctl launch booted com.apple.CoreSimulator.Bridge 2>/dev/null

echo "📱 Detectando tu iPhone activo..."
DEVICE_ID=$(xcrun simctl list devices booted | grep -E -o '[A-Z0-9]{8}-([A-Z0-9]{4}-){3}[A-Z0-9]{12}' | head -n 1)

if [ -z "$DEVICE_ID" ]; then
    echo "❌ Error: No se detectó ningún iPhone abierto."
    exit 1
fi

# 🕒 TRUCO: Creamos una variable con la fecha y hora actual (Ej: 2026-07-08_15-45)
FECHA_ACTUAL=$(date +"%Y-%m-%d_%H-%M")

echo "🚀 Iniciando la suite de pruebas en el dispositivo: $DEVICE_ID"

# 📊 EJECUCIÓN DETALLADA:
# Apuntamos a la CARPETA 'iOS/smoke' (sin el archivo .yaml al final) para que tome todos los tests por separado.
# Guardamos el reporte incluyendo la fecha en el nombre para tener un histórico.
maestro --device "$DEVICE_ID" test --config "iOS/configs/config-order-new-fc-tools-flows.yaml.yaml" \
  --format html-detailed \
  --output "iOS/reports/new-fc-tools-test.html"  \
  iOS/Flows/new-fc-tools/

echo "📊 ¡Pruebas terminadas! Abriendo el último reporte..."
