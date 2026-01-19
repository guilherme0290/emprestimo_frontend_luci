# Repository Guidelines

## Project Structure & Module Organization
- `lib/` contains the Flutter app code. Key areas: `lib/main.dart` (entry), `lib/core/` (config, constants, services), `lib/models/` (data models), `lib/providers/` (state), `lib/services/` (API), `lib/screens/` (UI screens), `lib/widgets/` (reusable UI).
- `assets/` holds images and fonts used by the UI.
- `test/` contains Flutter tests (currently `test/widget_test.dart`).
- `android/`, `ios/`, and `web/` contain platform-specific integration and build files.

## Frontend Project Map
- Entry point: `lib/main.dart`
- App layers: `lib/core/` (config/theme), `lib/models/`, `lib/providers/`, `lib/services/`, `lib/widgets/`
- Feature screens: `lib/screens/` with modules like `auth/`, `home/`, `clientes/`, `emprestimos/`, `parcelas/`, `cobranca/`, `transferencia/`, `vendedores/`, `planos/`, `relatorio/`, `score/`, `notificacoes/`, `config/`, `parametros/`, `localizar_parcela/`
- Assets: `assets/` (images/fonts)

## Build, Test, and Development Commands
- `flutter pub get` to install dependencies.
- `flutter run` to run the app on a connected device or emulator.
- `flutter test` to run the test suite.
- `flutter build appbundle --release` to build the Android release bundle.
- `./deploy_web.sh` to build and deploy the web build to the configured remote host (uses `ssh` and `rsync`).

## Coding Style & Naming Conventions
- Indentation: 2 spaces, no tabs.
- Dart style: follow `analysis_options.yaml` and format with `dart format lib test`.
- Naming: `UpperCamelCase` for classes, `lowerCamelCase` for variables and methods, `snake_case.dart` for file names.
- Keep widgets small and focused; prefer extracting repeated UI into `lib/widgets/`.

## Testing Guidelines
- Use the Flutter testing stack (`flutter_test`).
- Name tests with the `_test.dart` suffix and keep test files under `test/`.
- Add or update tests for new UI logic or state management changes.

## Commit & Pull Request Guidelines
- Commit messages in this repo are short, descriptive, and written in Portuguese (for example: "correcao bug alteracao de senha"). Avoid extra prefixes unless needed.
- PRs should include a brief summary, steps to verify, and screenshots for UI changes.
- Link relevant issues or tickets if available and call out any configuration changes.

## Security & Configuration Tips
- Firebase config files like `android/app/google-services.json` and `lib/firebase_options.dart` are part of the app setup. Avoid committing new secrets or environment-specific keys without approval.
