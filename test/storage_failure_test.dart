import 'package:azha_work/screens/secure_note_screen.dart';
import 'package:azha_work/services/secure_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class _RecoverableStorage extends SecureStorageService {
  bool unavailable = true;
  String note = 'An existing saved note';

  @override
  Future<String> readNote() async {
    if (unavailable) throw MissingPluginException();
    return note;
  }

  @override
  Future<void> saveNote(String value) async {
    if (unavailable) throw MissingPluginException();
    note = value;
  }

  @override
  Future<void> deleteNote() async {
    if (unavailable) throw MissingPluginException();
    note = '';
  }
}

void main() {
  testWidgets('failed load leaves editor and Save enabled', (tester) async {
    final service = _RecoverableStorage();
    await tester.pumpWidget(
      MaterialApp(home: SecureNoteScreen(service: service)),
    );
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(find.byType(TextField)).enabled, isTrue);
    expect(find.textContaining('full app rebuild'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'My new draft');
    await tester.ensureVisible(find.text('Save'));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Note saved securely'), findsNothing);
    expect(find.text('My new draft'), findsOneWidget);

    service.unavailable = false;
    await tester.ensureVisible(find.text('Save'));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(service.note, 'My new draft');
    expect(find.text('Note saved securely'), findsOneWidget);
    expect(find.textContaining('full app rebuild'), findsNothing);
  });

  testWidgets('retry recovers storage without replacing an edited draft', (
    tester,
  ) async {
    final service = _RecoverableStorage();
    await tester.pumpWidget(
      MaterialApp(home: SecureNoteScreen(service: service)),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Keep this draft');
    service.unavailable = false;
    await tester.ensureVisible(find.text('Retry storage'));
    await tester.tap(find.text('Retry storage'));
    await tester.pumpAndSettle();
    expect(find.text('Keep this draft'), findsOneWidget);
    expect(find.textContaining('full app rebuild'), findsNothing);
    expect(find.text('Unsaved changes'), findsOneWidget);
  });
}
