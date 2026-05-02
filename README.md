# Калькулятор металлопроката

## Установка и запуск

### Требования
- Flutter SDK 3.x (https://flutter.dev/docs/get-started/install)
- Android Studio или Xcode (для iOS)

### Запуск
```bash
cd metal_calc
flutter pub get
flutter run
```

### Сборка APK (Android)
```bash
flutter build apk --release
# APK: build/app/outputs/flutter-apk/app-release.apk
```

### Сборка IPA (iOS)
```bash
flutter build ipa --release
```

## Структура проекта
```
lib/
  main.dart                   — точка входа
  models/models.dart          — модели данных
  data/
    profiles_data.dart        — сортамент и формулы
    materials_data.dart       — металлы и марки
    gost_sizes.dart           — размеры по ГОСТ для барабанов
  logic/calculator.dart       — логика расчёта
  widgets/drum_picker.dart    — компонент барабана
  screens/
    calc_screen.dart          — главный экран
    history_screen.dart       — история расчётов
assets/icons/                 — SVG иконки сортамента
```

## Логика расчёта
Оставьте одно поле пустым — приложение рассчитает его:
- Длина + Кол-во → **Масса**
- Масса + Кол-во → **Длина**
- Масса + Длина  → **Кол-во**
- Для листа: размеры + Кол-во → **Масса**, или Масса → **Кол-во**

## Управление барабанами
- **Удержи** кнопку сортамента → барабан выбора профиля
- **Удержи** кнопку металла → двойной барабан (группа + марка)
- **Удержи** поле размера (есть иконка ⚙) → барабан размеров по ГОСТ
- **Удержи** поле Количество → барабан 1–1000
- Длина и Масса — только клавиатура
=======
# kalkulator-metalla-pro
