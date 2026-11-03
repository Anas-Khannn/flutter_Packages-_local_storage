import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/secure_storage_service.dart';

class SecureNoteScreen extends StatefulWidget {
  const SecureNoteScreen({super.key, this.service});

  final SecureStorageService? service;

  @override
  State<SecureNoteScreen> createState() => _SecureNoteScreenState();
}

class _SecureNoteScreenState extends State<SecureNoteScreen> {
  final _controller = TextEditingController();
  late final SecureStorageService _service;
  bool _busy = true;
  bool _loadFailed = false;
  String _savedNote = '';
  String? _storageError;

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? SecureStorageService();
    _loadNote();
  }

  Future<void> _loadNote() async {
    final draft = _controller.text;
    setState(() => _busy = true);
    try {
      final note = await _service.readNote();
      if (!mounted) return;
      // Retrying storage must not overwrite a draft already being edited.
      if (draft.isEmpty && _controller.text == draft) {
        _controller.text = note;
      }
      _savedNote = note;
      _loadFailed = false;
      _storageError = null;
    } catch (error) {
      if (!mounted) return;
      _loadFailed = true;
      _storageError = _errorMessage(error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _saveNote() async {
    setState(() => _busy = true);
    try {
      await _service.saveNote(_controller.text);
      if (!mounted) return;
      _savedNote = _controller.text;
      _loadFailed = false;
      _storageError = null;
      _showMessage('Note saved securely');
    } catch (error) {
      if (!mounted) return;
      _storageError = _errorMessage(error);
      _showMessage('Note was not saved. Your draft is still here.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _clearNote() async {
    setState(() => _busy = true);
    try {
      await _service.deleteNote();
      if (!mounted) return;
      _controller.clear();
      _savedNote = '';
      _loadFailed = false;
      _storageError = null;
      _showMessage('Note cleared');
    } catch (error) {
      if (!mounted) return;
      _storageError = _errorMessage(error);
      _showMessage('Could not clear note. Your draft is still here.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _errorMessage(Object error) {
    if (error is MissingPluginException) {
      return 'Secure storage needs a full app rebuild. Stop the app, '
          'run flutter pub get, then flutter run. Hot restart is not enough. '
          'You can still type here; your draft has not been saved.';
    }
    if (error is PlatformException) {
      // Do not display native details that might include private data.
      return 'Secure storage is unavailable (${error.code}). '
          'You can still write your note. Retry storage or try Save again.';
    }
    return 'Secure storage is temporarily unavailable. You can still write '
        'your note, then retry storage or try Save again.';
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  static const _ink = Color(0xFF202B2A);
  static const _muted = Color(0xFF5C6862);
  static const _lime = Color(0xFFDDF988);

  @override
  Widget build(BuildContext context) {
    final available = !_busy;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Secure Storage Demo'),
        leadingWidth: 64,
        leading: const Padding(
          padding: EdgeInsets.only(left: 20),
          child: Icon(Icons.lock_outline_rounded, size: 25),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _privacyBanner(context),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'A little space for you.',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.6,
                              ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.edit_note_rounded, color: _muted),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'One private note. Right where you left it.',
                    style: TextStyle(color: _muted, height: 1.5),
                  ),
                  const SizedBox(height: 20),
                  _noteEditor(available),
                  const SizedBox(height: 20),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final save = FilledButton.icon(
                        onPressed: available ? _saveNote : null,
                        icon: const Icon(Icons.lock_outline_rounded, size: 20),
                        label: const Text('Save'),
                      );
                      final clear = OutlinedButton.icon(
                        onPressed: available ? _clearNote : null,
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          size: 20,
                        ),
                        label: const Text('Clear'),
                      );
                      if (constraints.maxWidth < 290) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [save, const SizedBox(height: 12), clear],
                        );
                      }
                      return Row(
                        children: [
                          Expanded(flex: 2, child: save),
                          const SizedBox(width: 12),
                          Expanded(child: clear),
                        ],
                      );
                    },
                  ),
                  if (_storageError != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      _storageError!,
                      style: const TextStyle(
                        color: Color(0xFFA13636),
                        height: 1.5,
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: _busy ? null : _loadNote,
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Retry storage'),
                      ),
                    ),
                  ],
                  const SizedBox(height: 26),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.phonelink_lock_rounded,
                        size: 16,
                        color: _muted,
                      ),
                      SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Stored securely on this device',
                          style: TextStyle(color: _muted, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _privacyBanner(BuildContext context) => Container(
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      color: _ink,
      borderRadius: BorderRadius.circular(28),
    ),
    child: Stack(
      children: [
        Positioned(
          right: -45,
          top: -45,
          child: ExcludeSemantics(
            child: Container(
              width: 190,
              height: 190,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF3B4740), width: 32),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(26),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: _lime,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.shield_outlined, size: 14, color: _ink),
                    SizedBox(width: 6),
                    Text(
                      'YOUR PERSONAL SPACE',
                      style: TextStyle(
                        color: _ink,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'Private thoughts.\nSafely kept.',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: const Color(0xFFFAFAF3),
                  fontWeight: FontWeight.w600,
                  height: 1.12,
                  letterSpacing: -1.2,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'A quiet home for the things you want to keep close.',
                style: TextStyle(
                  color: Color(0xFFD0D8CF),
                  height: 1.6,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _noteEditor(bool available) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: const Color(0xFFE3E5DA)),
      boxShadow: const [
        BoxShadow(
          color: Color(0x09202B2A),
          blurRadius: 24,
          offset: Offset(0, 8),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Row(
            children: [
              const Icon(Icons.notes_rounded, size: 20, color: _muted),
              const SizedBox(width: 8),
              const Text(
                'MY NOTE',
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 1.4,
                  fontWeight: FontWeight.w700,
                  color: _muted,
                ),
              ),
              const Spacer(),
              const Icon(Icons.lock_rounded, size: 15, color: _muted),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
          child: TextField(
            controller: _controller,
            enabled: available,
            minLines: 5,
            maxLines: 10,
            enableSuggestions: false,
            autocorrect: false,
            style: const TextStyle(fontSize: 16, height: 1.75, color: _ink),
            decoration: const InputDecoration(
              labelText: 'Private Note',
              hintText: 'Something worth keeping to yourself...',
              hintMaxLines: 2,
              alignLabelWithHint: true,
              floatingLabelBehavior: FloatingLabelBehavior.always,
              contentPadding: EdgeInsets.all(12),
              border: OutlineInputBorder(borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(borderSide: BorderSide.none),
              disabledBorder: OutlineInputBorder(borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide(color: Color(0xFF527244)),
              ),
              hintStyle: TextStyle(
                color: Color(0xFF7B847B),
                fontWeight: FontWeight.w400,
              ),
              labelStyle: TextStyle(color: _muted),
            ),
          ),
        ),
        const Divider(height: 1, color: Color(0xFFEEF0E8)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: ValueListenableBuilder<TextEditingValue>(
            valueListenable: _controller,
            builder: (context, value, child) {
              final changed = value.text != _savedNote;
              final status = _busy
                  ? 'Working...'
                  : _loadFailed
                  ? 'Storage unavailable'
                  : changed
                  ? 'Unsaved changes'
                  : _savedNote.isEmpty
                  ? 'Ready to write'
                  : 'Saved on this device';
              return Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 16,
                runSpacing: 8,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _busy
                            ? Icons.hourglass_top_rounded
                            : changed
                            ? Icons.circle_outlined
                            : Icons.check_circle_outline_rounded,
                        size: 14,
                        color: _muted,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        status,
                        style: const TextStyle(fontSize: 11, color: _muted),
                      ),
                    ],
                  ),
                  Text(
                    '${value.text.characters.length} characters',
                    style: const TextStyle(fontSize: 11, color: _muted),
                  ),
                ],
              );
            },
          ),
        ),
        if (_busy)
          const LinearProgressIndicator(
            semanticsLabel: 'Accessing secure note',
            minHeight: 2,
          ),
      ],
    ),
  );
}
