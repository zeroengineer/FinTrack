# Finance Tracker — Flutter App Design

## Origin

This app is being implemented from a Claude Design handoff bundle
(`Premium Personal Finance Tracker-handoff.zip`). The primary design source is
`premium-personal-finance-tracker/project/Finance Tracker.dc.html`, a single-file
HTML/CSS/JS prototype (React-like "DC" runtime) rendered inside a phone frame.
It fully specifies five screens: Home, Transactions, Add Transaction, Analytics,
Profile — including layout, spacing, colors, copy, icons, and interaction
behavior (swipe-to-edit/delete, keypad entry, tab switching, toasts).

Per the handoff README, the prototype's HTML/CSS/JS structure is not meant to be
copied — only its visual output and behavior. This spec describes a native
Flutter implementation that reproduces that design pixel-for-pixel while adding
real, persistent functionality (the prototype only holds data in memory).

## Goals

- A Flutter app (Android + iOS) matching the design's 5 screens pixel-for-pixel.
- Real local persistence: transactions, categories, and settings survive app
  restarts.
- Analytics/Home numbers are computed live from real stored transactions, not
  hardcoded like the prototype.
- Selected Profile settings are fully functional (see scope below); the rest
  are visible but inert placeholders, matching what the design actually shows.

## Out of scope

