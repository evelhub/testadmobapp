# ✅ ИСПРАВЛЕНИЕ: Linking Issues

## Проблема 1: Swift 6 Compatibility
```
CompileSwift normal arm64 (in target 'VGSLFundamentals' from project 'Pods')
** BUILD FAILED **
```
`VGSLFundamentals` требует Swift 6, недоступен в Xcode 15.4.

**Решение:** Использовать Yandex Mobile Ads 7.5.0 (Swift 5).

## Проблема 2: Undefined Symbols
```
Undefined symbols for architecture arm64:
  "_OBJC_CLASS_$_YMABannerView", referenced from:
       in libyandex_ads_device.a[2](yandex_ads_device.o)
  "yandex_ads_init()", referenced from:
      godot_ios_plugins_initialize() in dummy.o
   NOTE: declaration possibly missing 'extern "C"'
```

**Причина:** 
- `yandex_ads.mm` импортировал `<YandexMobileAds/YandexMobileAds.h>` при компиляции плагина
- SDK недоступен на этапе компиляции `.xcframework`
- Линкер не может найти символы при финальной сборке

**Решение:** Использовать forward declarations вместо прямого импорта SDK.

## Изменения

### 1. ios/Podfile.template
```ruby
# Версия SDK
pod 'YandexMobileAds', '7.5.0'  # Было: '~> 7.17.1'

# Добавлен post_install hook для линковки frameworks
post_install do |installer|
  # ... existing code ...
  
  # Add Yandex frameworks to main app target
  installer.aggregate_targets.each do |aggregate_target|
    aggregate_target.user_project.targets.each do |target|
      if target.name == 'PROJECT_NAME_PLACEHOLDER'
        target.build_configurations.each do |config|
          config.build_settings['OTHER_LDFLAGS'] ||= ['$(inherited)']
          config.build_settings['OTHER_LDFLAGS'] << '-framework YandexMobileAds'
          # ... other frameworks
        end
      end
    end
  end
end
```

### 2. ios/plugins/yandex_ads/yandex_ads.mm
```objc
// Было:
#import <YandexMobileAds/YandexMobileAds.h>

// Стало:
@class YMABannerView;
@class YMARewardedAd;
@interface YMAMobileAds : NSObject
+ (void)initializeSDKWithCompletionHandler:(void (^)(void))completionHandler;
@end
// ... и т.д.
```

### 3. ios/build_plugins.sh
```bash
# Было:
build_plugin "yandex_ads" "YandexAdsPlugin.mm"

# Стало:
build_plugin "yandex_ads" "yandex_ads.mm"
```

## Как это работает

### Компиляция плагина (build_plugins.sh):
1. Forward declarations позволяют компилировать без SDK
2. Создаётся `yandex_ads.xcframework` с символами
3. Символы помечены как `extern "C"` для C linkage

### Финальная сборка (xcodebuild):
1. CocoaPods добавляет YandexMobileAds framework
2. Линкер находит реальные классы SDK
3. Forward declarations заменяются на реальные классы
4. Всё линкуется успешно

## Следующие шаги
```bash
git add .
git commit -m "fix: use forward declarations and Yandex SDK 7.5.0

- Use forward declarations instead of importing SDK during plugin compilation
- Downgrade to Yandex Mobile Ads 7.5.0 for Swift 5 compatibility
- Fixes undefined symbols and Swift 6 compilation errors"
git push
```

## Ожидаемый результат
✅ Плагин скомпилируется в .xcframework
✅ CocoaPods установит SDK 7.5.0
✅ Линкер найдёт все символы
✅ IPA соберётся успешно
✅ Реклама Yandex будет работать
