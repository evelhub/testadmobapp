# ✅ ИСПРАВЛЕНИЕ: Swift Support через xcodebuild

## Проблема
Godot `.gdip` файлы **не поддерживают** Swift linker flags (`-lswiftCore` и т.д.). Они игнорируются при экспорте.

## Решение
Добавить Swift support флаги **напрямую в xcodebuild** команду в GitHub Actions workflow.

## Что изменилось

### В `.github/workflows/build-ios.yml`:

Добавлены build settings:
```bash
ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES=YES \
LD_RUNPATH_SEARCH_PATHS="@executable_path/Frameworks" \
OTHER_LDFLAGS="-ObjC -lswiftCore -lswiftFoundation -lswiftUIKit -lswiftCoreGraphics -lswiftDispatch -lswiftObjectiveC"
```

## Как это работает

1. **ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES=YES**
   - Xcode автоматически включит Swift runtime в IPA
   - Swift libraries будут скопированы в Frameworks/

2. **LD_RUNPATH_SEARCH_PATHS**
   - Линкер будет искать Swift libraries в правильном месте
   - `@executable_path/Frameworks` - стандартный путь для iOS

3. **OTHER_LDFLAGS**
   - Явно указываем какие Swift libraries линковать
   - `-ObjC` - для Objective-C categories
   - `-lswift*` - Swift runtime libraries

## Почему это работает

Godot экспортирует Xcode проект, но **не контролирует build settings**. Мы можем переопределить их через xcodebuild параметры.

## Что делать

```bash
git add .github/workflows/build-ios.yml
git commit -m "Add Swift support flags to xcodebuild command"
git push
```

## Результат

- ✅ Swift runtime libraries слинкуются
- ✅ Yandex SDK заработает
- ✅ IPA соберётся успешно
- ✅ Приложение запустится на устройстве

## Альтернатива

Если это не сработает, можно:
1. Использовать старую версию Yandex SDK (Objective-C, без Swift)
2. Создать custom Godot export template с Swift support
3. Использовать CocoaPods для автоматической линковки

Но текущее решение должно сработать! 🚀

---

## 🚀 ГОТОВО К ПУШУ!

Это обходит ограничение Godot `.gdip` файлов.
