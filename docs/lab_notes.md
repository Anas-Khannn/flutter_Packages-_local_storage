# Lab Task 07: Flutter Packages, Local Storage and Application Data

## Dependency declaration

Current pubspec.yaml dependency snippet:

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  flutter_secure_storage: ^11.2.0
```

The current pubspec.lock resolves flutter_secure_storage 11.2.0.

## Why commit pubspec.lock?

Flutter applications normally commit pubspec.lock so each checkout resolves the same package versions.
It records exact versions for direct and transitive dependencies.
This makes development, CI builds, and bug reproduction more consistent.
Update it deliberately when upgrading dependencies, and commit it with pubspec.yaml.

## Package evaluation

Checked on 2026-11-03 using the [pub.dev package page](https://pub.dev/packages/flutter_secure_storage)
and [version history](https://pub.dev/packages/flutter_secure_storage/versions).

- Publisher: verified publisher `steenbakker.dev`.
- Platforms: Android, iOS, macOS, Linux, Windows, and web.
- Release recency: pub.dev listed 11.2.0 as latest, published 48 days ago at lookup time.
- License: BSD-3-Clause.
- SDK constraints: pub.dev lists minimum Dart 3.8 for 11.2.0. Full Dart upper bound and Flutter constraint: TO VERIFY ON pub.dev after installing the resolved version.
- Documentation quality (assessment): useful README examples for write/read/delete, platform setup, and linked API documentation; platform sections need careful reading.

The lockfile now resolves version 11.2.0. The platform changes follow the
published 11.2.0 README and must be rechecked against the version pub resolves.

## Platform setup

Source: [version 11.2.0 README](https://pub.dev/packages/flutter_secure_storage/versions/11.2.0).

- Android: minimum API 23, preserving any higher Flutter minimum; auto-backup disabled in AndroidManifest.xml as recommended by the README.
- iOS/macOS: keychain-access-groups added to Debug/Profile and Release entitlements. iOS build configurations reference these entitlement files. Apple signing/provisioning must be verified on a Mac.
- Windows: install Visual Studio C++ build tools including the optional ATL component.
- Linux: install libsecret development/runtime packages and provide a keyring service.
- Web: use HTTPS or localhost. README labels web support experimental and calls for suitable security headers on deployment.
- main() initializes the Flutter binding before the screen accesses the plugin.

## Viva questions

1. **Dart package vs Flutter plugin:** A Dart package provides reusable Dart code. A Flutter plugin is a package that integrates platform functionality, often through native implementations.
2. **What is pub.dev for?** Discovering, evaluating, publishing, and obtaining Dart and Flutter packages and their documentation.
3. **What should you check before adding a package?** Publisher, maintenance and release history, platform support, SDK compatibility, license, documentation, dependencies, and setup requirements.
4. **Purpose of pubspec.yaml:** Declares project metadata, SDK constraints, dependencies, assets, and Flutter configuration.
5. **dependencies vs dev_dependencies:** Runtime application packages belong in dependencies; development tools, linters, and test libraries belong in dev_dependencies.
6. **Why secure storage for sensitive values?** It uses platform security mechanisms to protect values at rest instead of ordinary unprotected settings storage.
7. **What data suits secure storage?** Small sensitive values such as access tokens, credentials when required, and a short private note. Avoid bulk data and large documents.
8. **Service methods:** saveNote writes/replaces the private_note value; readNote returns it or an empty string; deleteNote removes that one key.
9. **When does a local database beat preferences?** When storing many structured records that need filtering, sorting, relationships, transactions, or offline queries.
10. **When is a cloud/backend required?** When data must be shared or synchronized across users/devices, centrally controlled, remotely backed up, or processed by trusted server logic.

## Verification status

Re-run on 2026-11-03 with full Flutter SDK access. Logs are saved in `docs/`.

- `flutter pub get` / `flutter pub deps`: dependencies resolved (`docs/pub_get_output.txt`, `docs/pub_deps_output.txt`).
- `flutter analyze`: no issues found (`docs/analyze_output.txt`).
- `flutter test`: all 4 tests passed (`docs/test_output.txt`).
- `flutter build apk --debug`: `app-debug.apk` built successfully (`docs/build_output.txt`).
- iOS, macOS, Linux, Windows, and web builds were not verified.
- Tests use FlutterSecureStorage.setMockInitialValues to avoid native storage calls. They check controls and save/reload/clear behavior with an in-memory mock; physical-device persistence still needs manual verification.

## Manual submission screenshots

- pubspec.yaml showing the resolved flutter_secure_storage dependency.
- App before saving with the empty Private Note field and Save/Clear controls.
- App after saving a non-sensitive sample note, with the success SnackBar.
- App after fully closing and reopening: the same saved sample note is restored.
- App after Clear, and optionally after another restart showing the empty field.
- Source files: lib/main.dart, lib/services/secure_storage_service.dart, and lib/screens/secure_note_screen.dart.
- Successful analyze/test/build output and dependency tree (saved in `docs/`).

