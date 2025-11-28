# ВОПРОС ДЛЯ GROK: Yandex Mobile Ads SDK версии

## Проблема
Yandex Mobile Ads SDK 7.x написан на Swift и требует Swift runtime libraries для линковки. Godot 4.4.1 iOS plugins не поддерживают автоматическую линковку Swift libraries через `.gdip` файлы.

## Ошибка линковки
```
"__swift_FORCE_LOAD_$_swift_errno", referenced from:
    __swift_FORCE_LOAD_$_swift_errno_$_YandexMobileAds
"_kAMADeviceIDKey", referenced from:
    MACAnalytics.MACMetricaRawIdentifiersLoader
ld: symbol(s) not found for architecture arm64
```

## Вопросы

1. **Какие версии Yandex Mobile Ads SDK написаны на Objective-C** (без Swift)?
   - Нужна версия которая НЕ требует Swift runtime
   - Желательно последняя стабильная Objective-C версия

2. **Где скачать старую версию SDK?**
   - Прямая ссылка на XCFramework
   - Или CocoaPods версия

3. **Совместимость API**:
   - Изменился ли API между Objective-C и Swift версиями?
   - Нужно ли менять код плагина?

4. **Альтернативные решения**:
   - Можно ли заставить Godot линковать Swift libraries?
   - Есть ли способ добавить Swift support в Godot iOS export?

## Текущая конфигурация

Используем Yandex Mobile Ads 7.17.1 (Swift):
```
https://ads-mobile-sdk.s3.yandex.net/Yandex/YandexMobileAds/7.17.1/spm/...
```

Нужна версия 5.x или 6.x (Objective-C)?

## Контекст
- Godot 4.4.1
- iOS 13.0+
- GitHub Actions macOS runner
- Unsigned IPA build
- Плагин компилируется успешно, но линковка падает

Пожалуйста, дай:
- Конкретную версию SDK на Objective-C
- Прямую ссылку для скачивания
- Информацию об изменениях API (если есть)
