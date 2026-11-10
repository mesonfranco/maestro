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
maestro --device "$DEVICE_ID" test --config "iOS/configs/config-order-new-fc-tools-flows.yaml" \
  --format html-detailed \
  --output "iOS/reports/new-fc-tools-test.html"  \
  iOS/Flows/new-fc-tools/

echo "📊 ¡Pruebas terminadas! Extrayendo versión real de la app..."

APP_BUNDLE_ID="com.vblast.flipaclip"

# 🍎 Buscamos directamente el Info.plist dentro del paquete .app ejecutable de la app instalada
APP_PATH=$(xcrun simctl get_app_container "$DEVICE_ID" "$APP_BUNDLE_ID" 2>/dev/null)

if [ -n "$APP_PATH" ]; then
  # Buscamos el archivo Info.plist dentro de la estructura de la aplicación compilada
  PLIST_PATH=$(find "$APP_PATH" -path "*/*.app/Info.plist" | head -n 1)
  
  if [ -f "$PLIST_PATH" ]; then
    APP_VERSION=$(python3 -c "import plistlib; p=plistlib.load(open('$PLIST_PATH', 'rb')); print(p.get('CFBundleShortVersionString', 'N/A'))")
    APP_BUILD=$(python3 -c "import plistlib; p=plistlib.load(open('$PLIST_PATH', 'rb')); print(p.get('CFBundleVersion', 'N/A'))")
  else
    APP_VERSION="N/A"
    APP_BUILD="N/A"
  fi
else
  APP_VERSION="N/A"
  APP_BUILD="N/A"
fi

# 3. Inyectamos la información correcta en el reporte HTML
REPORT_PATH="iOS/reports/new-fc-tools-test.html"

if [ -f "$REPORT_PATH" ]; then
  sed -i '' "s|<h1 class=\"mt-5 text-center\">Flow Execution Summary</h1>|<h1 class=\"mt-5 text-center\">Flow Execution Summary</h1><p class=\"text-center text-muted\">Versión iOS: $APP_VERSION (Build: $APP_BUILD)</p>|g" "$REPORT_PATH"
  echo "✅ Reporte de iOS actualizado con la versión correcta: $APP_VERSION ($APP_BUILD)"
else
  echo "⚠️ No se encontró el archivo de reporte en $REPORT_PATH"
fi
