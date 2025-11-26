# Инструкция по настройке Git и GitHub

## 1. Инициализация локального репозитория

```bash
git init
git add .
git commit -m "Initial commit: TestAdMobApp with AdMob integration"
```

## 2. Создание репозитория на GitHub

1. Перейти на https://github.com/new
2. Создать новый репозиторий (например, `testadmobapp`)
3. НЕ добавлять README, .gitignore или лицензию (они уже есть)

## 3. Подключение к GitHub

```bash
git remote add origin https://github.com/YOUR_USERNAME/testadmobapp.git
git branch -M main
git push -u origin main
```

Замени `YOUR_USERNAME` на свой GitHub username.

## 4. Запуск GitHub Actions

После push в `main` ветку:
1. Перейти в репозиторий на GitHub
2. Открыть вкладку "Actions"
3. Дождаться завершения workflow "Build Unsigned iOS IPA"
4. Скачать артефакт `ios-ipa` (содержит TestAdMobApp.ipa)

## 5. Установка на iPhone через Sideloadly

1. Скачать и установить Sideloadly: https://sideloadly.io/
2. Подключить iPhone к компьютеру
3. Открыть Sideloadly
4. Перетащить TestAdMobApp.ipa в окно программы
5. Ввести Apple ID
6. Нажать "Start"
7. Доверять сертификату на iPhone: Settings > General > VPN & Device Management

## Примечания

- Для отображения рекламы может потребоваться VPN (Spain)
- В России реклама может не работать
- Используются тестовые ID от Google AdMob
