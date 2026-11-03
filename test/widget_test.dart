import 'package:azha_work/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  testWidgets('shows note field and Save and Clear buttons', (tester) async {
    await tester.pumpWidget(const SecureStorageApp());
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Private Note'), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);
    expect(find.text('Clear'), findsOneWidget);
  });

  testWidgets('saves, reloads on restart, and clears note', (tester) async {
    await tester.pumpWidget(const SecureStorageApp());
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'A sample lab note');
    await tester.ensureVisible(find.text('Save'));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Note saved securely'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(const SecureStorageApp());
    await tester.pumpAndSettle();
    expect(find.text('A sample lab note'), findsOneWidget);
    await tester.ensureVisible(find.text('Clear'));
    await tester.tap(find.text('Clear'));
    await tester.pumpAndSettle();
    expect(find.text('Note cleared'), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      isEmpty,
    );

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(const SecureStorageApp());
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      isEmpty,
    );
  });
}
