import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Owns all storage access for the single private note.
class SecureStorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const String _noteKey = 'private_note';

  // Writing the same key replaces the previous note.
  Future<void> saveNote(String note) =>
      _storage.write(key: _noteKey, value: note);

  // A missing note is represented by an empty string.
  Future<String> readNote() async => await _storage.read(key: _noteKey) ?? '';

  // Delete only this note.
  Future<void> deleteNote() => _storage.delete(key: _noteKey);
}
