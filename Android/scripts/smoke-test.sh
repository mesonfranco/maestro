maestro test Android/Flows/smoke-flow/ --device 29211FDH2006X3 --config "Android/configs/config-order-smoke-flows.yaml" --format html-detailed --output Android/reports/smoke-test-report.html
# 2. Extraemos la versión y build de la app instalada en el dispositivo
APP_PACKAGE="com.vblast.flipaclip"
APP_VERSION=$(adb -s 29211FDH2006X3 shell dumpsys package $APP_PACKAGE | grep versionName | head -n 1 | cut -d= -f2)
APP_BUILD=$(adb -s 29211FDH2006X3 shell dumpsys package $APP_PACKAGE | grep versionCode | head -n 1 | cut -d= -f2 | tr -d ' ')

# 3. Apuntamos al archivo correcto (smoke-test-report.html)
REPORT_PATH="Android/reports/smoke-test-report.html"

if [ -f "$REPORT_PATH" ]; then
  # Inyectamos la información debajo del título principal
  sed -i '' "s|<h1 class=\"mt-5 text-center\">Flow Execution Summary</h1>|<h1 class=\"mt-5 text-center\">Flow Execution Summary</h1><p class=\"text-center text-muted\">Versión: $APP_VERSION (Build: $APP_BUILD)</p>|g" "$REPORT_PATH"
  echo "✅ Reporte actualizado con la versión: $APP_VERSION ($APP_BUILD)"
else
  echo "⚠️ No se encontró el archivo de reporte en $REPORT_PATH"
fi