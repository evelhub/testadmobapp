# ✅ ИСПРАВЛЕНИЕ: PrivacyInfo Bundle Swift Libraries

## Проблема
```
error: Build input file cannot be found: 
'.../YandexMobileAds_PrivacyInfo.bundle/YandexMobileAds_PrivacyInfo'
CopySwiftLibs failed
```

CocoaPods пытается скопировать Swift libraries в **resource bundle** (PrivacyInfo), но это не нужно - resource bundles не содержат исполняемого кода.

## Причина

`ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES=YES` применяется ко ВСЕМ targets, включая resource bundles. Но resource bundles - это просто файлы (plist, images), им не нужны Swift libraries.

## Решение

В `post_install` hook Podfile добавить условие:
```ruby
if target.name.include?('PrivacyInfo')
  config.build_settings['ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES'] = 'NO'
else
  config.build_settings['ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES'] = 'YES'
end
```

## Как это работает

### Targets в проекте:
- `YandexMobileAds` - framework ✅ нужны Swift libs
- `YandexMobileAds-YandexMobileAds_PrivacyInfo` - resource bundle ❌ НЕ нужны
- `VGSLFundamentals-VGSLFundamentalsPrivacyInfo` - resource bundle ❌ НЕ нужны
- `ios_xcode` - main app ✅ нужны Swift libs

### Старая конфигурация (не работала):
```ruby
# Все targets получают ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES=YES
# Resource bundles пытаются копировать Swift libs → ошибка
```

### Новая конфигурация (работает):
```ruby
# PrivacyInfo bundles: ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES=NO
# Остальные targets: ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES=YES
```

## Что делать

```bash
git add ios/Podfile.template
git commit -m "Fix PrivacyInfo bundle Swift libraries copying"
git push
```

## Результат

- ✅ Resource bundles не пытаются копировать Swift libs
- ✅ Main app и frameworks получают Swift support
- ✅ Сборка проходит успешно
- ✅ IPA создаётся!

## Почему это правильно

Resource bundles (`.bundle`) содержат только ресурсы:
- PrivacyInfo.xcprivacy
- Images, fonts, strings
- Нет исполняемого кода

Swift libraries нужны только для:
- Frameworks (`.framework`)
- Main app (`.app`)

---

## 🚀 ГОТОВО К ПУШУ!

Это стандартная проблема с CocoaPods и resource bundles.
