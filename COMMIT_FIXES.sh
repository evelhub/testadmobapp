#!/bin/bash

echo "Коммитим исправления UI и настроек..."

git add Main.gd Main.tscn project.godot export_presets.cfg ADMOB_TROUBLESHOOTING.md
git commit -m "Fix: Portrait orientation, visible UI, internet permissions, detailed logging"
git push origin main

echo ""
echo "✅ Готово! Изменения:"
echo "  - Вертикальная ориентация"
echo "  - Видимый UI с кнопкой и статусом"
echo "  - Адаптивность под любой экран"
echo "  - Разрешения для интернета"
echo "  - Подробное логирование"
echo ""
echo "Следующие шаги:"
echo "1. Дождись сборки в GitHub Actions"
echo "2. Скачай новый IPA"
echo "3. Установи через Sideloadly"
echo "4. Проверь что UI виден"
echo "5. Проверь логи через Console.app (Mac)"
echo ""
echo "⚠️  ВАЖНО: AdMob не работает в России даже с VPN!"
echo "   Читай ADMOB_TROUBLESHOOTING.md для деталей"
