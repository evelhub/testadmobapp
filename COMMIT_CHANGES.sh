#!/bin/bash

# Скрипт для коммита исправлений

echo "Добавляем изменения..."
git add Main.gd Main.tscn NEXT_STEPS.md

echo "Коммитим..."
git commit -m "Fix: Correct AdMob API usage - create AdView programmatically"

echo "Пушим в main..."
git push origin main

echo "Готово! Проверь GitHub Actions."
