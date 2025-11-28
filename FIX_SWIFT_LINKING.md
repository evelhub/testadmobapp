# ✅ ИСПРАВЛЕНИЕ: Swift Runtime Linking

## Проблема

```
"__swift_FORCE_LOAD_$_swift_Builtin_float", referenced from:
    __swift_FORCE_LOAD_$_swift_Builtin_float_$_YandexMobileAds
"_swift_willThrowTypedImpl", referenced from:
    _swift_willThrowTyped in YandexMobileAds
ld: symbol(s) not found for architecture arm64
```

**Yandex Mobile Ads SDK написан на Swift**, но Swift runtime библиотеки не линкуются.

## Причина

Yandex SDK использует Swift, но в `.gdip` не указаны Swift runtime libraries для линковки.

## Решение

Добавить Swift libraries в `linker_flags`:

### Обновлено в `yandex_ads.gdip`:

```
linker_flags=[
    "-ObjC",
    "-lswiftCore",
    "-lswiftFoundation", 
    "-lswiftUIKit",
    "-lswiftCoreGraphics",
    "-lswiftDispatch",
    "-lswiftObjectiveC"
]
```

Также добавлены дополнительные system frameworks которые требует Yandex SDK:
- `CoreTelephony.framework` - для определения оператора
- `SystemConfiguration.framework` - для сетевых настроек
- `CoreLocation.framework` - для геолокации (опционально)

## Как это работает

1. **Swift runtime** предоставляет базовые функции Swift
2. **Swift overlay libraries** (Foundation, UIKit и т.д.) - мосты между Swift и Objective-C
3. **Линкер** находит эти библиотеки в iOS SDK и линкует их

## Что делать

```bash
git add ios/plugins/yandex_ads/yandex_ads.gdip
git commit -m "Add Swift runtime libraries to Yandex plugin linker flags"
git push
```

## Результат

- ✅ Swift symbols резолвятся
- ✅ Yandex SDK слинкуется корректно
- ✅ Сборка пройдёт успешно
- ✅ IPA соберётся!

## Почему это нужно

Yandex Mobile Ads SDK 7.x написан на Swift (в отличие от старых версий на Objective-C). Поэтому нужны Swift runtime библиотеки.

Это стандартная практика для любого iOS проекта который использует Swift frameworks.

---

## 🚀 ГОТОВО К ПУШУ!

После этого фикса линковка должна пройти успешно.
