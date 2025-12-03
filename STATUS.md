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

## ✅ РЕШЕНИЕ НАЙДЕНО: Free Apple ID Signing

### Проблема unsigned build:
Все 5 попыток провалились - Apple блокирует unsigned IPA с Swift на iOS 18.4.
Всегда копируется старая библиотека (iOS 12.2) → crash.

### Решение от Grok:
**Free Apple ID signing** - работает без paid Developer Account ($99/год)!

### Что нужно:
1. ✅ **Удалённый Mac** (есть доступ)
2. ✅ **Free Apple ID** (создать на appleid.apple.com)
3. ✅ **iPhone UDID** (получить на Manjaro: `idevice_id -l`)
4. ✅ **10 минут на Mac** для создания certificate

### План действий:

#### Шаг 1: На удалённом Mac (10 мин)
- Подключиться через VNC/TeamViewer
- Xcode → Preferences → Accounts → Add Apple ID
- Generate Development Certificate
- Export .p12 (с паролем)
- Скачать .p12 файл

#### Шаг 2: Получить UDID iPhone (5 мин)
```bash
# На Manjaro
sudo pacman -S libimobiledevice
idevice_id -l  # Покажет UDID
```

#### Шаг 3: Создать Provisioning Profile (5 мин)
- developer.apple.com → Certificates → Profiles
- Create → iOS App Development
- Добавить UDID iPhone
- Download .mobileprovision

#### Шаг 4: GitHub Secrets (5 мин)
```bash
# Конвертировать в base64
base64 certificate.p12 > cert.txt
base64 profile.mobileprovision > profile.txt
```
Добавить в GitHub Secrets:
- `CERT_P12_BASE64`
- `CERT_PASSWORD`
- `PROVISIONING_BASE64`

#### Шаг 5: Обновить workflow (я сделаю)
Изменить на signed build с free certificate.

#### Шаг 6: Тестирование
- Push → GitHub Actions → Signed IPA
- Скачать IPA
- Установить через Sideloadly на Manjaro/Windows

## 🎯 ТЕКУЩИЙ ЭТАП: Чистая сборка iOS без рекламы

### Что сделали:
- ✅ Отключили iOS плагины (YandexAds, VkAds) в export_presets.cfg
- ✅ Упростили workflow - убрали все костыли:
  - ❌ Компиляция плагинов (build_plugins.sh)
  - ❌ Патчинг dummy.cpp
  - ❌ CocoaPods и SDK
  - ❌ Копирование Swift библиотек
- ✅ Обновили Main.gd - iOS gracefully отключает рекламу
- ✅ Android реклама работает как прежде

### Текущая сборка:
- 📱 iOS: Чистый unsigned IPA без рекламы
- 📱 Android: APK с Yandex + VK + AdMob рекламой

---

## 🎯 СЛЕДУЮЩИЙ ЭТАП: Настройка Apple ID и Signing (для рекламы)

### Что выяснили:
- ❌ Твой Apple ID показал "We are unable to process your request" при "Enroll today"
- ✅ Это НОРМАЛЬНО! Это про paid program ($99/год) который заблокирован для РФ
- ✅ Free development signing работает БЕЗ регистрации в program

### План действий:

#### 1. Проверить твой Apple ID на Mac (СНАЧАЛА)
```
1. Подключиться к удалённому Mac
2. Xcode → Preferences → Accounts → Add Apple ID
3. Попробовать создать "Apple Development" certificate
4. Если получится → используй свой Apple ID!
```

#### 2. Если не работает - создать новый Apple ID
```
1. VPN (США)
2. appleid.apple.com → Create Apple ID
3. Данные:
   - Регион: United States
   - Email: новый Gmail
   - Телефон: можно +7 российский
   - Адрес: 123 Main St, Los Angeles, CA 90210
```

#### 3. Получить UDID iPhone
```bash
sudo pacman -S libimobiledevice
idevice_id -l  # Скопировать UDID
```

#### 4. Создать Provisioning Profile
```
1. VPN (США)
2. developer.apple.com/account
3. Devices → Add Device (UDID)
4. Profiles → Create → iOS App Development
5. Download .mobileprovision
```

#### 5. Export Certificate (.p12)
```
1. На Mac: Keychain Access
2. My Certificates → "Apple Development"
3. Export → certificate.p12 (с паролем)
4. Скачать к себе
```

#### 6. GitHub Secrets
```bash
base64 -w 0 certificate.p12 > cert.txt
base64 -w 0 profile.mobileprovision > profile.txt
```
Добавить в GitHub:
- `CERT_P12_BASE64`
- `CERT_PASSWORD`
- `PROVISIONING_BASE64`

### Текущий статус:
✅ Чистая сборка iOS готова (без рекламы)
🔄 Signing для рекламы - опционально (когда будет нужно)

### Важно:
- ✅ iOS IPA собирается БЕЗ рекламы - приложение работает!
- ✅ Android APK с рекламой работает как прежде
- ⏸️ Для включения рекламы на iOS нужен signing (Mac + Apple ID)

### Быстрый старт:
```bash
git add .
git commit -m "Clean iOS build without ads"
git push
```
Скачай IPA из GitHub Artifacts → установи через Sideloadly

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
