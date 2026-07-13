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
