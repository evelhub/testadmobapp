# TestAdMobApp

Тестовое приложение для проверки AdMob баннеров и rewarded рекламы на iOS.

## Возможности

- Баннеры сверху и снизу экрана (adaptive full width)
- Rewarded видео реклама по кнопке WATCH
- Использует тестовые ID от Google AdMob
- Автоматическая сборка unsigned IPA через GitHub Actions

## Сборка

### Локально (требуется macOS)

1. Открыть проект в Godot 4.4.1
2. Project > Export > iOS
3. Export Project

### Через GitHub Actions

1. Push в ветку `main`
2. Перейти в Actions
3. Скачать артефакт `ios-ipa`

## Установка на iPhone

1. Скачать `TestAdMobApp.ipa` из GitHub Actions
2. Использовать Sideloadly для установки unsigned IPA
3. Запустить приложение

## Отображение рекламы

- В России реклама может не отображаться
- Рекомендуется использовать VPN (Spain) для тестирования
- Используются тестовые ID, поэтому реклама должна работать в тестовом режиме

## Технические детали

- Godot Engine 4.4.1
- AdMob Plugin (Poing v3.1.1+)
- CocoaPods для iOS зависимостей
- Test Banner ID: `ca-app-pub-3940256099942544/2934735716`
- Test Rewarded ID: `ca-app-pub-3940256099942544/1712485313`
