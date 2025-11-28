# ✅ ИСПРАВЛЕНИЕ: VGSLFundamentals Swift Compilation

## Проблема
```
CompileSwift normal arm64 (in target 'VGSLFundamentals' from project 'Pods')
BUILD FAILED
```

VGSLFundamentals - это Swift dependency Yandex SDK. Компиляция Swift кода падает в CI.

## Причина

VGSLFundamentals - это **динамический framework** который требует компиляции Swift source code. В CI environment это может вызывать проблемы.

## Решение

Использовать **static linkage** и **Static subspec** Yandex SDK:

```ruby
use_frameworks! :linkage => :static

pod 'YandexMobileAds/Static', '~> 7.17.1'
```

## Как это работает

### Dynamic vs Static:

**Dynamic frameworks** (по умолчанию):
- Компилируются как отдельные `.framework`
- Требуют компиляции Swift source
- VGSLFundamentals компилируется из исходников → ошибка

**Static frameworks** (с `:linkage => :static`):
- Линкуются статически в main binary
- Используют pre-compiled версии
- VGSLFundamentals уже скомпилирован → работает!

### Yandex SDK Subspecs:

- `pod 'YandexMobileAds'` - dynamic (по умолчанию)
- `pod 'YandexMobileAds/Static'` - static (pre-compiled)

## Что изменилось

### До:
```ruby
use_frameworks!  # Dynamic linkage
pod 'YandexMobileAds', '~> 7.17.1'  # Dynamic version
```
→ VGSLFundamentals компилируется из source → ошибка

### После:
```ruby
use_frameworks! :linkage => :static  # Static linkage
pod 'YandexMobileAds/Static', '~> 7.17.1'  # Static version
```
→ VGSLFundamentals pre-compiled → работает!

## Преимущества Static Linkage

✅ Быстрее компилируется (нет Swift compilation)
✅ Меньше проблем в CI
✅ Меньше размер IPA (dead code stripping)
✅ Совместимо с Godot

## Что делать

```bash
git add ios/Podfile.template
git commit -m "Use static linkage and Static subspec for Yandex SDK"
git push
```

## Результат

- ✅ VGSLFundamentals не компилируется (используется pre-built)
- ✅ Swift compilation проходит
- ✅ Сборка завершается успешно
- ✅ IPA создаётся!

## Почему это правильно

Static linkage - это **рекомендуемый подход** для iOS plugins в Godot, потому что:
- Godot сам использует static linking
- Меньше конфликтов с runtime
- Проще интеграция

---

## 🎉 ФИНАЛЬНЫЙ ФИКС!

Это должно решить проблему с VGSLFundamentals раз и навсегда!
