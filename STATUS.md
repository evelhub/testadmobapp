# 📊 Текущий статус проекта iOS сборки

**Дата обновления:** 28 ноября 2024, 18:20

## 🎯 Цель
Собрать iOS IPA с интеграцией Yandex Mobile Ads SDK через GitHub Actions.

## ✅ Что работает
- ✅ Android APK собирается успешно (Yandex + VK + AdMob)
- ✅ Godot 4.4.1 экспортирует iOS проект
- ✅ CocoaPods устанавливает Yandex Mobile Ads SDK 7.5.0
- ✅ iOS плагин компилируется в .xcframework
- ✅ Workspace создаётся через CocoaPods

## ❌ Текущая проблема
**Ошибка линковки на финальной стадии Build IPA:**

```
Undefined symbols for architecture arm64:
  "yandex_ads_init()", referenced from:
      godot_ios_plugins_initialize() in dummy.o
   NOTE: found '_yandex_ads_init' in libyandex_ads_device.a[2](yandex_ads_device.o), 
   declaration possibly missing 'extern "C"'
```

**Суть проблемы:**
- Godot генерирует `dummy.cpp` который вызывает `yandex_ads_init()` как C++ функцию
- Наш плагин экспортирует её как C функцию (`extern "C"`)
- Линкер находит `_yandex_ads_init` (C symbol), но ищет C++ mangled symbol

## 📁 Структура проекта

### iOS плагин
```
ios/plugins/yandex_ads/
├── yandex_ads.mm          # C bridge с extern "C" и forward declarations
├── yandex_ads.gdip        # Godot plugin descriptor
├── yandex_ads.xcframework # Скомпилированный плагин (создаётся в CI)
└── YandexAdsPlugin.mm     # Старый файл (не используется)
```

### Конфигурация
- `ios/Podfile.template` - CocoaPods зависимости (Yandex SDK 7.5.0)
- `ios/build_plugins.sh` - Скрипт компиляции плагина
- `.github/workflows/build-ios.yml` - CI/CD pipeline

## 🔧 Текущий подход

### 1. Компиляция плагина (build_plugins.sh)
```bash
# Компилируем yandex_ads.mm с forward declarations
xcrun clang++ -x objective-c++ -arch arm64 \
    -c yandex_ads.mm -o yandex_ads_device.o
ar rcs libyandex_ads_device.a yandex_ads_device.o
xcodebuild -create-xcframework \
    -library libyandex_ads_device.a \
    -output yandex_ads.xcframework
```

### 2. Godot экспорт
- Godot экспортирует iOS Xcode проект
- Создаёт `dummy.cpp` с вызовами плагина
- Копирует .xcframework в проект

### 3. CocoaPods
- Устанавливает Yandex Mobile Ads SDK 7.5.0
- Создаёт workspace
- Добавляет linker flags через post_install hook

### 4. Финальная сборка
- xcodebuild собирает через workspace
- **ПАДАЕТ на линковке** - не находит символы

## 🤔 Возможные решения

### Вариант A: Исправить extern "C" (текущий)
- Использовать header файл для правильных объявлений
- Заставить Godot генерировать правильный dummy.cpp

### Вариант B: Отказаться от .xcframework
- Добавить Yandex SDK напрямую через CocoaPods
- Использовать Godot iOS plugin без компиляции
- Линковать всё на этапе финальной сборки

### Вариант C: Использовать динамическую линковку
- Загружать плагин через dlopen/dlsym
- Обходить проблему с extern "C"

## 📝 История попыток

1. ❌ Импорт SDK в плагине → SDK недоступен при компиляции
2. ✅ Forward declarations → плагин компилируется
3. ❌ SDK 7.17.1 → требует Swift 6
4. ✅ SDK 7.5.0 → совместим со Swift 5
5. ❌ Линковка frameworks → символы не находятся
6. ❌ post_install hook → всё равно не линкуется
7. ❌ Текущая проблема → extern "C" vs C++ linkage

## 🔧 Решение от Grok: Добавить --minimum-deployment-target

### Проблема найдена:
`swift-stdlib-tool` копировал из `swift-5.0/iphoneos` (iOS 12.2) потому что не указан `--minimum-deployment-target`.

### Решение от Grok:
Добавить параметры в `swift-stdlib-tool`:
- `--toolchain` - явно указать toolchain
- `--minimum-deployment-target 17.0` - копировать для iOS 17+

Это заставит инструмент копировать правильные версии Swift libraries.

### Альтернатива (если не сработает):
**Signed IPA** с development certificate в GitHub Actions - Grok дал полную инструкцию.

### Что сделано:
1. ✅ Добавлен `--minimum-deployment-target 17.0` в swift-stdlib-tool
2. ✅ Добавлен `--toolchain` параметр

### Следующий шаг:
Коммит и тест. Если не сработает - переходим на signed IPA.

## 📂 Файлы документации

- `STATUS.md` - этот файл (текущий статус)
- `Z1-grok-answer.txt` - предыдущий ответ от Grok
- `Z2-workflow-logs.txt` - логи ошибки из GitHub Actions
- `Z3-grok-question.txt` - текущий вопрос для Grok
- `README.md` - общее описание проекта
- `PROJECT_ROADMAP.md` - план разработки

## 🔗 Полезные ссылки

- [Godot iOS plugins docs](https://docs.godotengine.org/en/stable/tutorials/platform/ios/ios_plugin.html)
- [Yandex Mobile Ads iOS](https://yandex.ru/dev/mobile-ads/doc/ios/quick-start.html)
- [CocoaPods](https://cocoapods.org/)
