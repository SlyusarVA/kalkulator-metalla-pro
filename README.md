# Калькулятор металлопроката

Flutter-приложение для расчёта веса и длины металлопроката. Ориентировано на логистику и снабжение.

## Требования

- Flutter SDK 3.x
- Android Studio (для Android) или Xcode (для iOS)

## Запуск

```bash
flutter pub get
flutter run
```

## Сборка

```bash
# Android
flutter build apk --release
# APK: build/app/outputs/flutter-apk/app-release.apk

# iOS
flutter build ipa --release
```

## Структура проекта
lib/
main.dart                 — точка входа
models/models.dart        — модели данных
data/
profiles_data.dart      — сортамент и формулы
materials_data.dart     — металлы и марки
gost_sizes.dart         — размеры по ГОСТ
logic/calculator.dart     — логика расчёта
widgets/drum_picker.dart  — компонент барабана
screens/
calc_screen.dart        — главный экран
history_screen.dart     — история расчётов
assets/icons/               — SVG иконки сортамента
## Логика расчёта

Оставь одно поле пустым — приложение рассчитает его:

- Длина + Кол-во → **Масса**
- Масса + Кол-во → **Длина**
- Масса + Длина → **Кол-во**
- Для листа: размеры + Кол-во → **Масса**, или Масса → **Кол-во**

## Управление

- Удержи кнопку сортамента → барабан выбора профиля
- Удержи кнопку металла → двойной барабан (группа + марка)
- Удержи поле размера (иконка ⚙) → барабан размеров по ГОСТ
- Удержи поле Количество → барабан 1–1000
