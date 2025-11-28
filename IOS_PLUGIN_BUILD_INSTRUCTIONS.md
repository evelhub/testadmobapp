# Инструкция по компиляции iOS плагинов для Godot

## Проблема
Godot 4.4.1 НЕ компилирует `.mm` файлы автоматически. Нужны готовые `.xcframework` библиотеки.

## Решение
Скомпилировать плагины локально на Mac и закоммитить `.xcframework` в репозиторий.

## Требования
- macOS с установленным Xcode 14+
- Command Line Tools: `xcode-select --install`

## Шаги

### 1. Установка зависимостей (если ещё не сделано)

Yandex Mobile Ads SDK уже должен быть установлен через CocoaPods. Если нет:

```bash
cd ios
pod install
```

### 2. Компиляция плагинов

Запусти скрипт компиляции:

```bash
cd ios
./build_plugins.sh
```

Скрипт создаст:
- `ios/plugins/yandex_ads/yandex_ads.xcframework`
- `ios/plugins/vk_ads/vk_ads.xcframework` (если есть)

### 3. Проверка результата

Убедись что `.xcframework` созданы:

```bash
ls -la ios/plugins/yandex_ads/yandex_ads.xcframework
ls -la ios/plugins/vk_ads/vk_ads.xcframework
```

Должны быть папки с такой структурой:
```
yandex_ads.xcframework/
├── Info.plist
├── ios-arm64/
│   └── libyandex_ads.a
└── ios-arm64_x86_64-simulator/
    └── libyandex_ads.a
```

### 4. Коммит в репозиторий

```bash
git add ios/plugins/*/*.xcframework
git commit -m "Add compiled iOS plugin frameworks"
git push
```

### 5. Тестирование

После коммита GitHub Actions пересоберёт IPA с новыми плагинами.

Установи IPA на устройство и проверь логи в 3uTools:
- Keyword: `YANDEX-PLUGIN` - должны появиться логи инициализации
- Keyword: `YMA` - логи Yandex Mobile Ads SDK

## Что изменилось

### До (не работало):
```
[config]
binary="yandex_ads.mm"  ❌ Исходный код, Godot не компилирует
```

### После (работает):
```
[config]
binary="yandex_ads.xcframework"  ✅ Готовая библиотека
```

## Альтернативный способ (если нет Mac)

Можно использовать GitHub Actions с macOS runner для компиляции:

1. Добавь шаг в `.github/workflows/build-ios.yml`:
```yaml
- name: Build iOS plugins
  run: |
    cd ios
    ./build_plugins.sh
```

2. Закоммить `.xcframework` после первой успешной сборки

## Troubleshooting

### Ошибка: "xcrun: error: SDK "iphoneos" cannot be located"
Установи Command Line Tools:
```bash
xcode-select --install
sudo xcode-select --switch /Applications/Xcode.app
```

### Ошибка: "YandexMobileAds/YandexMobileAds.h not found"
Установи CocoaPods зависимости:
```bash
cd ios
pod install
```

Затем добавь путь к фреймворкам в скрипт компиляции:
```bash
-F"$PWD/Pods/YandexMobileAds"
```

### Плагин не инициализируется
Проверь логи на устройстве:
```
# В 3uTools ищи:
YANDEX-C-BRIDGE  # Должно быть "yandex_ads_init() called"
YANDEX-PLUGIN    # Должно быть "Initializing Yandex Mobile Ads SDK"
```

Если логов нет - плагин не загружен. Проверь:
1. `.xcframework` существует в `ios/plugins/yandex_ads/`
2. В `export_presets.cfg`: `plugins/YandexAds=true`
3. Имя в `.gdip` совпадает: `name="YandexAds"`

## Следующие шаги

После успешной компиляции:
1. Пересобрать IPA через GitHub Actions
2. Установить на устройство
3. Проверить логи - должны появиться сообщения от SDK
4. Протестировать показ тестовой рекламы

## Ссылки

- [Godot iOS plugins documentation](https://docs.godotengine.org/en/stable/tutorials/platform/ios/ios_plugin.html)
- [Yandex Mobile Ads iOS SDK](https://yandex.ru/dev/mobile-ads/doc/ios/quick-start.html)
- [Grok answer with detailed explanation](Z1-grok-answer.txt)
