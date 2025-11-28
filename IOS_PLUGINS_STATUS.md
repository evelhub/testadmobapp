# iOS Plugins Status

## Current Status: 🔨 Compiling in GitHub Actions

## Solution

**Problem:** Godot 4.4.1 doesn't compile `.mm` files. Needs `.xcframework`.

**Solution:** 
1. Use forward declarations (no SDK import during compilation)
2. Compile in GitHub Actions with `ios/build_plugins.sh`
3. Real SDK links at runtime via `.gdip`

## Key Technical Detail

```objc
// Instead of: #import <YandexMobileAds/YandexMobileAds.h>
// Use forward declarations:
@class YMABannerView;
@interface YMAMobileAds : NSObject
+ (void)initializeSDKWithCompletionHandler:(void (^)(void))completionHandler;
@end
```

## Check Logs on Device (3uTools)

Keywords:
- `YANDEX-PLUGIN` - plugin logs
- `YANDEX-C-BRIDGE` - init calls
- `YMA` - SDK logs

Expected:
```
🟡 [YANDEX-C-BRIDGE] yandex_ads_init() called
✅ [YANDEX-PLUGIN] SDK initialized successfully
```

## References

- [Grok analysis](Z1-grok-answer.txt)
- [Build script](ios/build_plugins.sh)
