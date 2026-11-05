#!/bin/bash

echo "🚀 Starting all the flows"

# 1. Ejecuta el primer script
echo "▶️ Smoke test running"
./iOS/scripts/smoke-test.sh

# 2. Ejecuta el segundo script
echo "▶️ New FC tools test running"
./iOS/scripts/new-fc-tools-test.sh

# 3. Ejecuta el tercer script
echo "▶️ Legacy tools test running"
./iOS/scripts/legacy-tools-test.sh

echo "✅ All flows ran successfully. Check the reports in iOS/reports/ for details."