- Any backend/cloud sync — everything is on-device only.
- Multi-currency support — currency is fixed to ₹ (INR), matching the design.
- A theme-color picker — accent color is fixed to the design's default blue
  (`#2563EB`); the prototype's "accent" prop was a design-tool authoring
  affordance, not an in-app feature (no such control exists in the Profile
  screen's preference rows).
- Backup & Restore — stays a visible, inert "coming soon" row.

## Tech stack

| Concern | Choice | Why |
|---|---|---|
| State management | `flutter_riverpod` | Type-safe, low boilerplate, good fit for the derived-data-heavy screens (analytics/home aggregates). |
| Local storage | `hive` + `hive_flutter` | Lightweight embedded NoSQL DB; no native SQL needed for simple typed records (transactions, categories, settings). |
| PIN storage | `flutter_secure_storage` | PIN lock secret must not sit in a plain local DB; use platform secure storage (Keychain/Keystore). |
| Charts | `fl_chart` | Bar / donut / line chart equivalents of the prototype's Chart.js bar/doughnut/line charts. |
| Icons | `material_symbols_icons` | Exposes the exact Material Symbols Rounded icon names used in the design (`restaurant`, `directions_bus`, `receipt_long`, `savings`, etc.) for a pixel-accurate icon match. |
| Font | `google_fonts` (Manrope) | Matches the design's `Manrope` font family. |
| Notifications | `flutter_local_notifications` (+ `timezone`) | Real scheduled local reminders. |
| CSV export | `csv` + `share_plus` | Generate a CSV and hand it to the OS share sheet. |

## Data models (Hive)

**Transaction**
- `id` (String, uuid)
- `kind` (`expense` | `income`)
- `categoryId` (String, references Category)
- `note` (String)
- `amount` (double)
- `date` (DateTime)

**Category**
- `id` (String)
- `name` (String)
- `kind` (`expense` | `income`)
- `iconName` (String — Material Symbols name)
- `colorHex` (String)
- `isCustom` (bool) — seeded defaults are `false`, user-added are `true`

Seeded with the same 15 defaults as the prototype (10 expense: Food, Transport,
Shopping, Bills, Entertainment, Health, Travel, Education, Rent, Others; 5
income: Salary, Freelance, Bonus, Gift, Other), each with the same icon/color
mapping shown in the design.

**Settings** (single record)
- `userName` (String) — set during onboarding, no hardcoded default name
- `monthlyBudget` (double) — set during onboarding
- `monthlySalary` (double) — set during onboarding
- `darkMode` (bool, default true — matches the design's dark-only look)
- `remindersEnabled` (bool)
- `reminderTime` (TimeOfDay, stored as minutes-since-midnight)
- `pinLockEnabled` (bool)
- `onboardingComplete` (bool, default false)

## Onboarding

The app ships with **zero mock data** — no seeded sample transactions, no
placeholder salary/budget/name baked in as if they were real user data (the
prototype's "Devang" / ₹70,000 salary / ₹50,000 budget / 8 sample transactions
were dummy design-tool content, not real defaults to carry into the app).

On first launch (`onboardingComplete == false`), the app shows a short
onboarding flow instead of the tab shell:
1. **Welcome** — app name/logo, short description, "Get Started".
2. **Your name** — text field, used for the Home greeting ("Good Morning,
   `<name>` 👋") and Profile screen.
3. **Salary & budget** — monthly salary and monthly budget amounts (used by
   the Home budget card and Profile's info cards).
4. **Finish** — writes `userName`, `monthlySalary`, `monthlyBudget`, and
   `onboardingComplete = true` to Settings in one save, then enters the tab
   shell with the Home tab active — showing genuine empty states (no recent
   transactions, ₹0 spent, "No transactions found" on the Transactions tab,
   an analytics empty state) since no transactions exist yet.

Every screen that displayed a fixed prototype number (balance, income,
expense, savings, budget %, analytics charts, top categories, monthly trend)
must instead handle the all-zero / empty-list state cleanly rather than
assuming data exists.

**PIN** stored separately via `flutter_secure_storage`, never in the Hive
settings record.

## App structure

```
lib/
  main.dart                     — Hive/notification init, runApp
  app.dart                      — MaterialApp, light/dark ThemeData, PIN-lock gate
  theme/app_theme.dart          — colors, text styles pulled from the design's CSS
  models/                       — transaction.dart, category.dart, settings.dart (Hive adapters)
  data/
    hive_boxes.dart             — box registration/open
    seed_categories.dart        — the 15 default categories
  providers/
    transactions_provider.dart  — CRUD + derived: recent, grouped/filtered, monthly aggregates
    categories_provider.dart    — CRUD for categories
    settings_provider.dart      — user/budget/darkMode/reminders/pinLock
    pin_provider.dart           — set/verify/clear PIN
  features/
    shell/                      — bottom nav + IndexedStack of the 5 tabs
    home/                       — balance hero, quick actions, budget card, recent list
    transactions/               — search, filter chips, grouped swipeable list, empty state
    add_transaction/            — segmented toggle, amount display, category grid, keypad, save
    analytics/                  — bar/donut/line charts, top categories, savings card
    profile/
      profile_screen.dart
      categories_screen.dart    — add/rename/delete categories
      about_screen.dart
      pin_setup_screen.dart, pin_unlock_screen.dart
  widgets/                      — shared currency text, category icon avatar, toast helper
  utils/                        — currency_formatter.dart, date_grouping.dart, csv_export.dart
```

## Behavior notes carried over from the design

- Amount keypad: max 9 digits, at most 2 decimal places, backspace clears to
  `0`, matching the prototype's `pressKey` logic.
- Transaction rows: swipe left reveals Delete, swipe right reveals Edit,
  snapping open/closed past a 46px-equivalent drag threshold.
- Toasts for: transaction added/deleted, "enter an amount first" validation,
  filter taps.
- Transactions screen groups by day label (`Today`, `Yesterday`, else a date
  label), filterable by search text (matches category or note). The three
  filter chips are wired to real filtering, since the prototype only stubs
  them with a toast and doesn't specify exact semantics:
  - **Month** — a picker of months that have transactions, default "All".
  - **Category** — a picker of categories, default "All Categories".
  - **Type** — Income / Expense / "All Types".
  All three combine with each other and with the search text.

## Newly-functional Profile settings

- **Dark Mode** — real `ThemeMode` switch (the design is dark-only, so a light
  `ThemeData` is authored using the same design language, not shown in the
  source).
- **PIN Lock** — toggling on prompts a 4-digit PIN setup (with confirm); when
  enabled, app boots to an unlock screen requiring the correct PIN before
  reaching the shell.
- **Reminder notifications** — toggling on requests notification permission
  and schedules a daily local reminder; toggling off cancels it.
- **Export Data** — generates a CSV of all transactions and opens the OS share
  sheet.
- **Categories management** — a screen listing all categories (defaults +
  custom) with add/rename/delete for custom ones; the 15 default categories
  are permanent (cannot be renamed or deleted) to avoid breaking existing
  transactions that reference them.
- **About** — static screen: app name, version, short description.
- **Backup & Restore** — remains a visible, inert row (no dialog/action).

## Error handling

- Hive/init failure → simple full-screen error with a retry button.
- Add Transaction: amount must be `> 0` to save (toast, matching the design).
- Notification permission denied → toggle reverts to off with an explanatory
  snackbar.
- PIN setup: requires two matching entries; unlock: wrong PIN shows an inline
  error (no lockout/throttling in this iteration).
- CSV export/share cancelled or failed → snackbar error, no crash.

## Testing

- **Unit:** currency formatting (₹ + `en_IN` grouping), budget percentage
  calculation, category breakdown/top-category aggregation from a set of
  transactions, day-grouping logic, CSV row generation.
- **Widget:** each of the 5 tab screens renders against seeded fake providers;
  full add-transaction flow (keypad entry → category select → save → appears
  in Transactions/Home); PIN setup + correct/incorrect unlock.
