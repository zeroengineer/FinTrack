import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:finance_tracker/models/settings.dart';
import 'package:finance_tracker/data/hive_boxes.dart';
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
  setUp(() async {
    // The setup screen flips settings.pinLockEnabled, which needs the
    // settings box. In-memory box per the FakeAsync-zone constraint
    // (see docs in onboarding_flow_test.dart).
    if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(SettingsRecordAdapter());
    final box = await Hive.openBox<SettingsRecord>(settingsBoxName, bytes: Uint8List(0));
    await box.put(settingsKey, SettingsRecord());
  });

  tearDown(() async {
    await Hive.close();
  });

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
