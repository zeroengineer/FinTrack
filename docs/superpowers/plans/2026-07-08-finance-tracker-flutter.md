# Finance Tracker Flutter App Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a Flutter app (Android + iOS) that reproduces the 5-screen
"Finance Tracker" design (`Finance Tracker.dc.html`) pixel-for-pixel, backed by
real local persistence (Hive) instead of the prototype's in-memory mock data.

**Architecture:** Riverpod for state, Hive for local persistence, pure-function
utils for all derived calculations (currency formatting, budget %, analytics
aggregation, grouping, CSV), `fl_chart` for charts, `material_symbols_icons`
for icon parity with the design, `flutter_slidable` for swipe-to-edit/delete
rows, `flutter_secure_storage` for the PIN, `flutter_local_notifications` for
reminders.

**Tech Stack:** Flutter (stable channel), flutter_riverpod, hive/hive_flutter,
hive_generator/build_runner, fl_chart, material_symbols_icons, google_fonts,
flutter_slidable, flutter_secure_storage, flutter_local_notifications +
timezone, csv, share_plus, path_provider, intl, uuid.

## Global Constraints

- Currency is fixed to ₹ (INR) with Indian-style digit grouping (e.g.
  `1,23,456`) — no currency picker.
- Accent color is fixed to `#2563EB` (design default) — no theme-color picker.
- The 15 default categories (10 expense, 5 income) are seeded exactly as in
  the design's `CAT` map and are permanent (cannot be renamed/deleted).
- Fully-functional Profile settings: Dark Mode, PIN Lock, Reminder
  notifications, Export Data (CSV), Categories management, About screen.
- Placeholder-only Profile setting: Backup & Restore (visible, inert row).
- Transactions screen's Month/Category/Type filter chips are real filters
  that combine with each other and the search box.
- No backend/cloud sync anywhere — everything is on-device.

Full design detail: `docs/superpowers/specs/2026-07-08-finance-tracker-flutter-design.md`.
Source design file: `_import/premium-personal-finance-tracker/project/Finance Tracker.dc.html`.

---

## Task 0: Create the Flutter project and add dependencies

**Files:**
- Create: Flutter project at repo root (`/Users/devang/finance tracker`) via `flutter create`
- Modify: `pubspec.yaml`

- [ ] **Step 1: Create the project**

