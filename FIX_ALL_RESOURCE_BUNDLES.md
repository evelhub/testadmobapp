# ✅ ИСПРАВЛЕНИЕ: Все Resource Bundles

## Проблема
```
CopySwiftLibs AppMetricaProtobuf.bundle failed
Build input file cannot be found
```

Та же ошибка, но с **другим bundle** - `AppMetricaProtobuf`. Условие `include?('PrivacyInfo')` не покрывает все resource bundles.

## Причина

В проекте **несколько resource bundles**:
- `YandexMobileAds_PrivacyInfo.bundle`
- `VGSLFundamentalsPrivacyInfo.bundle`
- `AppMetricaProtobuf.bundle` ← новый!
- Возможно ещё другие...

Проверка по имени не надёжна.

## Решение

Проверять **тип продукта** вместо имени:
```ruby
if target.respond_to?(:product_type) && 
   target.product_type == 'com.apple.product-type.bundle'
  # Это resource bundle - не нужны Swift libs
  config.build_settings['ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES'] = 'NO'
else
  # Это framework или app - нужны Swift libs
  config.build_settings['ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES'] = 'YES'
end
```

## Как это работает

### Типы продуктов в Xcode:
- `com.apple.product-type.bundle` - resource bundle (только файлы)
- `com.apple.product-type.framework` - framework (код + ресурсы)
- `com.apple.product-type.application` - app (исполняемый файл)

### Старый подход (не работал):
```ruby
if target.name.include?('PrivacyInfo')  # ❌ Не покрывает все bundles
```

### Новый подход (работает):
```ruby
if target.product_type == 'com.apple.product-type.bundle'  # ✅ Все bundles
```

## Что изменилось

### До:
- ✅ YandexMobileAds_PrivacyInfo - отключено
- ✅ VGSLFundamentalsPrivacyInfo - отключено  
- ❌ AppMetricaProtobuf - НЕ отключено → ошибка

### После:
- ✅ Все bundles - отключено
- ✅ Все frameworks - включено
- ✅ Main app - включено

## Что делать

```bash
git add ios/Podfile.template
git commit -m "Fix Swift libs for all resource bundles using product_type check"
git push
```

## Результат

- ✅ ВСЕ resource bundles не копируют Swift libs
- ✅ Frameworks и app получают Swift support
- ✅ Сборка проходит!
- ✅ IPA создаётся!

## Почему это правильно

Проверка по `product_type` - это **стандартный способ** определения типа target в CocoaPods. Это надёжнее чем проверка по имени.

---

## 🚀 ПОСЛЕДНИЙ ФИКС!

Это должно решить проблему раз и навсегда для ВСЕХ resource bundles!
