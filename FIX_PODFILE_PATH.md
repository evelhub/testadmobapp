# ✅ ИСПРАВЛЕНИЕ: Путь к Podfile.template

## Проблема
```
cp: ../../ios/Podfile.template: No such file or directory
```

Относительный путь `../../ios/` не работает, потому что мы находимся в `build/` директории.

## Решение
Использовать **абсолютный путь** через `$GITHUB_WORKSPACE`:

```bash
WORKSPACE_ROOT="${GITHUB_WORKSPACE}"
cp "$WORKSPACE_ROOT/ios/Podfile.template" ./Podfile
```

## Как это работает

### Структура в GitHub Actions:
```
$GITHUB_WORKSPACE/              # /Users/runner/work/testadmobapp/testadmobapp
├── ios/
│   └── Podfile.template        # Наш файл
└── build/                      # $XCODE_PROJECT_DIR
    └── ios_xcode.xcodeproj
```

### Старый путь (не работал):
```bash
cd build/
cp ../../ios/Podfile.template ./Podfile  # ❌ Неправильно
```

### Новый путь (работает):
```bash
cd build/
cp $GITHUB_WORKSPACE/ios/Podfile.template ./Podfile  # ✅ Правильно
```

## Что изменилось

Добавлена проверка существования файла:
```bash
if [ ! -f "$WORKSPACE_ROOT/ios/Podfile.template" ]; then
  echo "❌ Podfile.template not found"
  ls -la "$WORKSPACE_ROOT/ios/"
  exit 1
fi
```

Это поможет быстро найти проблему если файл не закоммичен.

## Что делать

```bash
git add .github/workflows/build-ios.yml
git commit -m "Fix Podfile.template path using GITHUB_WORKSPACE"
git push
```

## Результат

- ✅ Podfile.template найдётся
- ✅ Скопируется в build директорию
- ✅ CocoaPods установит зависимости
- ✅ Сборка продолжится!

---

## 🚀 ГОТОВО К ПУШУ!

Простая ошибка с путём, легко исправляется.
