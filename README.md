# FinTrack

A premium personal finance tracker built with Flutter for Android and iOS. Track income and expenses, stick to a monthly budget, and understand your spending with clear analytics — all stored privately on your device. No accounts, no cloud, no backend.

## Features

- **Onboarding** — a 3-step flow (welcome → name → salary & budget) that personalizes the app on first launch
- **Home** — available balance hero with income/expense/savings tiles, monthly budget progress, quick add-expense/add-income actions, and recent transactions
- **Transactions** — full history grouped by day (Today / Yesterday / date), live search, and combinable Month / Category / Type filters; swipe a row right to edit, left to delete
- **Add Transaction** — custom keypad with live ₹ amount display, expense/income toggle, category picker, and optional note
- **Analytics** — income vs expense bar chart, category breakdown donut, top spending categories, and a 6-month savings trend
- **Profile & Settings**
  - Dark mode toggle (the app ships dark-first)
  - PIN lock backed by the OS Keychain/Keystore via secure storage
  - Daily reminder notifications
  - Export all transactions to CSV and share
  - Category management — 15 built-in categories plus your own custom ones
- **INR-native** — amounts use Indian digit grouping (e.g. ₹1,23,456)

## Tech stack

| Concern | Choice |
|---|---|
| State management | [flutter_riverpod](https://pub.dev/packages/flutter_riverpod) |
| Local persistence | [Hive](https://pub.dev/packages/hive) (+ hive_generator) |
| Charts | [fl_chart](https://pub.dev/packages/fl_chart) |
| Icons | [material_symbols_icons](https://pub.dev/packages/material_symbols_icons) |
| Typography | Manrope (bundled, via google_fonts) |
| Swipe actions | [flutter_slidable](https://pub.dev/packages/flutter_slidable) |
| PIN storage | [flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage) |
| Notifications | [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications) + timezone |
| Sharing/export | csv, share_plus, path_provider |

## Architecture

```
lib/
├── main.dart            # bootstrap: Hive + notifications init
├── app.dart             # root MaterialApp; onboarding / PIN / shell routing
├── theme/               # colors, dark & light palettes, text theme
├── models/              # Hive models: transaction, category, settings
├── data/                # box setup + seeded default categories
├── providers/           # Riverpod: CRUD, settings, derived state, PIN
├── services/            # reminder notifications, CSV share
├── utils/               # pure functions: currency, budget %, analytics,
│                        # filtering, date grouping, CSV
├── widgets/             # shared UI pieces
└── features/            # one folder per screen
    ├── onboarding/  ├── home/         ├── transactions/
    ├── add_transaction/  ├── analytics/  ├── profile/
    ├── categories/  ├── pin/  ├── about/  └── shell/
```

All derived numbers (budget %, category breakdown, monthly series, filters) are pure functions in `utils/`, composed into the UI through Riverpod providers — which keeps them trivially unit-testable.

## Getting started

Requires the [Flutter SDK](https://docs.flutter.dev/get-started/install) (stable channel).

```bash
git clone https://github.com/zeroengineer/FinTrack.git
cd FinTrack
flutter pub get
flutter run
```

If you change any Hive model, regenerate the adapters:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Tests

```bash
flutter test      # 80 tests: utils, providers, and widget tests per screen
flutter analyze
```

## Fonts

The Manrope font is bundled under `google_fonts/` and licensed under the [SIL Open Font License](google_fonts/OFL.txt).