Run (from `/Users/devang/finance tracker`):
```bash
flutter create --org com.devang --project-name finance_tracker .
```
Expected: creates `lib/`, `android/`, `ios/`, `pubspec.yaml`, `test/`, and
initializes a git repo (if one didn't already exist) with an initial commit
of the scaffold.

- [ ] **Step 2: Verify the default scaffold builds and its default test passes**

Run: `flutter test`
Expected: `00:0X +1: All tests passed!` (the default counter-app widget test).

- [ ] **Step 3: Add dependencies to `pubspec.yaml`**

Under `dependencies:` (keep the existing `flutter:` and `cupertino_icons:` entries):
```yaml
  flutter_riverpod: ^2.5.1
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  flutter_secure_storage: ^9.2.2
  fl_chart: ^0.68.0
  material_symbols_icons: ^4.2719.3
  google_fonts: ^6.2.1
  flutter_slidable: ^3.1.1
  flutter_local_notifications: ^17.2.2
  timezone: ^0.9.4
  csv: ^6.0.0
  share_plus: ^10.0.2
  path_provider: ^2.1.4
  intl: ^0.19.0
  uuid: ^4.4.2
```
Under `dev_dependencies:` (keep `flutter_test:` and `flutter_lints:`), add:
```yaml
  build_runner: ^2.4.11
  hive_generator: ^2.0.1
```

- [ ] **Step 4: Fetch packages**

Run: `flutter pub get`
Expected: exits 0, "Got dependencies!" with no version-solving errors. If a
version conflict is reported, bump the conflicting package to the version
`pub get` suggests and re-run.

- [ ] **Step 5: Commit**

```bash
git add pubspec.yaml pubspec.lock
git commit -m "chore: add project dependencies"
```

---

## Task 1: Theme (colors + text theme, light/dark)

**Files:**
- Create: `lib/theme/app_theme.dart`
- Test: `test/theme/app_theme_test.dart`

**Interfaces:**
- Produces: `AppColors` (static `Color` constants), `AppPalette` (a
  `ThemeExtension<AppPalette>` with fields `surface`, `surfaceAlt`, `border`,
  `textSecondary`, `textTertiary`, `textQuaternary`), `AppPalette.dark`,
  `AppPalette.light` (const instances), `buildAppTheme(Brightness) -> ThemeData`,
  extension method `context.palette -> AppPalette`.

- [ ] **Step 1: Write the failing test**

```dart
// test/theme/app_theme_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/theme/app_theme.dart';

void main() {
  test('buildAppTheme(dark) carries the dark AppPalette extension', () {
    final theme = buildAppTheme(Brightness.dark);
    expect(theme.brightness, Brightness.dark);
    expect(theme.extension<AppPalette>(), AppPalette.dark);
  });

  test('buildAppTheme(light) carries the light AppPalette extension', () {
    final theme = buildAppTheme(Brightness.light);
    expect(theme.brightness, Brightness.light);
    expect(theme.extension<AppPalette>(), AppPalette.light);
  });

  test('AppPalette.lerp with a non-AppPalette extension returns this unchanged', () {
    expect(AppPalette.dark.lerp(null, 0.5), AppPalette.dark);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/theme/app_theme_test.dart`
Expected: FAIL — `Error: Couldn't resolve the package 'finance_tracker'` or
`Target of URI doesn't exist: 'package:finance_tracker/theme/app_theme.dart'`.

- [ ] **Step 3: Implement `lib/theme/app_theme.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const accent = Color(0xFF2563EB);
  static const accent2 = Color(0xFF3B82F6);
  static const accentSoft = Color(0x292563EB); // ~16% alpha
  static const accentRing = Color(0x732563EB); // ~45% alpha
  static const success = Color(0xFF22C55E);
  static const danger = Color(0xFFEF4444);
  static const dangerStrong = Color(0xFFDC2626);

  static const darkBg = Color(0xFF06080D);
  static const darkSurface = Color(0xFF141A24);
  static const darkSurfaceAlt = Color(0xFF0A0E17);
  static const darkTextPrimary = Color(0xFFF8FAFC);
  static const darkTextSecondary = Color(0xFF94A3B8);
  static const darkTextTertiary = Color(0xFF64748B);
  static const darkTextQuaternary = Color(0xFF475569);
  static const darkBorder = Color(0x12FFFFFF);

  static const lightBg = Color(0xFFF8FAFC);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightSurfaceAlt = Color(0xFFF1F5F9);
  static const lightTextPrimary = Color(0xFF0F172A);
  static const lightTextSecondary = Color(0xFF64748B);
  static const lightTextTertiary = Color(0xFF94A3B8);
  static const lightTextQuaternary = Color(0xFFCBD5E1);
  static const lightBorder = Color(0x14000000);
}

@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  final Color surface;
  final Color surfaceAlt;
  final Color border;
  final Color textSecondary;
  final Color textTertiary;
  final Color textQuaternary;

  const AppPalette({
    required this.surface,
    required this.surfaceAlt,
    required this.border,
    required this.textSecondary,
    required this.textTertiary,
    required this.textQuaternary,
  });

  static const dark = AppPalette(
    surface: AppColors.darkSurface,
    surfaceAlt: AppColors.darkSurfaceAlt,
    border: AppColors.darkBorder,
    textSecondary: AppColors.darkTextSecondary,
    textTertiary: AppColors.darkTextTertiary,
    textQuaternary: AppColors.darkTextQuaternary,
  );

  static const light = AppPalette(
    surface: AppColors.lightSurface,
    surfaceAlt: AppColors.lightSurfaceAlt,
    border: AppColors.lightBorder,
    textSecondary: AppColors.lightTextSecondary,
    textTertiary: AppColors.lightTextTertiary,
    textQuaternary: AppColors.lightTextQuaternary,
  );

  @override
  AppPalette copyWith({
    Color? surface,
    Color? surfaceAlt,
    Color? border,
    Color? textSecondary,
    Color? textTertiary,
    Color? textQuaternary,
  }) {
    return AppPalette(
      surface: surface ?? this.surface,
      surfaceAlt: surfaceAlt ?? this.surfaceAlt,
      border: border ?? this.border,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      textQuaternary: textQuaternary ?? this.textQuaternary,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceAlt: Color.lerp(surfaceAlt, other.surfaceAlt, t)!,
      border: Color.lerp(border, other.border, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      textQuaternary: Color.lerp(textQuaternary, other.textQuaternary, t)!,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is AppPalette &&
      surface == other.surface &&
      surfaceAlt == other.surfaceAlt &&
      border == other.border &&
      textSecondary == other.textSecondary &&
      textTertiary == other.textTertiary &&
      textQuaternary == other.textQuaternary;

  @override
  int get hashCode => Object.hash(
      surface, surfaceAlt, border, textSecondary, textTertiary, textQuaternary);
}

ThemeData buildAppTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;
  final bg = isDark ? AppColors.darkBg : AppColors.lightBg;
  final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
  final palette = isDark ? AppPalette.dark : AppPalette.light;
  final base = isDark ? ThemeData.dark() : ThemeData.light();

  return base.copyWith(
    brightness: brightness,
    scaffoldBackgroundColor: bg,
    primaryColor: AppColors.accent,
    colorScheme: base.colorScheme.copyWith(
      brightness: brightness,
      primary: AppColors.accent,
      onPrimary: Colors.white,
      secondary: AppColors.accent2,
      onSecondary: Colors.white,
      error: AppColors.danger,
      onError: Colors.white,
      surface: palette.surface,
      onSurface: textPrimary,
    ),
    textTheme: GoogleFonts.manropeTextTheme(base.textTheme).apply(
      bodyColor: textPrimary,
      displayColor: textPrimary,
    ),
    extensions: [palette],
  );
}

extension AppPaletteX on BuildContext {
  AppPalette get palette => Theme.of(this).extension<AppPalette>()!;
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/theme/app_theme_test.dart`
Expected: `00:0X +3: All tests passed!`

- [ ] **Step 5: Commit**

```bash
git add lib/theme/app_theme.dart test/theme/app_theme_test.dart
git commit -m "feat: add app theme with light/dark palettes"
```

---

## Task 2: Data models (Hive) — Transaction, Category, Settings

**Files:**
- Create: `lib/models/txn_kind.dart`
- Create: `lib/models/transaction.dart`
- Create: `lib/models/category.dart`
- Create: `lib/models/settings.dart`
- Test: `test/models/models_test.dart`

**Interfaces:**
- Produces: `TxnKind` enum (`expense`, `income`) with `typeId: 2`;
  `TransactionRecord` (`typeId: 0`, fields `id, kind, categoryId, note, amount, date`);
  `CategoryRecord` (`typeId: 1`, fields `id, name, kind, iconName, colorHex, isCustom`);
  `SettingsRecord` (`typeId: 3`, fields `userName, monthlyBudget, monthlySalary, darkMode, remindersEnabled, reminderMinutesSinceMidnight, pinLockEnabled, onboardingComplete`).
  No field has a hardcoded "real-looking" default — `userName` defaults to
  `''`, `monthlyBudget`/`monthlySalary` default to `0`, `onboardingComplete`
  defaults to `false`; the app has no mock/sample data anywhere.
  Each class has a generated `*Adapter` (via `hive_generator`) after `build_runner` runs.

- [ ] **Step 1: Write the model source files (with Hive annotations, no generated code yet)**

```dart
// lib/models/txn_kind.dart
import 'package:hive/hive.dart';

part 'txn_kind.g.dart';

@HiveType(typeId: 2)
enum TxnKind {
  @HiveField(0)
  expense,
  @HiveField(1)
  income,
}
```

```dart
// lib/models/transaction.dart
import 'package:hive/hive.dart';
import 'txn_kind.dart';

part 'transaction.g.dart';

@HiveType(typeId: 0)
class TransactionRecord extends HiveObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  TxnKind kind;
  @HiveField(2)
  String categoryId;
  @HiveField(3)
  String note;
  @HiveField(4)
  double amount;
  @HiveField(5)
  DateTime date;

  TransactionRecord({
    required this.id,
    required this.kind,
    required this.categoryId,
    required this.note,
    required this.amount,
    required this.date,
  });
}
```

```dart
// lib/models/category.dart
import 'package:hive/hive.dart';
import 'txn_kind.dart';

part 'category.g.dart';

@HiveType(typeId: 1)
class CategoryRecord extends HiveObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  String name;
  @HiveField(2)
  TxnKind kind;
  @HiveField(3)
  String iconName;
  @HiveField(4)
  String colorHex;
  @HiveField(5)
  bool isCustom;

  CategoryRecord({
    required this.id,
    required this.name,
    required this.kind,
    required this.iconName,
    required this.colorHex,
    this.isCustom = false,
  });
}
```

```dart
// lib/models/settings.dart
import 'package:hive/hive.dart';

part 'settings.g.dart';

@HiveType(typeId: 3)
class SettingsRecord extends HiveObject {
  @HiveField(0)
  String userName;
  @HiveField(1)
  double monthlyBudget;
  @HiveField(2)
  double monthlySalary;
  @HiveField(3)
  bool darkMode;
  @HiveField(4)
  bool remindersEnabled;
  @HiveField(5)
  int reminderMinutesSinceMidnight;
  @HiveField(6)
  bool pinLockEnabled;
  @HiveField(7)
  bool onboardingComplete;

  SettingsRecord({
    this.userName = '',
    this.monthlyBudget = 0,
    this.monthlySalary = 0,
    this.darkMode = true,
    this.remindersEnabled = false,
    this.reminderMinutesSinceMidnight = 1200,
    this.pinLockEnabled = false,
    this.onboardingComplete = false,
  });
}
```

- [ ] **Step 2: Run build_runner to generate the Hive adapters**

Run: `dart run build_runner build --delete-conflicting-outputs`
Expected: `[INFO] Succeeded after Xs with 4 outputs` and the four `*.g.dart`
files now exist next to their sources.

- [ ] **Step 3: Write the test**

```dart
// test/models/models_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/models/txn_kind.dart';
import 'package:finance_tracker/models/transaction.dart';
import 'package:finance_tracker/models/category.dart';
import 'package:finance_tracker/models/settings.dart';

void main() {
  test('TransactionRecord holds the fields it was constructed with', () {
    final t = TransactionRecord(
      id: '1',
      kind: TxnKind.expense,
      categoryId: 'food',
      note: 'Lunch',
      amount: 320,
      date: DateTime(2026, 7, 8),
    );
    expect(t.kind, TxnKind.expense);
    expect(t.categoryId, 'food');
    expect(t.amount, 320);
  });

  test('CategoryRecord defaults isCustom to false', () {
    final c = CategoryRecord(
      id: 'food',
      name: 'Food',
      kind: TxnKind.expense,
      iconName: 'restaurant',
      colorHex: '#F59E0B',
    );
    expect(c.isCustom, false);
  });

  test('SettingsRecord has no mock data — starts empty/false pre-onboarding', () {
    final s = SettingsRecord();
    expect(s.userName, '');
    expect(s.monthlyBudget, 0);
    expect(s.monthlySalary, 0);
    expect(s.darkMode, true);
    expect(s.pinLockEnabled, false);
    expect(s.onboardingComplete, false);
  });
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/models/models_test.dart`
Expected: `00:0X +3: All tests passed!`

- [ ] **Step 5: Commit**

```bash
git add lib/models test/models/models_test.dart
git commit -m "feat: add Hive data models for transactions, categories, settings"
```

---

## Task 3: Seed categories + Hive box initialization

**Files:**
- Create: `lib/data/seed_categories.dart`
- Create: `lib/data/hive_boxes.dart`
- Test: `test/data/seed_categories_test.dart`

**Interfaces:**
- Consumes: `CategoryRecord`, `TxnKind` (Task 2).
- Produces: `const List<CategoryRecord> kDefaultCategories`; top-level
  constants `transactionsBoxName`, `categoriesBoxName`, `settingsBoxName`;
  `Future<void> initHive()`; `Future<void> seedCategoriesIfEmpty(Box<CategoryRecord> box)`.

- [ ] **Step 1: Write the failing test**

```dart
// test/data/seed_categories_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/data/seed_categories.dart';
import 'package:finance_tracker/models/txn_kind.dart';

void main() {
  test('there are exactly 15 default categories (10 expense, 5 income)', () {
    expect(kDefaultCategories.length, 15);
    expect(kDefaultCategories.where((c) => c.kind == TxnKind.expense).length, 10);
    expect(kDefaultCategories.where((c) => c.kind == TxnKind.income).length, 5);
  });

  test('every default category is non-custom and has a unique id', () {
    expect(kDefaultCategories.every((c) => c.isCustom == false), true);
    final ids = kDefaultCategories.map((c) => c.id).toSet();
    expect(ids.length, kDefaultCategories.length);
  });

  test('Food category matches the design mapping', () {
    final food = kDefaultCategories.firstWhere((c) => c.id == 'food');
    expect(food.name, 'Food');
    expect(food.iconName, 'restaurant');
    expect(food.colorHex, '#F59E0B');
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/data/seed_categories_test.dart`
Expected: FAIL — `seed_categories.dart` doesn't exist yet.

- [ ] **Step 3: Implement `lib/data/seed_categories.dart`**

```dart
import '../models/category.dart';
import '../models/txn_kind.dart';

const kDefaultCategories = <CategoryRecord>[
  CategoryRecord(id: 'food', name: 'Food', kind: TxnKind.expense, iconName: 'restaurant', colorHex: '#F59E0B'),
  CategoryRecord(id: 'transport', name: 'Transport', kind: TxnKind.expense, iconName: 'directions_bus', colorHex: '#3B82F6'),
  CategoryRecord(id: 'shopping', name: 'Shopping', kind: TxnKind.expense, iconName: 'shopping_bag', colorHex: '#EC4899'),
  CategoryRecord(id: 'bills', name: 'Bills', kind: TxnKind.expense, iconName: 'receipt_long', colorHex: '#8B5CF6'),
  CategoryRecord(id: 'entertainment', name: 'Entertainment', kind: TxnKind.expense, iconName: 'movie', colorHex: '#F43F5E'),
  CategoryRecord(id: 'health', name: 'Health', kind: TxnKind.expense, iconName: 'ecg_heart', colorHex: '#22C55E'),
  CategoryRecord(id: 'travel', name: 'Travel', kind: TxnKind.expense, iconName: 'flight', colorHex: '#06B6D4'),
  CategoryRecord(id: 'education', name: 'Education', kind: TxnKind.expense, iconName: 'school', colorHex: '#6366F1'),
  CategoryRecord(id: 'rent', name: 'Rent', kind: TxnKind.expense, iconName: 'home_work', colorHex: '#F97316'),
  CategoryRecord(id: 'others', name: 'Others', kind: TxnKind.expense, iconName: 'category', colorHex: '#94A3B8'),
  CategoryRecord(id: 'salary', name: 'Salary', kind: TxnKind.income, iconName: 'payments', colorHex: '#22C55E'),
  CategoryRecord(id: 'freelance', name: 'Freelance', kind: TxnKind.income, iconName: 'work', colorHex: '#3B82F6'),
  CategoryRecord(id: 'bonus', name: 'Bonus', kind: TxnKind.income, iconName: 'redeem', colorHex: '#F59E0B'),
  CategoryRecord(id: 'gift', name: 'Gift', kind: TxnKind.income, iconName: 'card_giftcard', colorHex: '#EC4899'),
  CategoryRecord(id: 'other_income', name: 'Other', kind: TxnKind.income, iconName: 'savings', colorHex: '#94A3B8'),
];
```

Note: `CategoryRecord` extends `HiveObject`, which does not block `const`
constructors from being used as literal values here since we never call
`.save()` on these until they're `put()` into a box — but `HiveObject`'s
fields (`key`, `isInBox`, etc.) are non-const-friendly in some Hive versions.
If `const kDefaultCategories` fails to compile with a "not a constant
expression" error, change it to `final` (drop `const`) — functionally
identical for this list's usage (read-only, built once).

- [ ] **Step 4: Implement `lib/data/hive_boxes.dart`**

```dart
import 'package:hive_flutter/hive_flutter.dart';
import '../models/txn_kind.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../models/settings.dart';
import 'seed_categories.dart';

const transactionsBoxName = 'transactions';
const categoriesBoxName = 'categories';
const settingsBoxName = 'settings';
const settingsKey = 'settings';

Future<void> initHive() async {
  await Hive.initFlutter();
  Hive.registerAdapter(TxnKindAdapter());
  Hive.registerAdapter(TransactionRecordAdapter());
  Hive.registerAdapter(CategoryRecordAdapter());
  Hive.registerAdapter(SettingsRecordAdapter());

  final categoriesBox = await Hive.openBox<CategoryRecord>(categoriesBoxName);
  await Hive.openBox<TransactionRecord>(transactionsBoxName);
  final settingsBox = await Hive.openBox<SettingsRecord>(settingsBoxName);

  await seedCategoriesIfEmpty(categoriesBox);
  if (!settingsBox.containsKey(settingsKey)) {
    await settingsBox.put(settingsKey, SettingsRecord());
  }
}

Future<void> seedCategoriesIfEmpty(Box<CategoryRecord> box) async {
  if (box.isNotEmpty) return;
  for (final c in kDefaultCategories) {
    await box.put(
      c.id,
      CategoryRecord(
        id: c.id,
        name: c.name,
        kind: c.kind,
        iconName: c.iconName,
        colorHex: c.colorHex,
        isCustom: c.isCustom,
      ),
    );
  }
}
```

- [ ] **Step 5: Run test to verify it passes**

Run: `flutter test test/data/seed_categories_test.dart`
Expected: `00:0X +3: All tests passed!`

- [ ] **Step 6: Commit**

```bash
git add lib/data test/data/seed_categories_test.dart
git commit -m "feat: seed default categories and initialize Hive boxes"
```

---

## Task 4: Currency formatting + budget percentage utils

**Files:**
- Create: `lib/utils/currency.dart`
- Create: `lib/utils/budget.dart`
- Test: `test/utils/currency_test.dart`
- Test: `test/utils/budget_test.dart`

**Interfaces:**
- Produces: `String formatInr(num amount)`; `String groupIndianDigits(String digits)`
  (public so the Add Transaction screen's live amount display can reuse it);
  `int budgetPercent(double spent, double budget)`.

- [ ] **Step 1: Write the failing tests**

```dart
// test/utils/currency_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/utils/currency.dart';

void main() {
  test('groups whole numbers using Indian digit grouping', () {
    expect(formatInr(320), '₹320');
    expect(formatInr(70000), '₹70,000');
    expect(formatInr(123456), '₹1,23,456');
    expect(formatInr(1499), '₹1,499');
  });

  test('keeps up to 2 decimal places when present', () {
    expect(formatInr(320.5), '₹320.50');
  });

  test('handles negative amounts', () {
    expect(formatInr(-500), '-₹500');
  });

  test('handles zero', () {
    expect(formatInr(0), '₹0');
  });
}
```

```dart
// test/utils/budget_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/utils/budget.dart';

void main() {
  test('computes rounded percentage of spent over budget', () {
    expect(budgetPercent(27440, 50000), 55);
  });

  test('clamps to 100 when spending exceeds budget', () {
    expect(budgetPercent(60000, 50000), 100);
  });

  test('returns 0 when budget is zero or negative', () {
    expect(budgetPercent(100, 0), 0);
    expect(budgetPercent(100, -10), 0);
  });
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `flutter test test/utils/currency_test.dart test/utils/budget_test.dart`
Expected: FAIL — neither `lib/utils/currency.dart` nor `lib/utils/budget.dart` exist yet.

- [ ] **Step 3: Implement `lib/utils/currency.dart`**

```dart
String formatInr(num amount) {
  final isNegative = amount < 0;
  final abs = amount.abs();
  final wholePart = abs.truncate();
  final decimalPart = abs - wholePart;
  final grouped = groupIndianDigits(wholePart.toString());
  final decimalStr = decimalPart > 0
      ? '.${(decimalPart * 100).round().toString().padLeft(2, '0')}'
      : '';
  return '${isNegative ? '-' : ''}₹$grouped$decimalStr';
}

String groupIndianDigits(String digits) {
  if (digits.length <= 3) return digits;
  final last3 = digits.substring(digits.length - 3);
  final parts = <String>[];
  var remaining = digits.substring(0, digits.length - 3);
  while (remaining.length > 2) {
    parts.insert(0, remaining.substring(remaining.length - 2));
    remaining = remaining.substring(0, remaining.length - 2);
  }
  if (remaining.isNotEmpty) parts.insert(0, remaining);
  return '${parts.join(',')},$last3';
}
```

- [ ] **Step 4: Implement `lib/utils/budget.dart`**

```dart
int budgetPercent(double spent, double budget) {
  if (budget <= 0) return 0;
  final pct = (spent / budget * 100).round();
  return pct.clamp(0, 100);
}
```

- [ ] **Step 5: Run tests to verify they pass**

Run: `flutter test test/utils/currency_test.dart test/utils/budget_test.dart`
Expected: `00:0X +7: All tests passed!`

- [ ] **Step 6: Commit**

```bash
git add lib/utils/currency.dart lib/utils/budget.dart test/utils/currency_test.dart test/utils/budget_test.dart
git commit -m "feat: add currency formatting and budget percentage utils"
```

---

## Task 5: Day-grouping util (Today / Yesterday / date label)

**Files:**
- Create: `lib/utils/date_grouping.dart`
- Test: `test/utils/date_grouping_test.dart`

**Interfaces:**
- Produces: `String dayGroupLabel(DateTime date, DateTime now)`.

- [ ] **Step 1: Write the failing test**

```dart
// test/utils/date_grouping_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/utils/date_grouping.dart';

void main() {
  final now = DateTime(2026, 7, 8, 15, 0);

  test('same calendar day as now is "Today"', () {
    expect(dayGroupLabel(DateTime(2026, 7, 8, 9, 10), now), 'Today');
  });

  test('one calendar day before now is "Yesterday"', () {
    expect(dayGroupLabel(DateTime(2026, 7, 7, 23, 59), now), 'Yesterday');
  });

  test('older dates use a "MMM d" label', () {
    expect(dayGroupLabel(DateTime(2026, 7, 5, 11, 20), now), 'Jul 5');
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/utils/date_grouping_test.dart`
Expected: FAIL — `date_grouping.dart` doesn't exist yet.

- [ ] **Step 3: Implement `lib/utils/date_grouping.dart`**

```dart
import 'package:intl/intl.dart';

String dayGroupLabel(DateTime date, DateTime now) {
  final today = DateTime(now.year, now.month, now.day);
  final target = DateTime(date.year, date.month, date.day);
  final diff = today.difference(target).inDays;
  if (diff == 0) return 'Today';
  if (diff == 1) return 'Yesterday';
  return DateFormat('MMM d').format(date);
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/utils/date_grouping_test.dart`
Expected: `00:0X +3: All tests passed!`

- [ ] **Step 5: Commit**

```bash
git add lib/utils/date_grouping.dart test/utils/date_grouping_test.dart
git commit -m "feat: add day-grouping util for transaction lists"
```

---

## Task 6: Analytics aggregation utils

**Files:**
- Create: `lib/utils/analytics.dart`
- Test: `test/utils/analytics_test.dart`

**Interfaces:**
- Consumes: `TransactionRecord`, `TxnKind` (Task 2).
- Produces: `HomeSummary` (fields `income`, `expense`, `balance`, getter
  `savings`), `computeHomeSummary(List<TransactionRecord>, DateTime now) -> HomeSummary`;
  `CategoryShare` (fields `categoryId`, `amount`, `percent`),
  `categoryBreakdown(List<TransactionRecord> expenses) -> List<CategoryShare>`
  (sorted descending by amount); `TopCategory` (fields `categoryId`, `amount`,
  `barFraction`), `topSpendingCategories(List<TransactionRecord> expenses, {int limit = 4}) -> List<TopCategory>`;
  `MonthlyTotals` (fields `month`, `income`, `expense`, getter `savings`),
  `monthlySeries(List<TransactionRecord>, DateTime now, {int months = 6}) -> List<MonthlyTotals>`
  (ascending by month, always exactly `months` entries even with no data).

- [ ] **Step 1: Write the failing test**

```dart
// test/utils/analytics_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/models/transaction.dart';
import 'package:finance_tracker/models/txn_kind.dart';
import 'package:finance_tracker/utils/analytics.dart';

TransactionRecord _t(TxnKind kind, String cat, double amt, DateTime date) =>
    TransactionRecord(id: '$cat-$amt-$date', kind: kind, categoryId: cat, note: '', amount: amt, date: date);

void main() {
  final now = DateTime(2026, 7, 8);

  group('computeHomeSummary', () {
    test('sums only the current month\'s income/expense', () {
      final txns = [
        _t(TxnKind.income, 'salary', 70000, DateTime(2026, 7, 1)),
        _t(TxnKind.expense, 'food', 320, DateTime(2026, 7, 8)),
        _t(TxnKind.expense, 'food', 999, DateTime(2026, 6, 20)), // last month, excluded
      ];
      final s = computeHomeSummary(txns, now);
      expect(s.income, 70000);
      expect(s.expense, 320);
      expect(s.balance, 70000 - 320);
      expect(s.savings, 70000 - 320);
    });
  });

  group('categoryBreakdown', () {
    test('returns percent-of-total shares sorted descending', () {
      final expenses = [
        _t(TxnKind.expense, 'shopping', 8200, now),
        _t(TxnKind.expense, 'food', 6570, now),
        _t(TxnKind.expense, 'bills', 4800, now),
      ];
      final result = categoryBreakdown(expenses);
      expect(result.map((e) => e.categoryId).toList(), ['shopping', 'food', 'bills']);
      expect(result.first.amount, 8200);
      expect(result.first.percent, closeTo(8200 / (8200 + 6570 + 4800) * 100, 0.001));
    });

    test('empty input returns empty list', () {
      expect(categoryBreakdown([]), isEmpty);
    });
  });

  group('topSpendingCategories', () {
    test('limits results and computes bar fraction relative to the max', () {
      final expenses = [
        _t(TxnKind.expense, 'shopping', 8200, now),
        _t(TxnKind.expense, 'food', 6570, now),
        _t(TxnKind.expense, 'bills', 4800, now),
        _t(TxnKind.expense, 'transport', 3200, now),
        _t(TxnKind.expense, 'others', 1000, now),
      ];
      final result = topSpendingCategories(expenses, limit: 4);
      expect(result.length, 4);
      expect(result.first.barFraction, 1.0);
      expect(result.last.categoryId, 'transport');
    });
  });

  group('monthlySeries', () {
    test('returns exactly `months` entries ending at the current month, ascending', () {
      final txns = [
        _t(TxnKind.income, 'salary', 70000, DateTime(2026, 7, 1)),
        _t(TxnKind.expense, 'food', 27440, DateTime(2026, 7, 5)),
      ];
      final series = monthlySeries(txns, now, months: 6);
      expect(series.length, 6);
      expect(series.last.month, DateTime(2026, 7, 1));
      expect(series.first.month, DateTime(2026, 2, 1));
      expect(series.last.income, 70000);
      expect(series.last.expense, 27440);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/utils/analytics_test.dart`
Expected: FAIL — `analytics.dart` doesn't exist yet.

- [ ] **Step 3: Implement `lib/utils/analytics.dart`**

```dart
import '../models/transaction.dart';
import '../models/txn_kind.dart';

class HomeSummary {
  final double income;
  final double expense;
  final double balance;
  const HomeSummary({required this.income, required this.expense, required this.balance});
  double get savings => income - expense;
}

HomeSummary computeHomeSummary(List<TransactionRecord> txns, DateTime now) {
  double income = 0, expense = 0;
  for (final t in txns) {
    if (t.date.year == now.year && t.date.month == now.month) {
      if (t.kind == TxnKind.income) {
        income += t.amount;
      } else {
        expense += t.amount;
      }
    }
  }
  return HomeSummary(income: income, expense: expense, balance: income - expense);
}

class CategoryShare {
  final String categoryId;
  final double amount;
  final double percent;
  const CategoryShare({required this.categoryId, required this.amount, required this.percent});
}

List<CategoryShare> categoryBreakdown(List<TransactionRecord> expenses) {
  if (expenses.isEmpty) return [];
  final totals = <String, double>{};
  double total = 0;
  for (final t in expenses) {
    totals[t.categoryId] = (totals[t.categoryId] ?? 0) + t.amount;
    total += t.amount;
  }
  final entries = totals.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
  return entries
      .map((e) => CategoryShare(
            categoryId: e.key,
            amount: e.value,
            percent: total == 0 ? 0 : e.value / total * 100,
          ))
      .toList();
}

class TopCategory {
  final String categoryId;
  final double amount;
  final double barFraction;
  const TopCategory({required this.categoryId, required this.amount, required this.barFraction});
}

List<TopCategory> topSpendingCategories(List<TransactionRecord> expenses, {int limit = 4}) {
  final totals = <String, double>{};
  for (final t in expenses) {
    totals[t.categoryId] = (totals[t.categoryId] ?? 0) + t.amount;
  }
  final entries = totals.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
  final top = entries.take(limit).toList();
  final maxV = top.isEmpty ? 1.0 : top.first.value;
  return top
      .map((e) => TopCategory(
            categoryId: e.key,
            amount: e.value,
            barFraction: maxV == 0 ? 0 : e.value / maxV,
          ))
      .toList();
}

class MonthlyTotals {
  final DateTime month;
  final double income;
  final double expense;
  const MonthlyTotals({required this.month, required this.income, required this.expense});
  double get savings => income - expense;
}

List<MonthlyTotals> monthlySeries(List<TransactionRecord> txns, DateTime now, {int months = 6}) {
  final buckets = <DateTime, MonthlyTotals>{};
  final order = <DateTime>[];
  for (var i = months - 1; i >= 0; i--) {
    final m = DateTime(now.year, now.month - i, 1);
    buckets[m] = MonthlyTotals(month: m, income: 0, expense: 0);
    order.add(m);
  }
  for (final t in txns) {
    final key = DateTime(t.date.year, t.date.month, 1);
    final bucket = buckets[key];
    if (bucket == null) continue;
    buckets[key] = t.kind == TxnKind.income
        ? MonthlyTotals(month: key, income: bucket.income + t.amount, expense: bucket.expense)
        : MonthlyTotals(month: key, income: bucket.income, expense: bucket.expense + t.amount);
  }
  return [for (final m in order) buckets[m]!];
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/utils/analytics_test.dart`
Expected: `00:0X +7: All tests passed!`

- [ ] **Step 5: Commit**

```bash
git add lib/utils/analytics.dart test/utils/analytics_test.dart
git commit -m "feat: add analytics aggregation utils"
```

---

## Task 7: Transaction filtering util

**Files:**
- Create: `lib/utils/filtering.dart`
- Test: `test/utils/filtering_test.dart`

**Interfaces:**
- Consumes: `TransactionRecord`, `TxnKind`, `CategoryRecord` (Task 2).
- Produces: `List<TransactionRecord> filterTransactions(List<TransactionRecord> all, {String query = '', String? categoryId, TxnKind? kind, DateTime? month, required Map<String, CategoryRecord> categoriesById})`.

- [ ] **Step 1: Write the failing test**

```dart
// test/utils/filtering_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/models/transaction.dart';
import 'package:finance_tracker/models/category.dart';
import 'package:finance_tracker/models/txn_kind.dart';
import 'package:finance_tracker/utils/filtering.dart';

void main() {
  final food = CategoryRecord(id: 'food', name: 'Food', kind: TxnKind.expense, iconName: 'restaurant', colorHex: '#F59E0B');
  final salary = CategoryRecord(id: 'salary', name: 'Salary', kind: TxnKind.income, iconName: 'payments', colorHex: '#22C55E');
  final catsById = {'food': food, 'salary': salary};

  final txns = [
    TransactionRecord(id: '1', kind: TxnKind.expense, categoryId: 'food', note: 'Lunch at work', amount: 320, date: DateTime(2026, 7, 8)),
    TransactionRecord(id: '2', kind: TxnKind.income, categoryId: 'salary', note: 'Monthly salary', amount: 70000, date: DateTime(2026, 7, 1)),
    TransactionRecord(id: '3', kind: TxnKind.expense, categoryId: 'food', note: 'Groceries', amount: 450, date: DateTime(2026, 6, 5)),
  ];

  test('no filters returns everything', () {
    expect(filterTransactions(txns, categoriesById: catsById).length, 3);
  });

  test('search query matches category name or note (case-insensitive)', () {
    expect(filterTransactions(txns, query: 'lunch', categoriesById: catsById).map((t) => t.id), ['1']);
    expect(filterTransactions(txns, query: 'FOOD', categoriesById: catsById).map((t) => t.id), ['1', '3']);
  });

  test('categoryId filter restricts to that category', () {
    expect(filterTransactions(txns, categoryId: 'salary', categoriesById: catsById).map((t) => t.id), ['2']);
  });

  test('kind filter restricts to income or expense', () {
    expect(filterTransactions(txns, kind: TxnKind.income, categoriesById: catsById).map((t) => t.id), ['2']);
  });

  test('month filter restricts to that calendar month', () {
    expect(filterTransactions(txns, month: DateTime(2026, 6), categoriesById: catsById).map((t) => t.id), ['3']);
  });

  test('filters combine', () {
    expect(
      filterTransactions(txns, kind: TxnKind.expense, month: DateTime(2026, 7), categoriesById: catsById).map((t) => t.id),
      ['1'],
    );
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/utils/filtering_test.dart`
Expected: FAIL — `filtering.dart` doesn't exist yet.

- [ ] **Step 3: Implement `lib/utils/filtering.dart`**

```dart
import '../models/category.dart';
import '../models/transaction.dart';
import '../models/txn_kind.dart';

List<TransactionRecord> filterTransactions(
  List<TransactionRecord> all, {
  String query = '',
  String? categoryId,
  TxnKind? kind,
  DateTime? month,
  required Map<String, CategoryRecord> categoriesById,
}) {
  final q = query.trim().toLowerCase();
  return all.where((t) {
    if (categoryId != null && t.categoryId != categoryId) return false;
    if (kind != null && t.kind != kind) return false;
    if (month != null && (t.date.year != month.year || t.date.month != month.month)) return false;
    if (q.isNotEmpty) {
      final catName = categoriesById[t.categoryId]?.name.toLowerCase() ?? '';
      if (!catName.contains(q) && !t.note.toLowerCase().contains(q)) return false;
    }
    return true;
  }).toList();
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/utils/filtering_test.dart`
Expected: `00:0X +6: All tests passed!`

- [ ] **Step 5: Commit**

```bash
git add lib/utils/filtering.dart test/utils/filtering_test.dart
git commit -m "feat: add transaction filtering util"
```

---

## Task 8: CSV export util

**Files:**
- Create: `lib/utils/csv_export.dart`
- Test: `test/utils/csv_export_test.dart`

**Interfaces:**
- Consumes: `TransactionRecord`, `TxnKind`, `CategoryRecord` (Task 2).
- Produces: `String transactionsToCsv(List<TransactionRecord> txns, Map<String, CategoryRecord> categoriesById)`.

- [ ] **Step 1: Write the failing test**

```dart
// test/utils/csv_export_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/models/transaction.dart';
import 'package:finance_tracker/models/category.dart';
import 'package:finance_tracker/models/txn_kind.dart';
import 'package:finance_tracker/utils/csv_export.dart';

void main() {
  test('produces a header row plus one row per transaction', () {
    final food = CategoryRecord(id: 'food', name: 'Food', kind: TxnKind.expense, iconName: 'restaurant', colorHex: '#F59E0B');
    final txns = [
      TransactionRecord(id: '1', kind: TxnKind.expense, categoryId: 'food', note: 'Lunch', amount: 320, date: DateTime(2026, 7, 8, 13, 20)),
    ];
    final csv = transactionsToCsv(txns, {'food': food});
    final lines = csv.trim().split('\r\n');
    expect(lines.first, 'Date,Type,Category,Note,Amount');
    expect(lines[1], '2026-07-08 13:20,Expense,Food,Lunch,320.00');
  });

  test('unknown category id falls back to "Unknown"', () {
    final txns = [
      TransactionRecord(id: '1', kind: TxnKind.income, categoryId: 'missing', note: '', amount: 100, date: DateTime(2026, 1, 1)),
    ];
    final csv = transactionsToCsv(txns, {});
    expect(csv, contains('Unknown'));
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/utils/csv_export_test.dart`
Expected: FAIL — `csv_export.dart` doesn't exist yet.

- [ ] **Step 3: Implement `lib/utils/csv_export.dart`**

```dart
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import '../models/category.dart';
import '../models/transaction.dart';
import '../models/txn_kind.dart';

String transactionsToCsv(List<TransactionRecord> txns, Map<String, CategoryRecord> categoriesById) {
  final dateFmt = DateFormat('yyyy-MM-dd HH:mm');
  final rows = <List<String>>[
    ['Date', 'Type', 'Category', 'Note', 'Amount'],
    ...txns.map((t) => [
          dateFmt.format(t.date),
          t.kind == TxnKind.income ? 'Income' : 'Expense',
          categoriesById[t.categoryId]?.name ?? 'Unknown',
          t.note,
          t.amount.toStringAsFixed(2),
        ]),
  ];
  return const ListToCsvConverter().convert(rows);
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/utils/csv_export_test.dart`
Expected: `00:0X +2: All tests passed!`

- [ ] **Step 5: Commit**

```bash
git add lib/utils/csv_export.dart test/utils/csv_export_test.dart
git commit -m "feat: add CSV export util"
```

---

## Task 9: Riverpod CRUD providers for categories and transactions

**Files:**
- Create: `lib/providers/categories_provider.dart`
- Create: `lib/providers/transactions_provider.dart`
- Test: `test/providers/categories_provider_test.dart`
- Test: `test/providers/transactions_provider_test.dart`

**Interfaces:**
- Consumes: `CategoryRecord`, `TransactionRecord`, `TxnKind` (Task 2);
  `categoriesBoxName`, `transactionsBoxName` (Task 3).
- Produces: `categoriesBoxProvider -> Provider<Box<CategoryRecord>>`;
  `CategoriesNotifier` with `add(CategoryRecord)`, `rename(String id, String newName)`,
  `delete(String id)`; `categoriesProvider -> StateNotifierProvider<CategoriesNotifier, List<CategoryRecord>>`.
  `transactionsBoxProvider -> Provider<Box<TransactionRecord>>`;
  `TransactionsNotifier` with `add(TransactionRecord)`, `update(TransactionRecord)`,
  `delete(String id)`; `transactionsProvider -> StateNotifierProvider<TransactionsNotifier, List<TransactionRecord>>`
  (state always sorted by `date` descending).

- [ ] **Step 1: Write the failing tests**

```dart
// test/providers/categories_provider_test.dart
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance_tracker/models/txn_kind.dart';
import 'package:finance_tracker/models/category.dart';
import 'package:finance_tracker/providers/categories_provider.dart';
import 'package:finance_tracker/data/hive_boxes.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('hive_test_');
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(TxnKindAdapter());
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(CategoryRecordAdapter());
    await Hive.openBox<CategoryRecord>(categoriesBoxName);
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    tempDir.deleteSync(recursive: true);
  });

  test('starts with whatever is already in the box', () async {
    await Hive.box<CategoryRecord>(categoriesBoxName).put(
      'food',
      CategoryRecord(id: 'food', name: 'Food', kind: TxnKind.expense, iconName: 'restaurant', colorHex: '#F59E0B'),
    );
    final container = ProviderContainer();
    addTearDown(container.dispose);
    expect(container.read(categoriesProvider).map((c) => c.id), ['food']);
  });

  test('add() persists to the box and updates state', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await container.read(categoriesProvider.notifier).add(
      CategoryRecord(id: 'custom1', name: 'Pets', kind: TxnKind.expense, iconName: 'pets', colorHex: '#000000', isCustom: true),
    );
    expect(container.read(categoriesProvider).map((c) => c.id), contains('custom1'));
    expect(Hive.box<CategoryRecord>(categoriesBoxName).get('custom1')!.name, 'Pets');
  });

  test('rename() updates name in place', () async {
    await Hive.box<CategoryRecord>(categoriesBoxName).put(
      'custom1',
      CategoryRecord(id: 'custom1', name: 'Pets', kind: TxnKind.expense, iconName: 'pets', colorHex: '#000000', isCustom: true),
    );
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await container.read(categoriesProvider.notifier).rename('custom1', 'Pet Care');
    expect(container.read(categoriesProvider).firstWhere((c) => c.id == 'custom1').name, 'Pet Care');
  });

  test('delete() removes from the box and state', () async {
    await Hive.box<CategoryRecord>(categoriesBoxName).put(
      'custom1',
      CategoryRecord(id: 'custom1', name: 'Pets', kind: TxnKind.expense, iconName: 'pets', colorHex: '#000000', isCustom: true),
    );
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await container.read(categoriesProvider.notifier).delete('custom1');
    expect(container.read(categoriesProvider).any((c) => c.id == 'custom1'), false);
  });
}
```

```dart
// test/providers/transactions_provider_test.dart
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance_tracker/models/txn_kind.dart';
import 'package:finance_tracker/models/transaction.dart';
import 'package:finance_tracker/providers/transactions_provider.dart';
import 'package:finance_tracker/data/hive_boxes.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('hive_test_');
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(TxnKindAdapter());
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(TransactionRecordAdapter());
    await Hive.openBox<TransactionRecord>(transactionsBoxName);
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    tempDir.deleteSync(recursive: true);
  });

  test('state is sorted by date descending', () async {
    final box = Hive.box<TransactionRecord>(transactionsBoxName);
    await box.put('1', TransactionRecord(id: '1', kind: TxnKind.expense, categoryId: 'food', note: '', amount: 100, date: DateTime(2026, 7, 1)));
    await box.put('2', TransactionRecord(id: '2', kind: TxnKind.expense, categoryId: 'food', note: '', amount: 200, date: DateTime(2026, 7, 8)));
    final container = ProviderContainer();
    addTearDown(container.dispose);
    expect(container.read(transactionsProvider).map((t) => t.id), ['2', '1']);
  });

  test('add() persists and re-sorts', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await container.read(transactionsProvider.notifier).add(
      TransactionRecord(id: '1', kind: TxnKind.income, categoryId: 'salary', note: 'pay', amount: 70000, date: DateTime(2026, 7, 8)),
    );
    expect(container.read(transactionsProvider).length, 1);
  });

  test('update() overwrites the existing record by id', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(transactionsProvider.notifier);
    await notifier.add(TransactionRecord(id: '1', kind: TxnKind.expense, categoryId: 'food', note: 'old', amount: 100, date: DateTime(2026, 7, 8)));
    await notifier.update(TransactionRecord(id: '1', kind: TxnKind.expense, categoryId: 'food', note: 'new', amount: 150, date: DateTime(2026, 7, 8)));
    final txn = container.read(transactionsProvider).single;
    expect(txn.note, 'new');
    expect(txn.amount, 150);
  });

  test('delete() removes by id', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(transactionsProvider.notifier);
    await notifier.add(TransactionRecord(id: '1', kind: TxnKind.expense, categoryId: 'food', note: '', amount: 100, date: DateTime(2026, 7, 8)));
    await notifier.delete('1');
    expect(container.read(transactionsProvider), isEmpty);
  });
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `flutter test test/providers/categories_provider_test.dart test/providers/transactions_provider_test.dart`
Expected: FAIL — neither provider file exists yet.

- [ ] **Step 3: Implement `lib/providers/categories_provider.dart`**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../data/hive_boxes.dart';
import '../models/category.dart';

final categoriesBoxProvider = Provider<Box<CategoryRecord>>((ref) {
  return Hive.box<CategoryRecord>(categoriesBoxName);
});

class CategoriesNotifier extends StateNotifier<List<CategoryRecord>> {
  final Box<CategoryRecord> box;
  CategoriesNotifier(this.box) : super(box.values.toList());

  void _refresh() => state = box.values.toList();

  Future<void> add(CategoryRecord c) async {
    await box.put(c.id, c);
    _refresh();
  }

  Future<void> rename(String id, String newName) async {
    final existing = box.get(id);
    if (existing == null) return;
    await box.put(
      id,
      CategoryRecord(
        id: existing.id,
        name: newName,
        kind: existing.kind,
        iconName: existing.iconName,
        colorHex: existing.colorHex,
        isCustom: existing.isCustom,
      ),
    );
    _refresh();
  }

  Future<void> delete(String id) async {
    await box.delete(id);
    _refresh();
  }
}

final categoriesProvider = StateNotifierProvider<CategoriesNotifier, List<CategoryRecord>>((ref) {
  return CategoriesNotifier(ref.watch(categoriesBoxProvider));
});
```

- [ ] **Step 4: Implement `lib/providers/transactions_provider.dart`**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../data/hive_boxes.dart';
import '../models/transaction.dart';

final transactionsBoxProvider = Provider<Box<TransactionRecord>>((ref) {
  return Hive.box<TransactionRecord>(transactionsBoxName);
});

class TransactionsNotifier extends StateNotifier<List<TransactionRecord>> {
  final Box<TransactionRecord> box;
  TransactionsNotifier(this.box) : super(_sorted(box.values.toList()));

  static List<TransactionRecord> _sorted(List<TransactionRecord> l) =>
      l..sort((a, b) => b.date.compareTo(a.date));

  void _refresh() => state = _sorted(box.values.toList());

  Future<void> add(TransactionRecord t) async {
    await box.put(t.id, t);
    _refresh();
  }

  Future<void> update(TransactionRecord t) async {
    await box.put(t.id, t);
    _refresh();
  }

  Future<void> delete(String id) async {
    await box.delete(id);
    _refresh();
  }
}

final transactionsProvider = StateNotifierProvider<TransactionsNotifier, List<TransactionRecord>>((ref) {
  return TransactionsNotifier(ref.watch(transactionsBoxProvider));
});
```

- [ ] **Step 5: Run tests to verify they pass**

Run: `flutter test test/providers/categories_provider_test.dart test/providers/transactions_provider_test.dart`
Expected: `00:0X +8: All tests passed!`

- [ ] **Step 6: Commit**

```bash
git add lib/providers/categories_provider.dart lib/providers/transactions_provider.dart test/providers/categories_provider_test.dart test/providers/transactions_provider_test.dart
git commit -m "feat: add Riverpod CRUD providers for categories and transactions"
```

---

## Task 10: Settings provider

**Files:**
- Create: `lib/providers/settings_provider.dart`
- Test: `test/providers/settings_provider_test.dart`

**Interfaces:**
- Consumes: `SettingsRecord` (Task 2); `settingsBoxName`, `settingsKey` (Task 3).
- Produces: `settingsBoxProvider -> Provider<Box<SettingsRecord>>`;
  `SettingsNotifier` with `setUserName(String)`, `setMonthlyBudget(double)`,
  `setMonthlySalary(double)`, `setDarkMode(bool)`, `setRemindersEnabled(bool)`,
  `setReminderMinutes(int)`, `setPinLockEnabled(bool)`,
  `completeOnboarding({required String userName, required double monthlySalary, required double monthlyBudget})`
  (sets all three plus `onboardingComplete = true` in a single save);
  `settingsProvider -> StateNotifierProvider<SettingsNotifier, SettingsRecord>`.

- [ ] **Step 1: Write the failing test**

```dart
// test/providers/settings_provider_test.dart
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance_tracker/models/settings.dart';
import 'package:finance_tracker/providers/settings_provider.dart';
import 'package:finance_tracker/data/hive_boxes.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('hive_test_');
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(SettingsRecordAdapter());
    final box = await Hive.openBox<SettingsRecord>(settingsBoxName);
    await box.put(settingsKey, SettingsRecord());
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    tempDir.deleteSync(recursive: true);
  });

  test('starts from the record already in the box, with no mock data', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    expect(container.read(settingsProvider).userName, '');
    expect(container.read(settingsProvider).onboardingComplete, false);
  });

  test('completeOnboarding sets name/salary/budget and flips onboardingComplete', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await container.read(settingsProvider.notifier).completeOnboarding(
          userName: 'Asha',
          monthlySalary: 60000,
          monthlyBudget: 40000,
        );
    final s = container.read(settingsProvider);
    expect(s.userName, 'Asha');
    expect(s.monthlySalary, 60000);
    expect(s.monthlyBudget, 40000);
    expect(s.onboardingComplete, true);
  });

  test('setDarkMode persists and updates state', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await container.read(settingsProvider.notifier).setDarkMode(false);
    expect(container.read(settingsProvider).darkMode, false);
    expect(Hive.box<SettingsRecord>(settingsBoxName).get(settingsKey)!.darkMode, false);
  });

  test('setMonthlyBudget persists and updates state', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await container.read(settingsProvider.notifier).setMonthlyBudget(80000);
    expect(container.read(settingsProvider).monthlyBudget, 80000);
  });

  test('setPinLockEnabled persists and updates state', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await container.read(settingsProvider.notifier).setPinLockEnabled(true);
    expect(container.read(settingsProvider).pinLockEnabled, true);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/providers/settings_provider_test.dart`
Expected: FAIL — `settings_provider.dart` doesn't exist yet.

- [ ] **Step 3: Implement `lib/providers/settings_provider.dart`**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../data/hive_boxes.dart';
import '../models/settings.dart';

final settingsBoxProvider = Provider<Box<SettingsRecord>>((ref) {
  return Hive.box<SettingsRecord>(settingsBoxName);
});

class SettingsNotifier extends StateNotifier<SettingsRecord> {
  final Box<SettingsRecord> box;
  SettingsNotifier(this.box) : super(box.get(settingsKey) ?? SettingsRecord());

  Future<void> _save(SettingsRecord next) async {
    await box.put(settingsKey, next);
    state = next;
  }

  Future<void> setUserName(String v) => _save(_copy(userName: v));
  Future<void> setMonthlyBudget(double v) => _save(_copy(monthlyBudget: v));
  Future<void> setMonthlySalary(double v) => _save(_copy(monthlySalary: v));
  Future<void> setDarkMode(bool v) => _save(_copy(darkMode: v));
  Future<void> setRemindersEnabled(bool v) => _save(_copy(remindersEnabled: v));
  Future<void> setReminderMinutes(int v) => _save(_copy(reminderMinutesSinceMidnight: v));
  Future<void> setPinLockEnabled(bool v) => _save(_copy(pinLockEnabled: v));

  Future<void> completeOnboarding({
    required String userName,
    required double monthlySalary,
    required double monthlyBudget,
  }) {
    return _save(_copy(
      userName: userName,
      monthlySalary: monthlySalary,
      monthlyBudget: monthlyBudget,
      onboardingComplete: true,
    ));
  }

  SettingsRecord _copy({
    String? userName,
    double? monthlyBudget,
    double? monthlySalary,
    bool? darkMode,
    bool? remindersEnabled,
    int? reminderMinutesSinceMidnight,
    bool? pinLockEnabled,
    bool? onboardingComplete,
  }) {
    return SettingsRecord(
      userName: userName ?? state.userName,
      monthlyBudget: monthlyBudget ?? state.monthlyBudget,
      monthlySalary: monthlySalary ?? state.monthlySalary,
      darkMode: darkMode ?? state.darkMode,
      remindersEnabled: remindersEnabled ?? state.remindersEnabled,
      reminderMinutesSinceMidnight: reminderMinutesSinceMidnight ?? state.reminderMinutesSinceMidnight,
      pinLockEnabled: pinLockEnabled ?? state.pinLockEnabled,
      onboardingComplete: onboardingComplete ?? state.onboardingComplete,
    );
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsRecord>((ref) {
  return SettingsNotifier(ref.watch(settingsBoxProvider));
});
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/providers/settings_provider_test.dart`
Expected: `00:0X +6: All tests passed!`

- [ ] **Step 5: Commit**

```bash
git add lib/providers/settings_provider.dart test/providers/settings_provider_test.dart
git commit -m "feat: add settings provider"
```

---

## Task 11: Derived providers (home summary, budget %, analytics, filters, tab/draft state)

**Files:**
- Create: `lib/providers/app_state.dart`
- Test: `test/providers/app_state_test.dart`

**Interfaces:**
- Consumes: `transactionsProvider`, `categoriesProvider`, `settingsProvider`
  (Tasks 9-10); `HomeSummary`, `computeHomeSummary`, `CategoryShare`,
  `categoryBreakdown`, `TopCategory`, `topSpendingCategories`, `MonthlyTotals`,
  `monthlySeries` (Task 6); `filterTransactions` (Task 7); `dayGroupLabel`
  (Task 5).
- Produces: `AppTab` enum (`home, transactions, add, analytics, profile`),
  `currentTabProvider -> StateProvider<AppTab>`;
  `sessionUnlockedProvider -> StateProvider<bool>` (defaults `false`; only
  meaningful when `settings.pinLockEnabled` is true — used by later PIN-lock
  routing);
  `categoriesByIdProvider -> Provider<Map<String, CategoryRecord>>`;
  `homeSummaryProvider -> Provider<HomeSummary>`;
  `recentTransactionsProvider -> Provider<List<TransactionRecord>>` (top 3);
  `budgetPercentProvider -> Provider<int>`;
  `searchQueryProvider -> StateProvider<String>`;
  `selectedMonthProvider -> StateProvider<DateTime?>`;
  `selectedCategoryIdProvider -> StateProvider<String?>`;
  `selectedKindFilterProvider -> StateProvider<TxnKind?>`;
  `filteredTransactionsProvider -> Provider<List<TransactionRecord>>`;
  `groupedTransactionsProvider -> Provider<List<MapEntry<String, List<TransactionRecord>>>>`;
  `currentMonthExpensesProvider -> Provider<List<TransactionRecord>>`;
  `categoryBreakdownProvider -> Provider<List<CategoryShare>>`;
  `topSpendingCategoriesProvider -> Provider<List<TopCategory>>`;
  `monthlySeriesProvider -> Provider<List<MonthlyTotals>>`;
  `AddTxnDraft` (fields `kind`, `amount`, `categoryId`, `note`, `editingId`)
  with `copyWith`; `AddTxnDraftNotifier` with `reset({TxnKind kind})`,
  `setKind(TxnKind)`, `setCategory(String)`, `setNote(String)`,
  `pressKey(String)`, `loadForEdit(TransactionRecord)`;
  `addTxnDraftProvider -> StateNotifierProvider<AddTxnDraftNotifier, AddTxnDraft>`.

- [ ] **Step 1: Write the failing test**

Note: `TransactionsNotifier` (Task 9) reads the box's contents once, at
construction, via `ref.watch(transactionsBoxProvider)`. Populate every box
with its fixture data *before* creating the `ProviderContainer` in each test
below, so the notifier's initial state already reflects the fixtures.

```dart
// test/providers/app_state_test.dart
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance_tracker/models/txn_kind.dart';
import 'package:finance_tracker/models/transaction.dart';
import 'package:finance_tracker/models/category.dart';
import 'package:finance_tracker/models/settings.dart';
import 'package:finance_tracker/data/hive_boxes.dart';
import 'package:finance_tracker/data/seed_categories.dart';
import 'package:finance_tracker/providers/app_state.dart';

void main() {
  late Directory tempDir;
  late DateTime now;

  setUp(() async {
    now = DateTime.now();
    tempDir = Directory.systemTemp.createTempSync('hive_test_');
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(TxnKindAdapter());
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(TransactionRecordAdapter());
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(CategoryRecordAdapter());
    if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(SettingsRecordAdapter());
    final catBox = await Hive.openBox<CategoryRecord>(categoriesBoxName);
    await seedCategoriesIfEmpty(catBox);
    await Hive.openBox<TransactionRecord>(transactionsBoxName);
    final settingsBox = await Hive.openBox<SettingsRecord>(settingsBoxName);
    await settingsBox.put(settingsKey, SettingsRecord(monthlyBudget: 1000));
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    tempDir.deleteSync(recursive: true);
  });

  test('homeSummaryProvider + budgetPercentProvider reflect stored transactions', () async {
    final txnBox = Hive.box<TransactionRecord>(transactionsBoxName);
    await txnBox.put('1', TransactionRecord(id: '1', kind: TxnKind.expense, categoryId: 'food', note: '', amount: 500, date: now));
    await txnBox.put('2', TransactionRecord(id: '2', kind: TxnKind.income, categoryId: 'salary', note: '', amount: 2000, date: now));

    final container = ProviderContainer();
    addTearDown(container.dispose);
    final summary = container.read(homeSummaryProvider);
    expect(summary.expense, 500);
    expect(summary.income, 2000);
    expect(container.read(budgetPercentProvider), 50); // 500 / 1000 budget
  });

  test('filteredTransactionsProvider responds to searchQueryProvider changes', () async {
    final txnBox = Hive.box<TransactionRecord>(transactionsBoxName);
    await txnBox.put('1', TransactionRecord(id: '1', kind: TxnKind.expense, categoryId: 'food', note: 'Lunch', amount: 100, date: now));
    await txnBox.put('2', TransactionRecord(id: '2', kind: TxnKind.expense, categoryId: 'transport', note: 'Bus', amount: 50, date: now));

    final container = ProviderContainer();
    addTearDown(container.dispose);
    expect(container.read(filteredTransactionsProvider).length, 2);
    container.read(searchQueryProvider.notifier).state = 'lunch';
    expect(container.read(filteredTransactionsProvider).map((t) => t.id), ['1']);
  });

  test('groupedTransactionsProvider groups by day label', () async {
    final txnBox = Hive.box<TransactionRecord>(transactionsBoxName);
    await txnBox.put('1', TransactionRecord(id: '1', kind: TxnKind.expense, categoryId: 'food', note: '', amount: 100, date: now));

    final container = ProviderContainer();
    addTearDown(container.dispose);
    final grouped = container.read(groupedTransactionsProvider);
    expect(grouped.single.key, 'Today');
    expect(grouped.single.value.single.id, '1');
  });

  test('addTxnDraftProvider pressKey builds up the amount string', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(addTxnDraftProvider.notifier);
    notifier.pressKey('3');
    notifier.pressKey('2');
    notifier.pressKey('0');
    expect(container.read(addTxnDraftProvider).amount, '320');
    notifier.pressKey('back');
    expect(container.read(addTxnDraftProvider).amount, '32');
  });

  test('sessionUnlockedProvider defaults to false (locked)', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    expect(container.read(sessionUnlockedProvider), false);
    container.read(sessionUnlockedProvider.notifier).state = true;
    expect(container.read(sessionUnlockedProvider), true);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/providers/app_state_test.dart`
Expected: FAIL — `app_state.dart` doesn't exist yet.

- [ ] **Step 3: Implement `lib/providers/app_state.dart`**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category.dart';
import '../models/transaction.dart';
import '../models/txn_kind.dart';
import '../utils/analytics.dart';
import '../utils/budget.dart';
import '../utils/date_grouping.dart';
import '../utils/filtering.dart';
import 'categories_provider.dart';
import 'settings_provider.dart';
import 'transactions_provider.dart';

enum AppTab { home, transactions, add, analytics, profile }

final currentTabProvider = StateProvider<AppTab>((ref) => AppTab.home);

/// Whether the current app session has passed the PIN-lock gate. Ignored
/// entirely when `settings.pinLockEnabled` is false. Defaults to false
/// (locked) so a fresh app start with PIN lock enabled requires unlocking;
/// the PIN-unlock screen (added later) flips this to true on success.
final sessionUnlockedProvider = StateProvider<bool>((ref) => false);

final categoriesByIdProvider = Provider<Map<String, CategoryRecord>>((ref) {
  final cats = ref.watch(categoriesProvider);
  return {for (final c in cats) c.id: c};
});

final homeSummaryProvider = Provider<HomeSummary>((ref) {
  final txns = ref.watch(transactionsProvider);
  return computeHomeSummary(txns, DateTime.now());
});

final recentTransactionsProvider = Provider<List<TransactionRecord>>((ref) {
  return ref.watch(transactionsProvider).take(3).toList();
});

final budgetPercentProvider = Provider<int>((ref) {
  final summary = ref.watch(homeSummaryProvider);
  final settings = ref.watch(settingsProvider);
  return budgetPercent(summary.expense, settings.monthlyBudget);
});

final searchQueryProvider = StateProvider<String>((ref) => '');
final selectedMonthProvider = StateProvider<DateTime?>((ref) => null);
final selectedCategoryIdProvider = StateProvider<String?>((ref) => null);
final selectedKindFilterProvider = StateProvider<TxnKind?>((ref) => null);

final filteredTransactionsProvider = Provider<List<TransactionRecord>>((ref) {
  return filterTransactions(
    ref.watch(transactionsProvider),
    query: ref.watch(searchQueryProvider),
    categoryId: ref.watch(selectedCategoryIdProvider),
    kind: ref.watch(selectedKindFilterProvider),
    month: ref.watch(selectedMonthProvider),
    categoriesById: ref.watch(categoriesByIdProvider),
  );
});

final groupedTransactionsProvider = Provider<List<MapEntry<String, List<TransactionRecord>>>>((ref) {
  final filtered = ref.watch(filteredTransactionsProvider);
  final now = DateTime.now();
  final order = <String>[];
  final map = <String, List<TransactionRecord>>{};
  for (final t in filtered) {
    final label = dayGroupLabel(t.date, now);
    (map[label] ??= []..addAll(const [])).add(t);
    if (!order.contains(label)) order.add(label);
  }
  return [for (final label in order) MapEntry(label, map[label]!)];
});

final currentMonthExpensesProvider = Provider<List<TransactionRecord>>((ref) {
  final now = DateTime.now();
  return ref.watch(transactionsProvider).where((t) =>
      t.kind == TxnKind.expense && t.date.year == now.year && t.date.month == now.month).toList();
});

final categoryBreakdownProvider = Provider<List<CategoryShare>>((ref) {
  return categoryBreakdown(ref.watch(currentMonthExpensesProvider));
});

final topSpendingCategoriesProvider = Provider<List<TopCategory>>((ref) {
  return topSpendingCategories(ref.watch(currentMonthExpensesProvider));
});

final monthlySeriesProvider = Provider<List<MonthlyTotals>>((ref) {
  return monthlySeries(ref.watch(transactionsProvider), DateTime.now());
});

class AddTxnDraft {
  final TxnKind kind;
  final String amount;
  final String? categoryId;
  final String note;
  final String? editingId;

  const AddTxnDraft({
    this.kind = TxnKind.expense,
    this.amount = '0',
    this.categoryId,
    this.note = '',
    this.editingId,
  });

  AddTxnDraft copyWith({
    TxnKind? kind,
    String? amount,
    String? categoryId,
    bool clearCategoryId = false,
    String? note,
    String? editingId,
    bool clearEditingId = false,
  }) {
    return AddTxnDraft(
      kind: kind ?? this.kind,
      amount: amount ?? this.amount,
      categoryId: clearCategoryId ? null : (categoryId ?? this.categoryId),
      note: note ?? this.note,
      editingId: clearEditingId ? null : (editingId ?? this.editingId),
    );
  }
}

class AddTxnDraftNotifier extends StateNotifier<AddTxnDraft> {
  AddTxnDraftNotifier() : super(const AddTxnDraft());

  void reset({TxnKind kind = TxnKind.expense}) => state = AddTxnDraft(kind: kind);

  void setKind(TxnKind kind) => state = state.copyWith(kind: kind, clearCategoryId: true);

  void setCategory(String id) => state = state.copyWith(categoryId: id);

  void setNote(String note) => state = state.copyWith(note: note);

  void pressKey(String k) {
    var a = state.amount;
    if (k == '.') {
      if (a.contains('.')) return;
      a = '$a.';
    } else if (k == 'back') {
      a = a.length <= 1 ? '0' : a.substring(0, a.length - 1);
    } else {
      if (a.contains('.') && a.split('.')[1].length >= 2) return;
      a = a == '0' ? k : '$a$k';
    }
    if (a.replaceAll('.', '').length > 9) return;
    state = state.copyWith(amount: a);
  }

  void loadForEdit(TransactionRecord t) {
    state = AddTxnDraft(
      kind: t.kind,
      amount: t.amount == t.amount.roundToDouble() ? t.amount.toInt().toString() : t.amount.toString(),
      categoryId: t.categoryId,
      note: t.note,
      editingId: t.id,
    );
  }
}

final addTxnDraftProvider = StateNotifierProvider<AddTxnDraftNotifier, AddTxnDraft>((ref) {
  return AddTxnDraftNotifier();
});
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/providers/app_state_test.dart`
Expected: `00:0X +5: All tests passed!`

- [ ] **Step 5: Commit**

```bash
git add lib/providers/app_state.dart test/providers/app_state_test.dart
git commit -m "feat: add derived providers for home/analytics/filtering/add-txn state"
```

---

## Task 12: Onboarding flow

**Files:**
- Create: `lib/features/onboarding/onboarding_flow.dart`
- Test: `test/features/onboarding/onboarding_flow_test.dart`

**Interfaces:**
- Consumes: `settingsProvider` (Task 10).
- Produces: `OnboardingFlow` (a `ConsumerStatefulWidget`, no constructor args)
  — a 3-step `PageView` (Welcome → Name → Salary & Budget) that calls
  `settingsProvider.notifier.completeOnboarding(...)` on finish. Keys used by
  tests: `Key('onboarding_get_started_button')`, `Key('onboarding_name_field')`,
  `Key('onboarding_name_next_button')`, `Key('onboarding_salary_field')`,
  `Key('onboarding_budget_field')`, `Key('onboarding_finish_button')`.

- [ ] **Step 1: Write the failing test**

```dart
// test/features/onboarding/onboarding_flow_test.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance_tracker/models/settings.dart';
import 'package:finance_tracker/providers/settings_provider.dart';
import 'package:finance_tracker/data/hive_boxes.dart';
import 'package:finance_tracker/features/onboarding/onboarding_flow.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('hive_test_');
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(SettingsRecordAdapter());
    final box = await Hive.openBox<SettingsRecord>(settingsBoxName);
    await box.put(settingsKey, SettingsRecord());
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    tempDir.deleteSync(recursive: true);
  });

  testWidgets('walking through all 3 steps completes onboarding with entered values', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: OnboardingFlow()),
      ),
    );

    // Step 1: Welcome
    await tester.tap(find.byKey(const Key('onboarding_get_started_button')));
    await tester.pumpAndSettle();

    // Step 2: Name
    await tester.enterText(find.byKey(const Key('onboarding_name_field')), 'Asha');
    await tester.tap(find.byKey(const Key('onboarding_name_next_button')));
    await tester.pumpAndSettle();

    // Step 3: Salary & budget
    await tester.enterText(find.byKey(const Key('onboarding_salary_field')), '60000');
    await tester.enterText(find.byKey(const Key('onboarding_budget_field')), '40000');
    await tester.tap(find.byKey(const Key('onboarding_finish_button')));
    await tester.pumpAndSettle();

    final settings = container.read(settingsProvider);
    expect(settings.userName, 'Asha');
    expect(settings.monthlySalary, 60000);
    expect(settings.monthlyBudget, 40000);
    expect(settings.onboardingComplete, true);
  });

  testWidgets('tapping Next on the name step with an empty name does not advance', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: OnboardingFlow()),
      ),
    );

    await tester.tap(find.byKey(const Key('onboarding_get_started_button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('onboarding_name_next_button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('onboarding_name_field')), findsOneWidget);
    expect(container.read(settingsProvider).onboardingComplete, false);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/onboarding/onboarding_flow_test.dart`
Expected: FAIL — `onboarding_flow.dart` doesn't exist yet.

- [ ] **Step 3: Implement `lib/features/onboarding/onboarding_flow.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/settings_provider.dart';
import '../../theme/app_theme.dart';

class OnboardingFlow extends ConsumerStatefulWidget {
  const OnboardingFlow({super.key});

  @override
  ConsumerState<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends ConsumerState<OnboardingFlow> {
  final _pageController = PageController();
  final _nameController = TextEditingController();
  final _salaryController = TextEditingController();
  final _budgetController = TextEditingController();
  String? _nameError;

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _salaryController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  void _goToStep(int i) {
    _pageController.animateToPage(i, duration: const Duration(milliseconds: 280), curve: Curves.easeOut);
  }

  void _onNameNext() {
    if (_nameController.text.trim().isEmpty) {
      setState(() => _nameError = 'Please enter your name');
      return;
    }
    setState(() => _nameError = null);
    _goToStep(2);
  }

  Future<void> _finish() async {
    final salary = double.tryParse(_salaryController.text.trim()) ?? 0;
    final budget = double.tryParse(_budgetController.text.trim()) ?? 0;
    await ref.read(settingsProvider.notifier).completeOnboarding(
          userName: _nameController.text.trim(),
          monthlySalary: salary,
          monthlyBudget: budget,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _WelcomeStep(onNext: () => _goToStep(1)),
            _NameStep(controller: _nameController, error: _nameError, onNext: _onNameNext),
            _SalaryBudgetStep(
              salaryController: _salaryController,
              budgetController: _budgetController,
              onFinish: _finish,
            ),
          ],
        ),
      ),
    );
  }
}

class _StepScaffold extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? content;
  final String buttonLabel;
  final Key buttonKey;
  final VoidCallback onPressed;

  const _StepScaffold({
    required this.title,
    required this.subtitle,
    this.content,
    required this.buttonLabel,
    required this.buttonKey,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 40, 28, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.6)),
          const SizedBox(height: 10),
          Text(subtitle, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: context.palette.textSecondary)),
          if (content != null) ...[const SizedBox(height: 32), content!],
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              key: buttonKey,
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
              child: Text(buttonLabel, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

class _WelcomeStep extends StatelessWidget {
  final VoidCallback onNext;
  const _WelcomeStep({required this.onNext});

  @override
  Widget build(BuildContext context) {
    return _StepScaffold(
      title: 'Welcome to FinTrack',
      subtitle: 'Track your spending, stick to a budget, and see where your money goes — all on your device.',
      buttonLabel: 'Get Started',
      buttonKey: const Key('onboarding_get_started_button'),
      onPressed: onNext,
    );
  }
}

class _NameStep extends StatelessWidget {
  final TextEditingController controller;
  final String? error;
  final VoidCallback onNext;
  const _NameStep({required this.controller, required this.error, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return _StepScaffold(
      title: "What's your name?",
      subtitle: "We'll use this to greet you on the Home screen.",
      content: TextField(
        key: const Key('onboarding_name_field'),
        controller: controller,
        decoration: InputDecoration(labelText: 'Your name', errorText: error),
      ),
      buttonLabel: 'Next',
      buttonKey: const Key('onboarding_name_next_button'),
      onPressed: onNext,
    );
  }
}

class _SalaryBudgetStep extends StatelessWidget {
  final TextEditingController salaryController;
  final TextEditingController budgetController;
  final Future<void> Function() onFinish;
  const _SalaryBudgetStep({
    required this.salaryController,
    required this.budgetController,
    required this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    return _StepScaffold(
      title: 'Salary & budget',
      subtitle: 'Set your monthly salary and how much you plan to spend. You can change these later in Profile.',
      content: Column(
        children: [
          TextField(
            key: const Key('onboarding_salary_field'),
            controller: salaryController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Monthly salary (₹)'),
          ),
          const SizedBox(height: 16),
          TextField(
            key: const Key('onboarding_budget_field'),
            controller: budgetController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Monthly budget (₹)'),
          ),
        ],
      ),
      buttonLabel: 'Finish',
      buttonKey: const Key('onboarding_finish_button'),
      onPressed: onFinish,
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/features/onboarding/onboarding_flow_test.dart`
Expected: `00:0X +2: All tests passed!`

- [ ] **Step 5: Commit**

```bash
git add lib/features/onboarding test/features/onboarding
git commit -m "feat: add onboarding flow (name, salary, budget)"
```

> **Note on remaining tasks' ordering:** to avoid any task referencing a
> widget/class that a later task hasn't created yet, the rest of this plan
> builds bottom-up: shared UI helpers and the 5 leaf tab screens first, then
> Profile's sub-features (which the Profile screen links to), then Profile
> itself, then the bottom-nav shell that composes all 5 screens, then the
> app entry point that composes onboarding/shell, in that order.

---

## Task 13: Shared UI helpers + Home screen

**Files:**
- Create: `lib/utils/color_utils.dart`
- Create: `lib/utils/icon_lookup.dart`
- Create: `lib/widgets/category_icon_avatar.dart`
- Create: `lib/features/home/home_screen.dart`
- Test: `test/utils/color_utils_test.dart`
- Test: `test/features/home/home_screen_test.dart`

**Interfaces:**
- Produces: `Color colorFromHex(String hex)`; `const Map<String, IconData> kIconLookup`
  and `IconData symbolFor(String name)` (unknown names fall back to
  `Symbols.category`); `CategoryIconAvatar` widget (props `iconName`, `colorHex`,
  `size = 44`, `iconSize = 23`); `HomeScreen` (a `ConsumerWidget`, no
  constructor args — reads `homeSummaryProvider`, `budgetPercentProvider`,
  `recentTransactionsProvider`, `categoriesByIdProvider`, `settingsProvider`,
  and dispatches to `addTxnDraftProvider`/`currentTabProvider` on quick-action taps).

- [ ] **Step 1: Write the failing test for `color_utils.dart`**

```dart
// test/utils/color_utils_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/utils/color_utils.dart';

void main() {
  test('parses a #RRGGBB hex string to an opaque Color', () {
    expect(colorFromHex('#F59E0B'), const Color(0xFFF59E0B));
    expect(colorFromHex('2563EB'), const Color(0xFF2563EB));
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/utils/color_utils_test.dart`
Expected: FAIL — `color_utils.dart` doesn't exist yet.

- [ ] **Step 3: Implement `lib/utils/color_utils.dart`**

```dart
import 'package:flutter/material.dart';

Color colorFromHex(String hex) {
  final cleaned = hex.replaceFirst('#', '');
  final value = int.parse(cleaned, radix: 16);
  return Color(0xFF000000 | value);
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/utils/color_utils_test.dart`
Expected: `00:0X +1: All tests passed!`

- [ ] **Step 5: Implement `lib/utils/icon_lookup.dart`**

```dart
import 'package:flutter/widgets.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Every icon used by the 15 default categories, plus a small curated set of
/// extra choices offered when a user creates a custom category.
const Map<String, IconData> kIconLookup = {
  'restaurant': Symbols.restaurant,
  'directions_bus': Symbols.directions_bus,
  'shopping_bag': Symbols.shopping_bag,
  'receipt_long': Symbols.receipt_long,
  'movie': Symbols.movie,
  'ecg_heart': Symbols.ecg_heart,
  'flight': Symbols.flight,
  'school': Symbols.school,
  'home_work': Symbols.home_work,
  'category': Symbols.category,
  'payments': Symbols.payments,
  'work': Symbols.work,
  'redeem': Symbols.redeem,
  'card_giftcard': Symbols.card_giftcard,
  'savings': Symbols.savings,
  'pets': Symbols.pets,
  'sports_esports': Symbols.sports_esports,
  'local_cafe': Symbols.local_cafe,
  'fitness_center': Symbols.fitness_center,
  'checkroom': Symbols.checkroom,
};

IconData symbolFor(String name) => kIconLookup[name] ?? Symbols.category;
```

- [ ] **Step 6: Implement `lib/widgets/category_icon_avatar.dart`**

```dart
import 'package:flutter/material.dart';
import '../utils/color_utils.dart';
import '../utils/icon_lookup.dart';

class CategoryIconAvatar extends StatelessWidget {
  final String iconName;
  final String colorHex;
  final double size;
  final double iconSize;

  const CategoryIconAvatar({
    super.key,
    required this.iconName,
    required this.colorHex,
    this.size = 44,
    this.iconSize = 23,
  });

  @override
  Widget build(BuildContext context) {
    final color = colorFromHex(colorHex);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(size * 0.32),
      ),
      alignment: Alignment.center,
      child: Icon(symbolFor(iconName), size: iconSize, color: color),
    );
  }
}
```

- [ ] **Step 7: Write the failing test for `HomeScreen`**

```dart
// test/features/home/home_screen_test.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance_tracker/models/txn_kind.dart';
import 'package:finance_tracker/models/transaction.dart';
import 'package:finance_tracker/models/category.dart';
import 'package:finance_tracker/models/settings.dart';
import 'package:finance_tracker/data/hive_boxes.dart';
import 'package:finance_tracker/data/seed_categories.dart';
import 'package:finance_tracker/providers/app_state.dart';
import 'package:finance_tracker/features/home/home_screen.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('hive_test_');
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(TxnKindAdapter());
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(TransactionRecordAdapter());
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(CategoryRecordAdapter());
    if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(SettingsRecordAdapter());
    final catBox = await Hive.openBox<CategoryRecord>(categoriesBoxName);
    await seedCategoriesIfEmpty(catBox);
    final txnBox = await Hive.openBox<TransactionRecord>(transactionsBoxName);
    await txnBox.put('1', TransactionRecord(id: '1', kind: TxnKind.expense, categoryId: 'food', note: 'Lunch at work', amount: 320, date: DateTime.now()));
    final settingsBox = await Hive.openBox<SettingsRecord>(settingsBoxName);
    await settingsBox.put(settingsKey, SettingsRecord(userName: 'Asha', monthlyBudget: 1000, onboardingComplete: true));
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    tempDir.deleteSync(recursive: true);
  });

  testWidgets('shows greeting, budget, and the recent transaction', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: HomeScreen()),
      ),
    );

    expect(find.textContaining('Asha'), findsWidgets);
    expect(find.text('Lunch at work'), findsOneWidget);
    expect(find.text('32% used'), findsOneWidget); // 320 / 1000
  });

  testWidgets('empty state: no recent transactions', (tester) async {
    await Hive.box<TransactionRecord>(transactionsBoxName).clear();
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    expect(find.text('Lunch at work'), findsNothing);
  });

  testWidgets('tapping Add Expense sets the add-tab and expense draft kind', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.tap(find.text('Add Expense'));
    await tester.pump();
    expect(container.read(currentTabProvider), AppTab.add);
    expect(container.read(addTxnDraftProvider).kind, TxnKind.expense);
  });
}
```

- [ ] **Step 8: Run test to verify it fails**

Run: `flutter test test/features/home/home_screen_test.dart`
Expected: FAIL — `home_screen.dart` doesn't exist yet.

- [ ] **Step 9: Implement `lib/features/home/home_screen.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../models/txn_kind.dart';
import '../../providers/app_state.dart';
import '../../providers/settings_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/currency.dart';
import '../../widgets/category_icon_avatar.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(homeSummaryProvider);
    final budgetPct = ref.watch(budgetPercentProvider);
    final recent = ref.watch(recentTransactionsProvider);
    final categoriesById = ref.watch(categoriesByIdProvider);
    final settings = ref.watch(settingsProvider);
    final palette = context.palette;

    void goToAdd(TxnKind kind) {
      ref.read(addTxnDraftProvider.notifier).reset(kind: kind);
      ref.read(currentTabProvider.notifier).state = AppTab.add;
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 130),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Good Morning', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: palette.textSecondary)),
                      const SizedBox(height: 2),
                      Text('${settings.userName} 👋', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -0.4)),
                    ],
                  ),
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(color: palette.surface, shape: BoxShape.circle, border: Border.all(color: palette.border)),
                    child: Stack(
                      children: [
                        Center(child: Icon(Symbols.notifications, size: 24, color: palette.textSecondary)),
                        Positioned(
                          top: 11,
                          right: 12,
                          child: Container(width: 8, height: 8, decoration: BoxDecoration(color: AppColors.danger, shape: BoxShape.circle, border: Border.all(color: palette.surface, width: 2))),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            _BalanceHero(balance: summary.balance, income: summary.income, expense: summary.expense, savings: summary.savings),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(child: _QuickAction(label: 'Add Expense', icon: Symbols.remove, color: AppColors.danger, onTap: () => goToAdd(TxnKind.expense))),
                const SizedBox(width: 12),
                Expanded(child: _QuickAction(label: 'Add Income', icon: Symbols.add, color: AppColors.success, onTap: () => goToAdd(TxnKind.income))),
              ],
            ),
            const SizedBox(height: 18),
            _BudgetCard(budgetLabel: formatInr(settings.monthlyBudget), spent: summary.expense, budget: settings.monthlyBudget, pct: budgetPct),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Recent Transactions', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, letterSpacing: -0.3)),
                TextButton(
                  onPressed: () => ref.read(currentTabProvider.notifier).state = AppTab.transactions,
                  child: const Text('See all', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.accent)),
                ),
              ],
            ),
            Container(
              decoration: BoxDecoration(color: palette.surface, border: Border.all(color: palette.border), borderRadius: BorderRadius.circular(24)),
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
              child: recent.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: Text('No transactions yet', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: palette.textSecondary))),
                    )
                  : Column(
                      children: [
                        for (final t in recent)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
                            child: Row(
                              children: [
                                CategoryIconAvatar(
                                  iconName: categoriesById[t.categoryId]?.iconName ?? 'category',
                                  colorHex: categoriesById[t.categoryId]?.colorHex ?? '#94A3B8',
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(categoriesById[t.categoryId]?.name ?? t.categoryId, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                                      Text(t.note, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: palette.textSecondary)),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${t.kind == TxnKind.income ? '+' : '−'}${formatInr(t.amount)}',
                                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: t.kind == TxnKind.income ? AppColors.success : null),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BalanceHero extends StatelessWidget {
  final double balance, income, expense, savings;
  const _BalanceHero({required this.balance, required this.income, required this.expense, required this.savings});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 26, 24, 26),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.accent, Color(0xFF1E40AF)]),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Available Balance', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white70)),
          const SizedBox(height: 6),
          Text(formatInr(balance), style: const TextStyle(fontSize: 44, fontWeight: FontWeight.w800, letterSpacing: -1.5, color: Colors.white)),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(child: _HeroTile(label: 'Income', value: formatInr(income), icon: Symbols.arrow_downward)),
              const SizedBox(width: 10),
              Expanded(child: _HeroTile(label: 'Expenses', value: formatInr(expense), icon: Symbols.arrow_upward)),
              const SizedBox(width: 10),
              Expanded(child: _HeroTile(label: 'Savings', value: formatInr(savings), icon: Symbols.savings)),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroTile extends StatelessWidget {
  final String label, value;
  final IconData icon;
  const _HeroTile({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 13),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.13), borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Icon(icon, size: 15, color: Colors.white70), const SizedBox(width: 5), Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white70))]),
          const SizedBox(height: 5),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _QuickAction({required this.label, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Material(
      color: palette.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), border: Border.all(color: palette.border)),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(color: color.withOpacity(0.14), borderRadius: BorderRadius.circular(11)),
                child: Icon(icon, size: 20, color: color),
              ),
              const SizedBox(width: 10),
              Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}

class _BudgetCard extends StatelessWidget {
  final String budgetLabel;
  final double spent, budget;
  final int pct;
  const _BudgetCard({required this.budgetLabel, required this.spent, required this.budget, required this.pct});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: palette.surface, border: Border.all(color: palette.border), borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.16), borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Symbols.account_balance_wallet, size: 22, color: AppColors.accent),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Monthly Budget', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                      Text('$budgetLabel limit', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: palette.textSecondary)),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.16), borderRadius: BorderRadius.circular(20)),
                child: Text('$pct% used', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.accent)),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (pct / 100).clamp(0, 1),
              minHeight: 12,
              backgroundColor: palette.surfaceAlt,
              valueColor: const AlwaysStoppedAnimation(AppColors.accent),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Spent', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: palette.textSecondary)),
                  Text(formatInr(spent), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Remaining', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: palette.textSecondary)),
                  Text(formatInr(budget - spent), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.success)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 10: Run tests to verify they pass**

Run: `flutter test test/features/home/home_screen_test.dart`
Expected: `00:0X +3: All tests passed!`

- [ ] **Step 11: Commit**

```bash
git add lib/utils/color_utils.dart lib/utils/icon_lookup.dart lib/widgets/category_icon_avatar.dart lib/features/home test/utils/color_utils_test.dart test/features/home
git commit -m "feat: add shared icon/color helpers and the Home screen"
```

---

## Task 14: Transactions screen

**Files:**
- Create: `lib/features/transactions/transactions_screen.dart`
- Create: `lib/features/transactions/transaction_row.dart`
- Test: `test/features/transactions/transactions_screen_test.dart`

**Interfaces:**
- Consumes: `groupedTransactionsProvider`, `filteredTransactionsProvider`,
  `searchQueryProvider`, `selectedMonthProvider`, `selectedCategoryIdProvider`,
  `selectedKindFilterProvider`, `categoriesByIdProvider` (Task 11);
  `transactionsProvider` (Task 9, for delete); `addTxnDraftProvider`,
  `currentTabProvider` (Task 11, for edit navigation); `CategoryIconAvatar`
  (Task 13); `flutter_slidable`.
- Produces: `TransactionsScreen` (`ConsumerWidget`, no args);
  `TransactionRow` (`ConsumerWidget`, prop `txn`) rendering a `Slidable` with
  a start (right-swipe) Edit action and an end (left-swipe) Delete action.

- [ ] **Step 1: Write the failing test**

```dart
// test/features/transactions/transactions_screen_test.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance_tracker/models/txn_kind.dart';
import 'package:finance_tracker/models/transaction.dart';
import 'package:finance_tracker/models/category.dart';
import 'package:finance_tracker/models/settings.dart';
import 'package:finance_tracker/data/hive_boxes.dart';
import 'package:finance_tracker/data/seed_categories.dart';
import 'package:finance_tracker/providers/transactions_provider.dart';
import 'package:finance_tracker/providers/app_state.dart';
import 'package:finance_tracker/features/transactions/transactions_screen.dart';

Future<void> _seed() async {
  final catBox = await Hive.openBox<CategoryRecord>(categoriesBoxName);
  await seedCategoriesIfEmpty(catBox);
  final txnBox = await Hive.openBox<TransactionRecord>(transactionsBoxName);
  await txnBox.put('1', TransactionRecord(id: '1', kind: TxnKind.expense, categoryId: 'food', note: 'Lunch at work', amount: 320, date: DateTime.now()));
  await Hive.openBox<SettingsRecord>(settingsBoxName);
}

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('hive_test_');
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(TxnKindAdapter());
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(TransactionRecordAdapter());
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(CategoryRecordAdapter());
    if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(SettingsRecordAdapter());
    await _seed();
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    tempDir.deleteSync(recursive: true);
  });

  testWidgets('shows the seeded transaction grouped under Today', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const MaterialApp(home: TransactionsScreen())));
    expect(find.text('TODAY'), findsOneWidget);
    expect(find.text('Lunch at work'), findsOneWidget);
  });

  testWidgets('typing in the search box filters the list', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const MaterialApp(home: TransactionsScreen())));
    await tester.enterText(find.byType(TextField), 'zzz-no-match');
    await tester.pump();
    expect(find.text('No transactions found'), findsOneWidget);
  });

  testWidgets('empty state renders when there are no transactions at all', (tester) async {
    await Hive.box<TransactionRecord>(transactionsBoxName).clear();
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const MaterialApp(home: TransactionsScreen())));
    expect(find.text('No transactions found'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/transactions/transactions_screen_test.dart`
Expected: FAIL — `transactions_screen.dart` doesn't exist yet.

- [ ] **Step 3: Implement `lib/features/transactions/transaction_row.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../models/transaction.dart';
import '../../models/txn_kind.dart';
import '../../providers/app_state.dart';
import '../../providers/transactions_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/currency.dart';
import '../../widgets/category_icon_avatar.dart';

class TransactionRow extends ConsumerWidget {
  final TransactionRecord txn;
  const TransactionRow({super.key, required this.txn});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesById = ref.watch(categoriesByIdProvider);
    final cat = categoriesById[txn.categoryId];
    final palette = context.palette;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Slidable(
        key: ValueKey(txn.id),
        startActionPane: ActionPane(
          motion: const DrawerMotion(),
          extentRatio: 0.28,
          children: [
            SlidableAction(
              onPressed: (_) {
                ref.read(addTxnDraftProvider.notifier).loadForEdit(txn);
                ref.read(currentTabProvider.notifier).state = AppTab.add;
              },
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              icon: Icons.edit,
              label: 'Edit',
              borderRadius: BorderRadius.circular(20),
            ),
          ],
        ),
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          extentRatio: 0.28,
          children: [
            SlidableAction(
              onPressed: (_) => ref.read(transactionsProvider.notifier).delete(txn.id),
              backgroundColor: AppColors.dangerStrong,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: 'Delete',
              borderRadius: BorderRadius.circular(20),
            ),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(color: palette.surface, border: Border.all(color: palette.border), borderRadius: BorderRadius.circular(20)),
          child: Row(
            children: [
              CategoryIconAvatar(iconName: cat?.iconName ?? 'category', colorHex: cat?.colorHex ?? '#94A3B8'),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(cat?.name ?? txn.categoryId, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                    Text(txn.note, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: palette.textSecondary)),
                  ],
                ),
              ),
              Text(
                '${txn.kind == TxnKind.income ? '+' : '−'}${formatInr(txn.amount)}',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: txn.kind == TxnKind.income ? AppColors.success : null),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Implement `lib/features/transactions/transactions_screen.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../models/txn_kind.dart';
import '../../providers/app_state.dart';
import '../../theme/app_theme.dart';
import 'transaction_row.dart';

class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final grouped = ref.watch(groupedTransactionsProvider);
    final palette = context.palette;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Text('Transactions', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: -0.6)),
            ),
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(color: palette.surface, border: Border.all(color: palette.border), borderRadius: BorderRadius.circular(16)),
              child: Row(
                children: [
                  Icon(Symbols.search, size: 22, color: palette.textTertiary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      onChanged: (v) => ref.read(searchQueryProvider.notifier).state = v,
                      decoration: const InputDecoration(border: InputBorder.none, hintText: 'Search transactions'),
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const _FilterChipsRow(),
            const SizedBox(height: 14),
            Expanded(
              child: grouped.isEmpty
                  ? _EmptyState(palette: palette)
                  : ListView(
                      children: [
                        for (final entry in grouped) ...[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(2, 18, 2, 10),
                            child: Text(entry.key.toUpperCase(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: palette.textTertiary, letterSpacing: 0.8)),
                          ),
                          for (final t in entry.value) TransactionRow(txn: t),
                        ],
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 26),
                          child: Center(child: Text('Swipe a row left to delete, right to edit', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: palette.textQuaternary))),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final AppPalette palette;
  const _EmptyState({required this.palette});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(color: palette.surface, border: Border.all(color: palette.border), borderRadius: BorderRadius.circular(30)),
              child: Icon(Symbols.search_off, size: 46, color: palette.textQuaternary),
            ),
            const SizedBox(height: 22),
            const Text('No transactions found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text('Try a different search term or clear your filters to see everything.', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: palette.textSecondary, height: 1.5)),
          ],
        ),
      ),
    );
  }
}

class _FilterChipsRow extends ConsumerWidget {
  const _FilterChipsRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(selectedMonthProvider);
    final categoryId = ref.watch(selectedCategoryIdProvider);
    final kind = ref.watch(selectedKindFilterProvider);
    final categories = ref.watch(categoriesByIdProvider).values.toList();
    final palette = context.palette;

    Widget chip(String label, bool active, VoidCallback onTap) {
      return Padding(
        padding: const EdgeInsets.only(right: 9),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: active ? AppColors.accent.withOpacity(0.16) : palette.surface,
              border: Border.all(color: active ? AppColors.accent : palette.border),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: active ? AppColors.accent : null)),
                const Icon(Icons.expand_more, size: 16),
              ],
            ),
          ),
        ),
      );
    }

    Future<void> pickMonth() async {
      final now = DateTime.now();
      final options = <DateTime?>[null, for (var i = 0; i < 6; i++) DateTime(now.year, now.month - i, 1)];
      final choice = await showModalBottomSheet<DateTime?>(
        context: context,
        builder: (_) => ListView(
          shrinkWrap: true,
          children: [
            for (final m in options)
              ListTile(
                title: Text(m == null ? 'All months' : '${m.month}/${m.year}'),
                onTap: () => Navigator.pop(context, m),
              ),
          ],
        ),
      );
      ref.read(selectedMonthProvider.notifier).state = choice;
    }

    Future<void> pickCategory() async {
      final choice = await showModalBottomSheet<String?>(
        context: context,
        builder: (_) => ListView(
          shrinkWrap: true,
          children: [
            const ListTile(title: Text('All Categories')),
            for (final c in categories) ListTile(title: Text(c.name), onTap: () => Navigator.pop(context, c.id)),
          ],
        ),
      );
      ref.read(selectedCategoryIdProvider.notifier).state = choice;
    }

    Future<void> pickType() async {
      final choice = await showModalBottomSheet<int?>(
        context: context,
        builder: (_) => ListView(
          shrinkWrap: true,
          children: [
            ListTile(title: const Text('All Types'), onTap: () => Navigator.pop(context, -1)),
            ListTile(title: const Text('Income'), onTap: () => Navigator.pop(context, 1)),
            ListTile(title: const Text('Expense'), onTap: () => Navigator.pop(context, 0)),
          ],
        ),
      );
      if (choice == null) return;
      ref.read(selectedKindFilterProvider.notifier).state = choice == -1 ? null : TxnKind.values[choice];
    }

    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          chip(month == null ? 'All Months' : '${month.month}/${month.year}', month != null, pickMonth),
          chip(categoryId == null ? 'All Categories' : (categories.where((c) => c.id == categoryId).isEmpty ? 'Category' : categories.firstWhere((c) => c.id == categoryId).name), categoryId != null, pickCategory),
          chip(kind == null ? 'All Types' : (kind == TxnKind.income ? 'Income' : 'Expense'), kind != null, pickType),
        ],
      ),
    );
  }
}
```

- [ ] **Step 5: Run tests to verify they pass**

Run: `flutter test test/features/transactions/transactions_screen_test.dart`
Expected: `00:0X +3: All tests passed!`

- [ ] **Step 6: Commit**

```bash
git add lib/features/transactions test/features/transactions
git commit -m "feat: add Transactions screen with search, filters, and swipe actions"
```

---

## Task 15: Add Transaction screen

**Files:**
- Create: `lib/features/add_transaction/add_transaction_screen.dart`
- Test: `test/features/add_transaction/add_transaction_screen_test.dart`

**Interfaces:**
- Consumes: `addTxnDraftProvider` (Task 11, for kind/amount/category/note/editingId
  and `pressKey`/`setKind`/`setCategory`/`setNote`); `categoriesProvider`
  (Task 9, filtered by kind); `transactionsProvider` (Task 9, `add`/`update`);
  `currentTabProvider` (Task 11); `formatInr`, `groupIndianDigits` (Task 4);
  `CategoryIconAvatar` (Task 13); `uuid` package.
- Produces: `AddTransactionScreen` (`ConsumerWidget`, no args).

- [ ] **Step 1: Write the failing test**

```dart
// test/features/add_transaction/add_transaction_screen_test.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance_tracker/models/txn_kind.dart';
import 'package:finance_tracker/models/transaction.dart';
import 'package:finance_tracker/models/category.dart';
import 'package:finance_tracker/data/hive_boxes.dart';
import 'package:finance_tracker/data/seed_categories.dart';
import 'package:finance_tracker/providers/transactions_provider.dart';
import 'package:finance_tracker/providers/app_state.dart';
import 'package:finance_tracker/features/add_transaction/add_transaction_screen.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('hive_test_');
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(TxnKindAdapter());
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(TransactionRecordAdapter());
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(CategoryRecordAdapter());
    final catBox = await Hive.openBox<CategoryRecord>(categoriesBoxName);
    await seedCategoriesIfEmpty(catBox);
    await Hive.openBox<TransactionRecord>(transactionsBoxName);
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    tempDir.deleteSync(recursive: true);
  });

  testWidgets('tapping amount without entering one shows a validation toast', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const MaterialApp(home: AddTransactionScreen())));
    await tester.tap(find.text('Save Transaction'));
    await tester.pump();
    expect(find.text('Enter an amount first'), findsOneWidget);
    expect(container.read(transactionsProvider), isEmpty);
  });

  testWidgets('entering an amount via the keypad, picking a category, and saving adds a transaction', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const MaterialApp(home: AddTransactionScreen())));

    await tester.tap(find.text('3'));
    await tester.tap(find.text('2'));
    await tester.tap(find.text('0'));
    await tester.pump();
    expect(find.text('₹320'), findsOneWidget);

    await tester.tap(find.text('Food'));
    await tester.tap(find.text('Save Transaction'));
    await tester.pump();

    final txns = container.read(transactionsProvider);
    expect(txns.length, 1);
    expect(txns.single.amount, 320);
    expect(txns.single.categoryId, 'food');
    expect(container.read(currentTabProvider), AppTab.transactions);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/add_transaction/add_transaction_screen_test.dart`
Expected: FAIL — `add_transaction_screen.dart` doesn't exist yet.

- [ ] **Step 3: Implement `lib/features/add_transaction/add_transaction_screen.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:uuid/uuid.dart';
import '../../models/transaction.dart';
import '../../models/txn_kind.dart';
import '../../providers/app_state.dart';
import '../../providers/categories_provider.dart';
import '../../providers/transactions_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/currency.dart';
import '../../widgets/category_icon_avatar.dart';

const _uuid = Uuid();
const _keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '.', '0', 'back'];

class AddTransactionScreen extends ConsumerWidget {
  const AddTransactionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(addTxnDraftProvider);
    final notifier = ref.read(addTxnDraftProvider.notifier);
    final allCategories = ref.watch(categoriesProvider);
    final categories = allCategories.where((c) => c.kind == draft.kind).toList();
    final palette = context.palette;

    final parts = draft.amount.split('.');
    final wholeDisplay = groupIndianDigits(parts.first.isEmpty ? '0' : parts.first);
    final amountDisplay = '₹$wholeDisplay${parts.length > 1 ? '.${parts[1]}' : ''}';

    void save() {
      final amount = double.tryParse(draft.amount) ?? 0;
      if (amount <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter an amount first')));
        return;
      }
      final categoryId = draft.categoryId ?? (draft.kind == TxnKind.income ? 'salary' : 'food');
      final txn = TransactionRecord(
        id: draft.editingId ?? _uuid.v4(),
        kind: draft.kind,
        categoryId: categoryId,
        note: draft.note.isEmpty ? categoryId : draft.note,
        amount: amount,
        date: DateTime.now(),
      );
      if (draft.editingId != null) {
        ref.read(transactionsProvider.notifier).update(txn);
      } else {
        ref.read(transactionsProvider.notifier).add(txn);
      }
      notifier.reset();
      ref.read(currentTabProvider.notifier).state = AppTab.transactions;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(draft.kind == TxnKind.income ? 'Income added' : 'Expense added')),
      );
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 130),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => ref.read(currentTabProvider.notifier).state = AppTab.home,
                  icon: const Icon(Symbols.arrow_back),
                ),
                const Text('Add Transaction', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              ],
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 14),
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(color: palette.surface, border: Border.all(color: palette.border), borderRadius: BorderRadius.circular(16)),
              child: Row(
                children: [
                  Expanded(child: _SegButton(label: 'Expense', icon: Symbols.south_west, active: draft.kind == TxnKind.expense, onTap: () => notifier.setKind(TxnKind.expense))),
                  Expanded(child: _SegButton(label: 'Income', icon: Symbols.north_east, active: draft.kind == TxnKind.income, onTap: () => notifier.setKind(TxnKind.income))),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 26),
              child: Center(
                child: Column(
                  children: [
                    Text(draft.kind == TxnKind.income ? 'Income amount' : 'Expense amount', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: palette.textSecondary)),
                    const SizedBox(height: 8),
                    Text(amountDisplay, style: TextStyle(fontSize: 54, fontWeight: FontWeight.w800, letterSpacing: -2, color: draft.amount == '0' ? palette.textQuaternary : null)),
                  ],
                ),
              ),
            ),
            Text('CATEGORY', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: palette.textTertiary, letterSpacing: 0.6)),
            const SizedBox(height: 12),
            SizedBox(
              height: 84,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  for (final c in categories)
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: GestureDetector(
                        onTap: () => notifier.setCategory(c.id),
                        child: SizedBox(
                          width: 68,
                          child: Column(
                            children: [
                              Opacity(
                                opacity: draft.categoryId == c.id ? 1 : 0.7,
                                child: CategoryIconAvatar(iconName: c.iconName, colorHex: c.colorHex, size: 48, iconSize: 25),
                              ),
                              const SizedBox(height: 8),
                              Text(c.name, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: draft.categoryId == c.id ? null : palette.textSecondary)),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 20),
              decoration: BoxDecoration(color: palette.surface, border: Border.all(color: palette.border), borderRadius: BorderRadius.circular(20)),
              child: TextField(
                onChanged: notifier.setNote,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Symbols.notes),
                  hintText: 'Add a note (optional)',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 18),
                ),
              ),
            ),
            const SizedBox(height: 20),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.4,
              children: [
                for (final k in _keys)
                  Material(
                    color: palette.surface,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => notifier.pressKey(k),
                      child: Center(
                        child: k == 'back'
                            ? const Icon(Symbols.backspace, size: 26)
                            : Text(k, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton.icon(
                onPressed: save,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
                icon: const Icon(Symbols.check_circle, color: Colors.white),
                label: const Text('Save Transaction', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SegButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;
  const _SegButton({required this.label, required this.icon, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? AppColors.accent : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          height: 44,
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 19, color: active ? Colors.white : context.palette.textSecondary),
              const SizedBox(width: 7),
              Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: active ? Colors.white : context.palette.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `flutter test test/features/add_transaction/add_transaction_screen_test.dart`
Expected: `00:0X +2: All tests passed!`

- [ ] **Step 5: Commit**

```bash
git add lib/features/add_transaction test/features/add_transaction
git commit -m "feat: add the Add Transaction screen with keypad and category picker"
```

---

## Task 16: Analytics screen

**Files:**
- Create: `lib/features/analytics/analytics_screen.dart`
- Test: `test/features/analytics/analytics_screen_test.dart`

**Interfaces:**
- Consumes: `categoryBreakdownProvider`, `topSpendingCategoriesProvider`,
  `monthlySeriesProvider`, `homeSummaryProvider`, `currentMonthExpensesProvider`,
  `categoriesByIdProvider` (Task 11); `transactionsProvider` (Task 9, to
  detect the fully-empty case); `formatInr` (Task 4); `fl_chart`.
- Produces: `AnalyticsScreen` (`ConsumerWidget`, no args). Shows a single
  empty-state message instead of the charts when there are no transactions
  at all (fresh install, before the user logs anything).

- [ ] **Step 1: Write the failing test**

```dart
// test/features/analytics/analytics_screen_test.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance_tracker/models/txn_kind.dart';
import 'package:finance_tracker/models/transaction.dart';
import 'package:finance_tracker/models/category.dart';
import 'package:finance_tracker/data/hive_boxes.dart';
import 'package:finance_tracker/data/seed_categories.dart';
import 'package:finance_tracker/features/analytics/analytics_screen.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('hive_test_');
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(TxnKindAdapter());
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(TransactionRecordAdapter());
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(CategoryRecordAdapter());
    final catBox = await Hive.openBox<CategoryRecord>(categoriesBoxName);
    await seedCategoriesIfEmpty(catBox);
    await Hive.openBox<TransactionRecord>(transactionsBoxName);
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    tempDir.deleteSync(recursive: true);
  });

  testWidgets('shows an empty state when there are no transactions yet', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const MaterialApp(home: AnalyticsScreen())));
    expect(find.textContaining('Add a transaction'), findsOneWidget);
  });

  testWidgets('renders charts and category breakdown once data exists', (tester) async {
    final txnBox = Hive.box<TransactionRecord>(transactionsBoxName);
    final now = DateTime.now();
    await txnBox.put('1', TransactionRecord(id: '1', kind: TxnKind.expense, categoryId: 'food', note: '', amount: 500, date: now));
    await txnBox.put('2', TransactionRecord(id: '2', kind: TxnKind.income, categoryId: 'salary', note: '', amount: 2000, date: now));

    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const MaterialApp(home: AnalyticsScreen())));

    expect(find.text('Food'), findsWidgets);
    expect(find.text('Income vs Expense'), findsOneWidget);
    expect(find.text('Category Breakdown'), findsOneWidget);
    expect(find.text('Monthly Trend'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/analytics/analytics_screen_test.dart`
Expected: FAIL — `analytics_screen.dart` doesn't exist yet.

- [ ] **Step 3: Implement `lib/features/analytics/analytics_screen.dart`**

```dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../providers/app_state.dart';
import '../../providers/transactions_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/color_utils.dart';
import '../../utils/currency.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasAnyTransactions = ref.watch(transactionsProvider).isNotEmpty;
    final palette = context.palette;

    if (!hasAnyTransactions) {
      return SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Symbols.bar_chart_4_bars, size: 46, color: palette.textQuaternary),
                const SizedBox(height: 16),
                const Text('No analytics yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text('Add a transaction to see your spending overview here.', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: palette.textSecondary)),
              ],
            ),
          ),
        ),
      );
    }

    final summary = ref.watch(homeSummaryProvider);
    final breakdown = ref.watch(categoryBreakdownProvider);
    final topCats = ref.watch(topSpendingCategoriesProvider);
    final series = ref.watch(monthlySeriesProvider);
    final categoriesById = ref.watch(categoriesByIdProvider);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 130),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Text('Analytics', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: -0.6)),
            ),
            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Income vs Expense', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 180,
                    child: BarChart(
                      BarChartData(
                        gridData: const FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        titlesData: FlTitlesData(
                          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (v, meta) {
                                final i = v.toInt();
                                if (i < 0 || i >= series.length) return const SizedBox.shrink();
                                const monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                                return Text(monthNames[series[i].month.month - 1], style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600));
                              },
                            ),
                          ),
                        ),
                        barGroups: [
                          for (var i = 0; i < series.length; i++)
                            BarChartGroupData(x: i, barRods: [
                              BarChartRodData(toY: series[i].income, color: AppColors.accent, width: 8, borderRadius: BorderRadius.circular(4)),
                              BarChartRodData(toY: series[i].expense, color: const Color(0xFF475569), width: 8, borderRadius: BorderRadius.circular(4)),
                            ]),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Category Breakdown', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 140,
                        height: 140,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            PieChart(
                              PieChartData(
                                sectionsSpace: 2,
                                centerSpaceRadius: 50,
                                sections: [
                                  for (final b in breakdown)
                                    PieChartSectionData(
                                      value: b.amount,
                                      color: colorFromHex(categoriesById[b.categoryId]?.colorHex ?? '#94A3B8'),
                                      showTitle: false,
                                      radius: 20,
                                    ),
                                ],
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Total', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: palette.textSecondary)),
                                Text(formatInr(summary.expense), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          children: [
                            for (final b in breakdown)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 11),
                                child: Row(
                                  children: [
                                    Container(width: 10, height: 10, decoration: BoxDecoration(color: colorFromHex(categoriesById[b.categoryId]?.colorHex ?? '#94A3B8'), borderRadius: BorderRadius.circular(3))),
                                    const SizedBox(width: 9),
                                    Expanded(child: Text(categoriesById[b.categoryId]?.name ?? b.categoryId, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
                                    Text('${b.percent.round()}%', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Top Spending Categories', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 16),
                  for (final c in topCats)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(categoriesById[c.categoryId]?.name ?? c.categoryId, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                              Text(formatInr(c.amount), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: c.barFraction.clamp(0, 1),
                              minHeight: 8,
                              backgroundColor: palette.surfaceAlt,
                              valueColor: AlwaysStoppedAnimation(colorFromHex(categoriesById[c.categoryId]?.colorHex ?? '#94A3B8')),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Monthly Trend', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                  Text('Savings over the last 6 months', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: palette.textSecondary)),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 150,
                    child: LineChart(
                      LineChartData(
                        gridData: const FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        titlesData: FlTitlesData(
                          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (v, meta) {
                                final i = v.toInt();
                                if (i < 0 || i >= series.length) return const SizedBox.shrink();
                                const monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                                return Text(monthNames[series[i].month.month - 1], style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600));
                              },
                            ),
                          ),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            spots: [for (var i = 0; i < series.length; i++) FlSpot(i.toDouble(), series[i].savings)],
                            isCurved: true,
                            color: AppColors.accent,
                            barWidth: 3,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(show: true, color: AppColors.accent.withOpacity(0.2)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF16A34A), Color(0xFF065F46)]),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(children: [Icon(Symbols.trending_up, size: 20, color: Colors.white), SizedBox(width: 8), Text('Total Savings This Month', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white))]),
                  const SizedBox(height: 8),
                  Text(formatInr(summary.savings), style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w800, letterSpacing: -1, color: Colors.white)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: palette.surface, border: Border.all(color: palette.border), borderRadius: BorderRadius.circular(24)),
      child: child,
    );
  }
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `flutter test test/features/analytics/analytics_screen_test.dart`
Expected: `00:0X +2: All tests passed!`

- [ ] **Step 5: Commit**

```bash
git add lib/features/analytics test/features/analytics
git commit -m "feat: add Analytics screen with charts and empty state"
```

---

## Task 17: PIN lock (repository + setup/unlock screens)

**Files:**
- Create: `lib/providers/pin_provider.dart`
- Create: `lib/features/pin/pin_setup_screen.dart`
- Create: `lib/features/pin/pin_unlock_screen.dart`
- Test: `test/features/pin/pin_setup_screen_test.dart`
- Test: `test/features/pin/pin_unlock_screen_test.dart`

**Interfaces:**
- Consumes: `settingsProvider` (Task 10); `sessionUnlockedProvider` (Task 11).
- Produces: `PinRepository` (abstract: `hasPin()`, `setPin(String)`,
  `verifyPin(String)`, `clearPin()`); `SecureStoragePinRepository` (prod impl
  using `flutter_secure_storage`, key `'app_pin'`, PIN stored as plain digits
  — the OS Keychain/Keystore already encrypts secure-storage contents at
  rest, so no extra hashing dependency is needed for a 4-digit app lock);
  `pinRepositoryProvider -> Provider<PinRepository>`; `PinSetupScreen`
  (`ConsumerStatefulWidget`, no args, keys `pin_setup_pin_field`,
  `pin_setup_confirm_field`, `pin_setup_save_button`) — on success, saves the
  PIN, calls `settingsProvider.notifier.setPinLockEnabled(true)`, sets
  `sessionUnlockedProvider` to `true`, and pops the route; `PinUnlockScreen`
  (`ConsumerStatefulWidget`, no args, keys `pin_unlock_field`,
  `pin_unlock_button`) — on correct PIN sets `sessionUnlockedProvider` to
  `true`.

`SecureStoragePinRepository` is a thin, logic-free delegate to
`flutter_secure_storage`'s platform channel — it is not unit tested directly
(that would just be testing the third-party plugin); its contract is
exercised through the two screens below via a `FakePinRepository` test double.

- [ ] **Step 1: Write the failing tests**

```dart
// test/features/pin/pin_setup_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance_tracker/providers/pin_provider.dart';
import 'package:finance_tracker/providers/settings_provider.dart';
import 'package:finance_tracker/providers/app_state.dart';
import 'package:finance_tracker/features/pin/pin_setup_screen.dart';

class _FakePinRepository implements PinRepository {
  String? pin;
  @override
  Future<bool> hasPin() async => pin != null;
  @override
  Future<void> setPin(String p) async => pin = p;
  @override
  Future<bool> verifyPin(String p) async => pin == p;
  @override
  Future<void> clearPin() async => pin = null;
}

void main() {
  testWidgets('mismatched PINs show an error and do not save', (tester) async {
    final fake = _FakePinRepository();
    final container = ProviderContainer(overrides: [pinRepositoryProvider.overrideWithValue(fake)]);
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const MaterialApp(home: PinSetupScreen())));

    await tester.enterText(find.byKey(const Key('pin_setup_pin_field')), '1234');
    await tester.enterText(find.byKey(const Key('pin_setup_confirm_field')), '4321');
    await tester.tap(find.byKey(const Key('pin_setup_save_button')));
    await tester.pump();

    expect(find.text('PINs do not match'), findsOneWidget);
    expect(fake.pin, isNull);
  });

  testWidgets('matching 4-digit PINs save, enable PIN lock, and unlock the session', (tester) async {
    final fake = _FakePinRepository();
    final container = ProviderContainer(overrides: [pinRepositoryProvider.overrideWithValue(fake)]);
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(home: Navigator(onGenerateRoute: (_) => MaterialPageRoute(builder: (_) => const PinSetupScreen()))),
      ),
    );

    await tester.enterText(find.byKey(const Key('pin_setup_pin_field')), '1234');
    await tester.enterText(find.byKey(const Key('pin_setup_confirm_field')), '1234');
    await tester.tap(find.byKey(const Key('pin_setup_save_button')));
    await tester.pumpAndSettle();

    expect(fake.pin, '1234');
    expect(container.read(settingsProvider).pinLockEnabled, true);
    expect(container.read(sessionUnlockedProvider), true);
  });
}
```

```dart
// test/features/pin/pin_unlock_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance_tracker/providers/pin_provider.dart';
import 'package:finance_tracker/providers/app_state.dart';
import 'package:finance_tracker/features/pin/pin_unlock_screen.dart';

class _FakePinRepository implements PinRepository {
  String? pin;
  _FakePinRepository(this.pin);
  @override
  Future<bool> hasPin() async => pin != null;
  @override
  Future<void> setPin(String p) async => pin = p;
  @override
  Future<bool> verifyPin(String p) async => pin == p;
  @override
  Future<void> clearPin() async => pin = null;
}

void main() {
  testWidgets('wrong PIN shows an error and leaves the session locked', (tester) async {
    final fake = _FakePinRepository('1234');
    final container = ProviderContainer(overrides: [pinRepositoryProvider.overrideWithValue(fake)]);
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const MaterialApp(home: PinUnlockScreen())));

    await tester.enterText(find.byKey(const Key('pin_unlock_field')), '0000');
    await tester.tap(find.byKey(const Key('pin_unlock_button')));
    await tester.pump();

    expect(find.text('Incorrect PIN'), findsOneWidget);
    expect(container.read(sessionUnlockedProvider), false);
  });

  testWidgets('correct PIN unlocks the session', (tester) async {
    final fake = _FakePinRepository('1234');
    final container = ProviderContainer(overrides: [pinRepositoryProvider.overrideWithValue(fake)]);
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const MaterialApp(home: PinUnlockScreen())));

    await tester.enterText(find.byKey(const Key('pin_unlock_field')), '1234');
    await tester.tap(find.byKey(const Key('pin_unlock_button')));
    await tester.pump();

    expect(container.read(sessionUnlockedProvider), true);
  });
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `flutter test test/features/pin/pin_setup_screen_test.dart test/features/pin/pin_unlock_screen_test.dart`
Expected: FAIL — none of the PIN files exist yet.

- [ ] **Step 3: Implement `lib/providers/pin_provider.dart`**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class PinRepository {
  Future<bool> hasPin();
  Future<void> setPin(String pin);
  Future<bool> verifyPin(String pin);
  Future<void> clearPin();
}

class SecureStoragePinRepository implements PinRepository {
  static const _key = 'app_pin';
  final FlutterSecureStorage storage;
  SecureStoragePinRepository(this.storage);

  @override
  Future<bool> hasPin() async => (await storage.read(key: _key)) != null;

  @override
  Future<void> setPin(String pin) => storage.write(key: _key, value: pin);

  @override
  Future<bool> verifyPin(String pin) async => (await storage.read(key: _key)) == pin;

  @override
  Future<void> clearPin() => storage.delete(key: _key);
}

final pinRepositoryProvider = Provider<PinRepository>((ref) {
  return SecureStoragePinRepository(const FlutterSecureStorage());
});
```

- [ ] **Step 4: Implement `lib/features/pin/pin_setup_screen.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_state.dart';
import '../../providers/pin_provider.dart';
import '../../providers/settings_provider.dart';

class PinSetupScreen extends ConsumerStatefulWidget {
  const PinSetupScreen({super.key});

  @override
  ConsumerState<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends ConsumerState<PinSetupScreen> {
  final _pinController = TextEditingController();
  final _confirmController = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _pinController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final pin = _pinController.text.trim();
    final confirm = _confirmController.text.trim();
    if (pin.length != 4 || int.tryParse(pin) == null) {
      setState(() => _error = 'PIN must be 4 digits');
      return;
    }
    if (pin != confirm) {
      setState(() => _error = 'PINs do not match');
      return;
    }
    await ref.read(pinRepositoryProvider).setPin(pin);
    await ref.read(settingsProvider.notifier).setPinLockEnabled(true);
    ref.read(sessionUnlockedProvider.notifier).state = true;
    if (mounted) Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Set a PIN')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              key: const Key('pin_setup_pin_field'),
              controller: _pinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 4,
              decoration: const InputDecoration(labelText: 'Enter a 4-digit PIN'),
            ),
            TextField(
              key: const Key('pin_setup_confirm_field'),
              controller: _confirmController,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 4,
              decoration: InputDecoration(labelText: 'Confirm PIN', errorText: _error),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              key: const Key('pin_setup_save_button'),
              onPressed: _save,
              child: const Text('Save PIN'),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 5: Implement `lib/features/pin/pin_unlock_screen.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_state.dart';
import '../../providers/pin_provider.dart';

class PinUnlockScreen extends ConsumerStatefulWidget {
  const PinUnlockScreen({super.key});

  @override
  ConsumerState<PinUnlockScreen> createState() => _PinUnlockScreenState();
}

class _PinUnlockScreenState extends ConsumerState<PinUnlockScreen> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _unlock() async {
    final ok = await ref.read(pinRepositoryProvider).verifyPin(_controller.text.trim());
    if (ok) {
      ref.read(sessionUnlockedProvider.notifier).state = true;
    } else {
      setState(() => _error = 'Incorrect PIN');
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock, size: 40),
                const SizedBox(height: 16),
                const Text('Enter your PIN', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                const SizedBox(height: 16),
                TextField(
                  key: const Key('pin_unlock_field'),
                  controller: _controller,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(errorText: _error),
                  onSubmitted: (_) => _unlock(),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  key: const Key('pin_unlock_button'),
                  onPressed: _unlock,
                  child: const Text('Unlock'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 6: Run tests to verify they pass**

Run: `flutter test test/features/pin/pin_setup_screen_test.dart test/features/pin/pin_unlock_screen_test.dart`
Expected: `00:0X +4: All tests passed!`

- [ ] **Step 7: Commit**

```bash
git add lib/providers/pin_provider.dart lib/features/pin test/features/pin
git commit -m "feat: add PIN lock (setup and unlock screens)"
```

---

## Task 18: Reminder notifications service

**Files:**
- Create: `lib/services/reminder_service.dart`

**Interfaces:**
- Produces: `ReminderService` (abstract: `init()`, `requestPermission() -> Future<bool>`,
  `scheduleDailyReminder(int minutesSinceMidnight)`, `cancelReminder()`);
  `LocalNotificationsReminderService` (prod impl using
  `flutter_local_notifications` + `timezone`); `reminderServiceProvider -> Provider<ReminderService>`.

Like `SecureStoragePinRepository`, `LocalNotificationsReminderService` is a
thin delegate to a platform-channel plugin with no business logic of its
own — it is not unit tested directly. Its usage (schedule on enable, cancel
on disable, permission-denied handling) is exercised in Task 22 (Profile
screen) via a `FakeReminderService` test double, the same pattern as Task 17.
No test file for this task — it's pure plumbing, verified where it's used.

- [ ] **Step 1: Implement `lib/services/reminder_service.dart`**

```dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

abstract class ReminderService {
  Future<void> init();
  Future<bool> requestPermission();
  Future<void> scheduleDailyReminder(int minutesSinceMidnight);
  Future<void> cancelReminder();
}

class LocalNotificationsReminderService implements ReminderService {
  static const _reminderNotificationId = 1001;
  final FlutterLocalNotificationsPlugin plugin;
  LocalNotificationsReminderService(this.plugin);

  @override
  Future<void> init() async {
    tzdata.initializeTimeZones();
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    await plugin.initialize(const InitializationSettings(android: androidInit, iOS: iosInit));
  }

  @override
  Future<bool> requestPermission() async {
    final androidImpl = plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    final iosImpl = plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    final androidGranted = await androidImpl?.requestNotificationsPermission() ?? true;
    final iosGranted = await iosImpl?.requestPermissions(alert: true, badge: true, sound: true) ?? true;
    return androidGranted && iosGranted;
  }

  @override
  Future<void> scheduleDailyReminder(int minutesSinceMidnight) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, minutesSinceMidnight ~/ 60, minutesSinceMidnight % 60);
    if (scheduled.isBefore(now)) scheduled = scheduled.add(const Duration(days: 1));
    await plugin.zonedSchedule(
      _reminderNotificationId,
      'Log your expenses',
      "Don't forget to add today's transactions.",
      scheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails('reminders', 'Reminders', importance: Importance.defaultImportance),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  @override
  Future<void> cancelReminder() => plugin.cancel(_reminderNotificationId);
}

final reminderServiceProvider = Provider<ReminderService>((ref) {
  return LocalNotificationsReminderService(FlutterLocalNotificationsPlugin());
});
```

- [ ] **Step 2: Add the Android permissions notifications need**

Edit `android/app/src/main/AndroidManifest.xml`: inside the `<manifest>` tag,
above `<application ...>`, add:

```xml
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
    <uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
```

`POST_NOTIFICATIONS` is required at runtime on Android 13+ (requested via
`requestPermission()` above); `SCHEDULE_EXACT_ALARM` backs
`AndroidScheduleMode.exactAllowWhileIdle`; `RECEIVE_BOOT_COMPLETED` lets the
scheduled reminder survive a device reboot.

- [ ] **Step 3: Add the iOS notification capability**

`flutter_local_notifications`'s `DarwinInitializationSettings` requests iOS
notification permission at `init()` time by default — no `Info.plist` entry
is required beyond what `flutter create` already scaffolds. Confirm
`ios/Runner/Info.plist` exists (it does, from Task 0) and skip further
changes here.

- [ ] **Step 4: Confirm the project still analyzes cleanly**

Run: `flutter analyze lib/services/reminder_service.dart`
Expected: `No issues found!`

- [ ] **Step 5: Commit**

```bash
git add lib/services/reminder_service.dart android/app/src/main/AndroidManifest.xml
git commit -m "feat: add reminder notifications service"
```

---

## Task 19: CSV export service

**Files:**
- Create: `lib/services/export_service.dart`

**Interfaces:**
- Produces: `ExportService` (abstract: `shareCsv(String csv, String fileName)`);
  `SharePlusExportService` (prod impl using `path_provider` + `share_plus`);
  `exportServiceProvider -> Provider<ExportService>`.

Same rationale as Tasks 17-18: a thin plugin delegate, not unit tested
directly; exercised in Task 22 (Profile screen) via a `FakeExportService`.

- [ ] **Step 1: Implement `lib/services/export_service.dart`**

```dart
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

abstract class ExportService {
  Future<void> shareCsv(String csv, String fileName);
}

class SharePlusExportService implements ExportService {
  @override
  Future<void> shareCsv(String csv, String fileName) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsString(csv);
    await Share.shareXFiles([XFile(file.path)], text: 'Finance Tracker export');
  }
}

final exportServiceProvider = Provider<ExportService>((ref) {
  return SharePlusExportService();
});
```

- [ ] **Step 2: Confirm the project still analyzes cleanly**

Run: `flutter analyze lib/services/export_service.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/services/export_service.dart
git commit -m "feat: add CSV export service"
```

---

## Task 20: Categories management screen

**Files:**
- Create: `lib/features/categories/categories_screen.dart`
- Test: `test/features/categories/categories_screen_test.dart`

**Interfaces:**
- Consumes: `categoriesProvider` (Task 9, `add`/`rename`/`delete`);
  `kIconLookup` (Task 13); `CategoryIconAvatar` (Task 13); `uuid` package.
- Produces: `CategoriesScreen` (`ConsumerWidget`, no args). Default (seeded)
  categories render without edit/delete controls (`isCustom == false` is
  permanent, per the design doc); custom categories get edit and delete
  icon buttons. A floating action button opens an add-category dialog
  (name, Expense/Income toggle, icon picker from a curated set, color swatch
  picker from a fixed palette).

- [ ] **Step 1: Write the failing test**

```dart
// test/features/categories/categories_screen_test.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance_tracker/models/txn_kind.dart';
import 'package:finance_tracker/models/category.dart';
import 'package:finance_tracker/data/hive_boxes.dart';
import 'package:finance_tracker/data/seed_categories.dart';
import 'package:finance_tracker/providers/categories_provider.dart';
import 'package:finance_tracker/features/categories/categories_screen.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('hive_test_');
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(TxnKindAdapter());
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(CategoryRecordAdapter());
    final catBox = await Hive.openBox<CategoryRecord>(categoriesBoxName);
    await seedCategoriesIfEmpty(catBox);
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    tempDir.deleteSync(recursive: true);
  });

  testWidgets('default categories show with no delete button', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const MaterialApp(home: CategoriesScreen())));
    expect(find.text('Food'), findsOneWidget);
    expect(find.byIcon(Icons.delete_outline), findsNothing);
  });

  testWidgets('adding a custom category shows it with a delete button, which removes it', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const MaterialApp(home: CategoriesScreen())));

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('add_category_name_field')), 'Pets');
    await tester.tap(find.byKey(const Key('add_category_save_button')));
    await tester.pumpAndSettle();

    expect(find.text('Pets'), findsOneWidget);
    expect(find.byIcon(Icons.delete_outline), findsOneWidget);

    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(find.text('Pets'), findsNothing);
    expect(container.read(categoriesProvider).any((c) => c.name == 'Pets'), false);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/categories/categories_screen_test.dart`
Expected: FAIL — `categories_screen.dart` doesn't exist yet.

- [ ] **Step 3: Implement `lib/features/categories/categories_screen.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../models/category.dart';
import '../../models/txn_kind.dart';
import '../../providers/categories_provider.dart';
import '../../utils/icon_lookup.dart';
import '../../widgets/category_icon_avatar.dart';

const _uuid = Uuid();
const _palette = ['#F59E0B', '#3B82F6', '#EC4899', '#8B5CF6', '#F43F5E', '#22C55E', '#06B6D4', '#6366F1', '#F97316', '#94A3B8'];

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);

    Future<void> confirmDelete(CategoryRecord c) async {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Delete "${c.name}"?'),
          content: const Text('Existing transactions in this category will keep showing it by name.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
          ],
        ),
      );
      if (confirmed == true) {
        await ref.read(categoriesProvider.notifier).delete(c.id);
      }
    }

    Future<void> rename(CategoryRecord c) async {
      final controller = TextEditingController(text: c.name);
      final newName = await showDialog<String>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Rename category'),
          content: TextField(controller: controller),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: const Text('Save')),
          ],
        ),
      );
      if (newName != null && newName.isNotEmpty) {
        await ref.read(categoriesProvider.notifier).rename(c.id, newName);
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      body: ListView(
        children: [
          for (final c in categories)
            ListTile(
              leading: CategoryIconAvatar(iconName: c.iconName, colorHex: c.colorHex, size: 36, iconSize: 20),
              title: Text(c.name),
              subtitle: Text(c.kind == TxnKind.expense ? 'Expense' : 'Income'),
              trailing: c.isCustom
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () => rename(c)),
                        IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => confirmDelete(c)),
                      ],
                    )
                  : null,
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog(context: context, builder: (_) => const _AddCategoryDialog()),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _AddCategoryDialog extends ConsumerStatefulWidget {
  const _AddCategoryDialog();

  @override
  ConsumerState<_AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends ConsumerState<_AddCategoryDialog> {
  final _nameController = TextEditingController();
  TxnKind _kind = TxnKind.expense;
  String _iconName = kIconLookup.keys.first;
  String _colorHex = _palette.first;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    await ref.read(categoriesProvider.notifier).add(CategoryRecord(
          id: _uuid.v4(),
          name: name,
          kind: _kind,
          iconName: _iconName,
          colorHex: _colorHex,
          isCustom: true,
        ));
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add category'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(key: const Key('add_category_name_field'), controller: _nameController, decoration: const InputDecoration(labelText: 'Name')),
            const SizedBox(height: 12),
            SegmentedButton<TxnKind>(
              segments: const [
                ButtonSegment(value: TxnKind.expense, label: Text('Expense')),
                ButtonSegment(value: TxnKind.income, label: Text('Income')),
              ],
              selected: {_kind},
              onSelectionChanged: (s) => setState(() => _kind = s.first),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                for (final name in kIconLookup.keys)
                  GestureDetector(
                    onTap: () => setState(() => _iconName = name),
                    child: CircleAvatar(
                      backgroundColor: _iconName == name ? Theme.of(context).colorScheme.primary.withOpacity(0.2) : null,
                      child: Icon(kIconLookup[name]),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                for (final hex in _palette)
                  GestureDetector(
                    onTap: () => setState(() => _colorHex = hex),
                    child: CircleAvatar(
                      backgroundColor: Color(int.parse('FF${hex.replaceFirst('#', '')}', radix: 16)),
                      child: _colorHex == hex ? const Icon(Icons.check, color: Colors.white, size: 16) : null,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        TextButton(key: const Key('add_category_save_button'), onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `flutter test test/features/categories/categories_screen_test.dart`
Expected: `00:0X +2: All tests passed!`

- [ ] **Step 5: Commit**

```bash
git add lib/features/categories test/features/categories
git commit -m "feat: add categories management screen"
```

---

## Task 21: About screen

**Files:**
- Create: `lib/features/about/about_screen.dart`
- Test: `test/features/about/about_screen_test.dart`

**Interfaces:**
- Produces: `AboutScreen` (`StatelessWidget`, no args).

- [ ] **Step 1: Write the failing test**

```dart
// test/features/about/about_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/features/about/about_screen.dart';

void main() {
  testWidgets('shows the app name and version', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AboutScreen()));
    expect(find.text('FinTrack'), findsWidgets);
    expect(find.textContaining('2.4.0'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/about/about_screen_test.dart`
Expected: FAIL — `about_screen.dart` doesn't exist yet.

- [ ] **Step 3: Implement `lib/features/about/about_screen.dart`**

```dart
import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: const Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('FinTrack', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
            SizedBox(height: 6),
            Text('Version 2.4.0'),
            SizedBox(height: 20),
            Text(
              'FinTrack helps you track income and expenses, stick to a monthly '
              'budget, and understand your spending with clear analytics — all '
              'stored privately on your device.',
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/features/about/about_screen_test.dart`
Expected: `00:0X +1: All tests passed!`

- [ ] **Step 5: Commit**

```bash
git add lib/features/about test/features/about
git commit -m "feat: add About screen"
```

---

## Task 22: Profile screen

**Files:**
- Create: `lib/features/profile/profile_screen.dart`
- Test: `test/features/profile/profile_screen_test.dart`

**Interfaces:**
- Consumes: `settingsProvider` (Task 10); `categoriesProvider` (Task 9);
  `pinRepositoryProvider` (Task 17); `reminderServiceProvider` (Task 18);
  `exportServiceProvider` (Task 19); `transactionsProvider`,
  `categoriesByIdProvider` (for CSV export data); `transactionsToCsv` (Task 8);
  `formatInr` (Task 4); `PinSetupScreen` (Task 17); `CategoriesScreen`
  (Task 20); `AboutScreen` (Task 21).
- Produces: `ProfileScreen` (`ConsumerWidget`, no args). Preference rows:
  Categories (navigates to `CategoriesScreen`, shows live category count),
  Reminder Settings (real toggle — requests permission, schedules/cancels),
  Export Data (tapping triggers a real CSV share), Backup & Restore
  (placeholder — tapping shows a "Coming soon" snackbar, no real action),
  Dark Mode (real toggle via `settingsProvider.setDarkMode`), PIN Lock
  (toggling on pushes `PinSetupScreen`; toggling off confirms then clears
  the stored PIN and disables the setting), About (navigates to `AboutScreen`).
  No hardcoded fake email is shown under the user's name — the design's
  static `devang@email.com` was prototype filler, not real onboarding data.

- [ ] **Step 1: Write the failing test**

```dart
// test/features/profile/profile_screen_test.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance_tracker/models/txn_kind.dart';
import 'package:finance_tracker/models/category.dart';
import 'package:finance_tracker/models/settings.dart';
import 'package:finance_tracker/data/hive_boxes.dart';
import 'package:finance_tracker/data/seed_categories.dart';
import 'package:finance_tracker/providers/settings_provider.dart';
import 'package:finance_tracker/providers/pin_provider.dart';
import 'package:finance_tracker/services/reminder_service.dart';
import 'package:finance_tracker/services/export_service.dart';
import 'package:finance_tracker/features/profile/profile_screen.dart';
import 'package:finance_tracker/features/categories/categories_screen.dart';
import 'package:finance_tracker/features/about/about_screen.dart';

class _FakePinRepository implements PinRepository {
  String? pin;
  @override
  Future<bool> hasPin() async => pin != null;
  @override
  Future<void> setPin(String p) async => pin = p;
  @override
  Future<bool> verifyPin(String p) async => pin == p;
  @override
  Future<void> clearPin() async => pin = null;
}

class _FakeReminderService implements ReminderService {
  bool scheduled = false;
  @override
  Future<void> init() async {}
  @override
  Future<bool> requestPermission() async => true;
  @override
  Future<void> scheduleDailyReminder(int minutesSinceMidnight) async => scheduled = true;
  @override
  Future<void> cancelReminder() async => scheduled = false;
}

class _FakeExportService implements ExportService {
  bool shared = false;
  @override
  Future<void> shareCsv(String csv, String fileName) async => shared = true;
}

void main() {
  late Directory tempDir;
  late _FakeReminderService reminderService;
  late _FakeExportService exportService;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('hive_test_');
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(TxnKindAdapter());
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(CategoryRecordAdapter());
    if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(SettingsRecordAdapter());
    final catBox = await Hive.openBox<CategoryRecord>(categoriesBoxName);
    await seedCategoriesIfEmpty(catBox);
    final settingsBox = await Hive.openBox<SettingsRecord>(settingsBoxName);
    await settingsBox.put(settingsKey, SettingsRecord(userName: 'Asha', monthlySalary: 60000, monthlyBudget: 40000));
    reminderService = _FakeReminderService();
    exportService = _FakeExportService();
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    tempDir.deleteSync(recursive: true);
  });

  ProviderContainer buildContainer() => ProviderContainer(overrides: [
        pinRepositoryProvider.overrideWithValue(_FakePinRepository()),
        reminderServiceProvider.overrideWithValue(reminderService),
        exportServiceProvider.overrideWithValue(exportService),
      ]);

  testWidgets('shows user name, no fake email, and salary/budget', (tester) async {
    final container = buildContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const MaterialApp(home: ProfileScreen())));
    expect(find.text('Asha'), findsOneWidget);
    expect(find.textContaining('@'), findsNothing);
    expect(find.text('₹60,000'), findsOneWidget);
    expect(find.text('₹40,000'), findsOneWidget);
  });

  testWidgets('toggling Reminders on requests permission and schedules', (tester) async {
    final container = buildContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const MaterialApp(home: ProfileScreen())));
    await tester.tap(find.text('Reminder Settings'));
    await tester.pumpAndSettle();
    expect(reminderService.scheduled, true);
    expect(container.read(settingsProvider).remindersEnabled, true);
  });

  testWidgets('tapping Export Data shares a CSV', (tester) async {
    final container = buildContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const MaterialApp(home: ProfileScreen())));
    await tester.tap(find.text('Export Data'));
    await tester.pumpAndSettle();
    expect(exportService.shared, true);
  });

  testWidgets('tapping Categories navigates to CategoriesScreen', (tester) async {
    final container = buildContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const MaterialApp(home: ProfileScreen())));
    await tester.tap(find.text('Categories'));
    await tester.pumpAndSettle();
    expect(find.byType(CategoriesScreen), findsOneWidget);
  });

  testWidgets('tapping About navigates to AboutScreen', (tester) async {
    final container = buildContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const MaterialApp(home: ProfileScreen())));
    await tester.tap(find.text('About'));
    await tester.pumpAndSettle();
    expect(find.byType(AboutScreen), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/profile/profile_screen_test.dart`
Expected: FAIL — `profile_screen.dart` doesn't exist yet.

- [ ] **Step 3: Implement `lib/features/profile/profile_screen.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../providers/app_state.dart';
import '../../providers/categories_provider.dart';
import '../../providers/pin_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/transactions_provider.dart';
import '../../services/export_service.dart';
import '../../services/reminder_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/csv_export.dart';
import '../../utils/currency.dart';
import '../about/about_screen.dart';
import '../categories/categories_screen.dart';
import '../pin/pin_setup_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final categoryCount = ref.watch(categoriesProvider).length;
    final palette = context.palette;

    Future<void> toggleReminders(bool enable) async {
      if (enable) {
        final granted = await ref.read(reminderServiceProvider).requestPermission();
        if (!granted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notification permission denied')));
          return;
        }
        await ref.read(reminderServiceProvider).scheduleDailyReminder(settings.reminderMinutesSinceMidnight);
      } else {
        await ref.read(reminderServiceProvider).cancelReminder();
      }
      await ref.read(settingsProvider.notifier).setRemindersEnabled(enable);
    }

    Future<void> exportData() async {
      final txns = ref.read(transactionsProvider);
      final categoriesById = ref.read(categoriesByIdProvider);
      final csv = transactionsToCsv(txns, categoriesById);
      try {
        await ref.read(exportServiceProvider).shareCsv(csv, 'fintrack_export.csv');
      } catch (_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not export data')));
        }
      }
    }

    Future<void> togglePinLock(bool enable) async {
      if (enable) {
        await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PinSetupScreen()));
        return;
      }
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Turn off PIN Lock?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Turn off')),
          ],
        ),
      );
      if (confirmed == true) {
        await ref.read(pinRepositoryProvider).clearPin();
        await ref.read(settingsProvider.notifier).setPinLockEnabled(false);
      }
    }

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 130),
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Text('Profile', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: -0.6)),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: palette.surface, border: Border.all(color: palette.border), borderRadius: BorderRadius.circular(24)),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), gradient: const LinearGradient(colors: [AppColors.accent, Color(0xFF1E40AF)])),
                  alignment: Alignment.center,
                  child: Text(settings.userName.isEmpty ? '?' : settings.userName[0].toUpperCase(), style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white)),
                ),
                const SizedBox(width: 16),
                Expanded(child: Text(settings.userName, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800))),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _InfoCard(label: 'Monthly Salary', value: formatInr(settings.monthlySalary))),
              const SizedBox(width: 12),
              Expanded(child: _InfoCard(label: 'Default Budget', value: formatInr(settings.monthlyBudget))),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 24, 4, 10),
            child: Text('PREFERENCES', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: palette.textTertiary, letterSpacing: 0.8)),
          ),
          Container(
            decoration: BoxDecoration(color: palette.surface, border: Border.all(color: palette.border), borderRadius: BorderRadius.circular(20)),
            child: Column(
              children: [
                _PrefRow(
                  icon: Symbols.sell,
                  color: const Color(0xFFF59E0B),
                  label: 'Categories',
                  trailing: Text('$categoryCount'),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CategoriesScreen())),
                ),
                _PrefRow(
                  icon: Symbols.notifications,
                  color: const Color(0xFF3B82F6),
                  label: 'Reminder Settings',
                  trailing: Switch(value: settings.remindersEnabled, onChanged: toggleReminders),
                  onTap: () => toggleReminders(!settings.remindersEnabled),
                ),
                _PrefRow(
                  icon: Symbols.ios_share,
                  color: AppColors.success,
                  label: 'Export Data',
                  trailing: const Text('CSV'),
                  onTap: exportData,
                ),
                _PrefRow(
                  icon: Symbols.cloud_sync,
                  color: const Color(0xFF06B6D4),
                  label: 'Backup & Restore',
                  trailing: const SizedBox.shrink(),
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Coming soon'))),
                ),
                _PrefRow(
                  icon: Symbols.dark_mode,
                  color: const Color(0xFF8B5CF6),
                  label: 'Dark Mode',
                  trailing: Switch(value: settings.darkMode, onChanged: (v) => ref.read(settingsProvider.notifier).setDarkMode(v)),
                  onTap: () => ref.read(settingsProvider.notifier).setDarkMode(!settings.darkMode),
                ),
                _PrefRow(
                  icon: Symbols.lock,
                  color: AppColors.danger,
                  label: 'PIN Lock',
                  trailing: Switch(value: settings.pinLockEnabled, onChanged: togglePinLock),
                  onTap: () => togglePinLock(!settings.pinLockEnabled),
                ),
                _PrefRow(
                  icon: Symbols.info,
                  color: palette.textSecondary,
                  label: 'About',
                  trailing: const SizedBox.shrink(),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AboutScreen())),
                  isLast: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: OutlinedButton.icon(
              onPressed: () {},
              style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger, side: const BorderSide(color: AppColors.danger)),
              icon: const Icon(Symbols.logout),
              label: const Text('Log Out'),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String label, value;
  const _InfoCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: palette.surface, border: Border.all(color: palette.border), borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: palette.textSecondary)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _PrefRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final Widget trailing;
  final VoidCallback onTap;
  final bool isLast;
  const _PrefRow({required this.icon, required this.color, required this.label, required this.trailing, required this.onTap, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        decoration: BoxDecoration(border: isLast ? null : Border(bottom: BorderSide(color: palette.border))),
        child: Row(
          children: [
            Container(width: 36, height: 36, decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(11)), child: Icon(icon, size: 20, color: color)),
            const SizedBox(width: 15),
            Expanded(child: Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700))),
            trailing,
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `flutter test test/features/profile/profile_screen_test.dart`
Expected: `00:0X +5: All tests passed!`

- [ ] **Step 5: Commit**

```bash
git add lib/features/profile test/features/profile
git commit -m "feat: add Profile screen wiring settings, PIN lock, reminders, export, categories"
```

---

## Task 23: Bottom-nav app shell

**Files:**
- Create: `lib/features/shell/app_shell.dart`
- Test: `test/features/shell/app_shell_test.dart`

**Interfaces:**
- Consumes: `currentTabProvider`, `AppTab` (Task 11); `HomeScreen` (Task 13);
  `TransactionsScreen` (Task 14); `AddTransactionScreen` (Task 15);
  `AnalyticsScreen` (Task 16); `ProfileScreen` (Task 22).
- Produces: `AppShell` (`ConsumerWidget`, no args) — an `IndexedStack` of the
  5 tab screens plus a bottom nav bar (Home / Transactions / floating center
  Add / Analytics / Profile), matching the design's nav bar layout.

Note: `IndexedStack` builds all 5 children up front (only the active one is
painted/hit-testable), so this screen — and its test — need every provider
the 5 screens collectively depend on, including `Profile`'s PIN/reminder/export
service overrides.

- [ ] **Step 1: Write the failing test**

```dart
// test/features/shell/app_shell_test.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance_tracker/models/txn_kind.dart';
import 'package:finance_tracker/models/transaction.dart';
import 'package:finance_tracker/models/category.dart';
import 'package:finance_tracker/models/settings.dart';
import 'package:finance_tracker/data/hive_boxes.dart';
import 'package:finance_tracker/data/seed_categories.dart';
import 'package:finance_tracker/providers/app_state.dart';
import 'package:finance_tracker/providers/pin_provider.dart';
import 'package:finance_tracker/services/reminder_service.dart';
import 'package:finance_tracker/services/export_service.dart';
import 'package:finance_tracker/features/shell/app_shell.dart';

class _FakePinRepository implements PinRepository {
  String? pin;
  @override
  Future<bool> hasPin() async => pin != null;
  @override
  Future<void> setPin(String p) async => pin = p;
  @override
  Future<bool> verifyPin(String p) async => pin == p;
  @override
  Future<void> clearPin() async => pin = null;
}

class _FakeReminderService implements ReminderService {
  @override
  Future<void> init() async {}
  @override
  Future<bool> requestPermission() async => true;
  @override
  Future<void> scheduleDailyReminder(int minutesSinceMidnight) async {}
  @override
  Future<void> cancelReminder() async {}
}

class _FakeExportService implements ExportService {
  @override
  Future<void> shareCsv(String csv, String fileName) async {}
}

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('hive_test_');
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(TxnKindAdapter());
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(TransactionRecordAdapter());
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(CategoryRecordAdapter());
    if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(SettingsRecordAdapter());
    final catBox = await Hive.openBox<CategoryRecord>(categoriesBoxName);
    await seedCategoriesIfEmpty(catBox);
    await Hive.openBox<TransactionRecord>(transactionsBoxName);
    final settingsBox = await Hive.openBox<SettingsRecord>(settingsBoxName);
    await settingsBox.put(settingsKey, SettingsRecord(userName: 'Asha', onboardingComplete: true));
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    tempDir.deleteSync(recursive: true);
  });

  ProviderContainer buildContainer() => ProviderContainer(overrides: [
        pinRepositoryProvider.overrideWithValue(_FakePinRepository()),
        reminderServiceProvider.overrideWithValue(_FakeReminderService()),
        exportServiceProvider.overrideWithValue(_FakeExportService()),
      ]);

  testWidgets('starts on Home and switches tabs via the bottom nav', (tester) async {
    final container = buildContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const MaterialApp(home: AppShell())));

    expect(find.text('Recent Transactions'), findsOneWidget);

    await tester.tap(find.text('Transactions'));
    await tester.pump();
    expect(container.read(currentTabProvider), AppTab.transactions);

    await tester.tap(find.text('Analytics'));
    await tester.pump();
    expect(container.read(currentTabProvider), AppTab.analytics);

    await tester.tap(find.text('Profile'));
    await tester.pump();
    expect(container.read(currentTabProvider), AppTab.profile);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/shell/app_shell_test.dart`
Expected: FAIL — `app_shell.dart` doesn't exist yet.

- [ ] **Step 3: Implement `lib/features/shell/app_shell.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../providers/app_state.dart';
import '../../theme/app_theme.dart';
import '../add_transaction/add_transaction_screen.dart';
import '../analytics/analytics_screen.dart';
import '../home/home_screen.dart';
import '../profile/profile_screen.dart';
import '../transactions/transactions_screen.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(currentTabProvider);
    return Scaffold(
      body: IndexedStack(
        index: AppTab.values.indexOf(tab),
        children: const [
          HomeScreen(),
          TransactionsScreen(),
          AddTransactionScreen(),
          AnalyticsScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: _BottomNav(current: tab),
    );
  }
}

class _BottomNav extends ConsumerWidget {
  final AppTab current;
  const _BottomNav({required this.current});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;

    Widget navItem(AppTab tab, IconData icon, String label) {
      final active = tab == current;
      return Expanded(
        child: InkWell(
          onTap: () => ref.read(currentTabProvider.notifier).state = tab,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 25, color: active ? AppColors.accent : palette.textTertiary),
                const SizedBox(height: 5),
                Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: active ? AppColors.accent : palette.textTertiary)),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      height: 96,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      decoration: BoxDecoration(color: palette.surface.withOpacity(0.9), border: Border(top: BorderSide(color: palette.border))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          navItem(AppTab.home, Symbols.home, 'Home'),
          navItem(AppTab.transactions, Symbols.receipt_long, 'Transactions'),
          Expanded(
            child: Center(
              child: GestureDetector(
                onTap: () => ref.read(currentTabProvider.notifier).state = AppTab.add,
                child: Container(
                  width: 60,
                  height: 60,
                  margin: const EdgeInsets.only(top: -24),
                  decoration: const BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [AppColors.accent, Color(0xFF1E40AF)])),
                  child: const Icon(Symbols.add, color: Colors.white, size: 32),
                ),
              ),
            ),
          ),
          navItem(AppTab.analytics, Symbols.bar_chart_4_bars, 'Analytics'),
          navItem(AppTab.profile, Symbols.person, 'Profile'),
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/features/shell/app_shell_test.dart`
Expected: `00:0X +1: All tests passed!`

- [ ] **Step 5: Commit**

```bash
git add lib/features/shell test/features/shell
git commit -m "feat: add bottom-nav app shell composing all 5 tabs"
```

---

## Task 24: App entry point (main.dart + app.dart routing)

**Files:**
- Create: `lib/app.dart`
- Create: `lib/main.dart`
- Test: `test/app_test.dart`

**Interfaces:**
- Consumes: `settingsProvider` (Task 10); `sessionUnlockedProvider` (Task 11);
  `buildAppTheme` (Task 1); `OnboardingFlow` (Task 12); `PinUnlockScreen`
  (Task 17); `AppShell` (Task 23); `initHive` (Task 3);
  `LocalNotificationsReminderService` (Task 18).
- Produces: `FinanceTrackerApp` (`ConsumerWidget`, no args) — the root
  `MaterialApp`, routing to `OnboardingFlow` / `PinUnlockScreen` / `AppShell`
  based on `settings.onboardingComplete`, `settings.pinLockEnabled`, and
  `sessionUnlockedProvider`; `main()` — initializes Hive and notifications,
  then runs the app under a `ProviderScope`. `main.dart` has no test (pure
  bootstrapping, exercised implicitly by running the app).

- [ ] **Step 1: Write the failing test**

```dart
// test/app_test.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance_tracker/models/txn_kind.dart';
import 'package:finance_tracker/models/transaction.dart';
import 'package:finance_tracker/models/category.dart';
import 'package:finance_tracker/models/settings.dart';
import 'package:finance_tracker/data/hive_boxes.dart';
import 'package:finance_tracker/data/seed_categories.dart';
import 'package:finance_tracker/providers/app_state.dart';
import 'package:finance_tracker/providers/pin_provider.dart';
import 'package:finance_tracker/services/reminder_service.dart';
import 'package:finance_tracker/services/export_service.dart';
import 'package:finance_tracker/features/onboarding/onboarding_flow.dart';
import 'package:finance_tracker/features/pin/pin_unlock_screen.dart';
import 'package:finance_tracker/features/shell/app_shell.dart';
import 'package:finance_tracker/app.dart';

class _FakePinRepository implements PinRepository {
  String? pin;
  @override
  Future<bool> hasPin() async => pin != null;
  @override
  Future<void> setPin(String p) async => pin = p;
  @override
  Future<bool> verifyPin(String p) async => pin == p;
  @override
  Future<void> clearPin() async => pin = null;
}

class _FakeReminderService implements ReminderService {
  @override
  Future<void> init() async {}
  @override
  Future<bool> requestPermission() async => true;
  @override
  Future<void> scheduleDailyReminder(int minutesSinceMidnight) async {}
  @override
  Future<void> cancelReminder() async {}
}

class _FakeExportService implements ExportService {
  @override
  Future<void> shareCsv(String csv, String fileName) async {}
}

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('hive_test_');
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(TxnKindAdapter());
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(TransactionRecordAdapter());
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(CategoryRecordAdapter());
    if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(SettingsRecordAdapter());
    final catBox = await Hive.openBox<CategoryRecord>(categoriesBoxName);
    await seedCategoriesIfEmpty(catBox);
    await Hive.openBox<TransactionRecord>(transactionsBoxName);
    await Hive.openBox<SettingsRecord>(settingsBoxName);
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    tempDir.deleteSync(recursive: true);
  });

  ProviderContainer buildContainer() => ProviderContainer(overrides: [
        pinRepositoryProvider.overrideWithValue(_FakePinRepository()),
        reminderServiceProvider.overrideWithValue(_FakeReminderService()),
        exportServiceProvider.overrideWithValue(_FakeExportService()),
      ]);

  testWidgets('shows onboarding when onboardingComplete is false', (tester) async {
    await Hive.box<SettingsRecord>(settingsBoxName).put(settingsKey, SettingsRecord(onboardingComplete: false));
    final container = buildContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const FinanceTrackerApp()));
    expect(find.byType(OnboardingFlow), findsOneWidget);
  });

  testWidgets('shows the shell when onboarding is done and PIN lock is off', (tester) async {
    await Hive.box<SettingsRecord>(settingsBoxName).put(settingsKey, SettingsRecord(onboardingComplete: true, pinLockEnabled: false));
    final container = buildContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const FinanceTrackerApp()));
    expect(find.byType(AppShell), findsOneWidget);
  });

  testWidgets('shows the PIN unlock screen when PIN lock is on and session is locked', (tester) async {
    await Hive.box<SettingsRecord>(settingsBoxName).put(settingsKey, SettingsRecord(onboardingComplete: true, pinLockEnabled: true));
    final container = buildContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const FinanceTrackerApp()));
    expect(find.byType(PinUnlockScreen), findsOneWidget);
  });

  testWidgets('shows the shell once the session is unlocked', (tester) async {
    await Hive.box<SettingsRecord>(settingsBoxName).put(settingsKey, SettingsRecord(onboardingComplete: true, pinLockEnabled: true));
    final container = buildContainer();
    addTearDown(container.dispose);
    container.read(sessionUnlockedProvider.notifier).state = true;
    await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const FinanceTrackerApp()));
    expect(find.byType(AppShell), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/app_test.dart`
Expected: FAIL — `app.dart` doesn't exist yet.

- [ ] **Step 3: Implement `lib/app.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/onboarding/onboarding_flow.dart';
import 'features/pin/pin_unlock_screen.dart';
import 'features/shell/app_shell.dart';
import 'providers/app_state.dart';
import 'providers/settings_provider.dart';
import 'theme/app_theme.dart';

class FinanceTrackerApp extends ConsumerWidget {
  const FinanceTrackerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final sessionUnlocked = ref.watch(sessionUnlockedProvider);

    Widget home;
    if (!settings.onboardingComplete) {
      home = const OnboardingFlow();
    } else if (settings.pinLockEnabled && !sessionUnlocked) {
      home = const PinUnlockScreen();
    } else {
      home = const AppShell();
    }

    return MaterialApp(
      title: 'FinTrack',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(Brightness.light),
      darkTheme: buildAppTheme(Brightness.dark),
      themeMode: settings.darkMode ? ThemeMode.dark : ThemeMode.light,
      home: home,
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/app_test.dart`
Expected: `00:0X +4: All tests passed!`

- [ ] **Step 5: Implement `lib/main.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'data/hive_boxes.dart';
import 'services/reminder_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await initHive();
    await LocalNotificationsReminderService(FlutterLocalNotificationsPlugin()).init();
  } catch (e) {
    runApp(_StartupErrorApp(error: e.toString()));
    return;
  }
  runApp(const ProviderScope(child: FinanceTrackerApp()));
}

class _StartupErrorApp extends StatelessWidget {
  final String error;
  const _StartupErrorApp({required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                const Text('FinTrack failed to start', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(error, textAlign: TextAlign.center),
                const SizedBox(height: 20),
                ElevatedButton(onPressed: main, child: const Text('Retry')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 6: Commit**

```bash
git add lib/app.dart lib/main.dart test/app_test.dart
git commit -m "feat: wire up app entry point with onboarding/PIN/shell routing"
```

---

## Task 25: Final full-suite verification

**Files:** none created — this task only verifies the accumulated result of
Tasks 0-24.

- [ ] **Step 1: Run the full test suite**

Run: `flutter test`
Expected: every test file from every prior task passes — no failures. If
anything fails, fix the root cause in the relevant file from the task that
introduced it (don't patch symptoms in unrelated files).

- [ ] **Step 2: Run static analysis over the whole project**

Run: `flutter analyze`
Expected: `No issues found!`. Fix any lints or type errors surfaced —
common culprits at this scale are unused imports and missing `const`.

- [ ] **Step 3: Confirm the app builds**

Run: `flutter build apk --debug` (Android) — this is faster and more broadly
available in CI/dev environments than an iOS build, and exercises the same
Dart compilation + asset bundling. Expected: `Built build/app/outputs/flutter-apk/app-debug.apk`.

- [ ] **Step 4: Manual smoke test on a device or emulator, if one is available**

Run: `flutter devices` to check for a connected device/emulator/simulator.
If one is available, run: `flutter run`, and walk the golden path by hand:
onboarding (name → salary/budget → finish) → Home shows ₹0 everywhere and an
empty recent list → Add Expense → pick Food, key in an amount, save → Home
and Transactions both reflect it → Analytics now shows a chart instead of
the empty state → Profile: toggle Dark Mode (app re-themes), toggle PIN Lock
on (set a PIN), background/reopen the app (or hot-restart) and confirm the
PIN unlock screen appears → enter the PIN → shell reappears. If no
device/emulator is available, state that explicitly rather than claiming
this step was verified.

- [ ] **Step 5: Commit (only if Steps 1-3 required fixes)**

If any fixes were needed to make the suite/analyze/build pass, commit them:

```bash
git add -A
git commit -m "fix: resolve issues found in full-suite verification"
```

If no fixes were needed, there is nothing to commit — the plan is complete.
