#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION_FILE="$ROOT_DIR/android/version.properties"
DIST_DIR="$ROOT_DIR/build/dist"

usage() {
  cat <<'EOT'
Uso:
  scripts/build_android_release.sh [apk|aab|both]

Descrição:
  Gera build release assinada do Android usando key.properties.

Versão do app:
  Edite o arquivo: android/version.properties
    VERSION_CODE=51
    VERSION_NAME=1.0.32

Saídas:
  APK: build/app/outputs/flutter-apk/app-release.apk
  AAB: build/app/outputs/bundle/release/app-release.aab
  Cópias versionadas: build/dist/
EOT
}

TARGET="${1:-both}"
case "$TARGET" in
  apk|aab|both) ;;
  -h|--help|help)
    usage
    exit 0
    ;;
  *)
    echo "Alvo inválido: $TARGET"
    usage
    exit 1
    ;;
esac

if [[ ! -f "$ROOT_DIR/android/key.properties" ]]; then
  echo "Arquivo android/key.properties não encontrado."
  exit 1
fi

if [[ ! -f "$VERSION_FILE" ]]; then
  echo "Arquivo $VERSION_FILE não encontrado."
  exit 1
fi

VERSION_CODE="$(grep -E '^VERSION_CODE=' "$VERSION_FILE" | cut -d'=' -f2-)"
VERSION_NAME="$(grep -E '^VERSION_NAME=' "$VERSION_FILE" | cut -d'=' -f2-)"

if [[ -z "$VERSION_CODE" || -z "$VERSION_NAME" ]]; then
  echo "VERSION_CODE ou VERSION_NAME ausente em $VERSION_FILE"
  exit 1
fi

if ! [[ "$VERSION_CODE" =~ ^[0-9]+$ ]]; then
  echo "VERSION_CODE inválido: $VERSION_CODE"
  exit 1
fi

echo "Versão atual:"
echo "  VERSION_CODE=$VERSION_CODE"
echo "  VERSION_NAME=$VERSION_NAME"
echo

cd "$ROOT_DIR"
flutter pub get

BUILD_ARGS=(--release --build-name="$VERSION_NAME" --build-number="$VERSION_CODE")

if [[ "$TARGET" == "apk" || "$TARGET" == "both" ]]; then
  echo "Gerando APK release assinado..."
  flutter build apk "${BUILD_ARGS[@]}"
fi

if [[ "$TARGET" == "aab" || "$TARGET" == "both" ]]; then
  echo "Gerando AAB release assinado..."
  flutter build appbundle "${BUILD_ARGS[@]}"
fi

mkdir -p "$DIST_DIR"
if [[ -f "$ROOT_DIR/build/app/outputs/flutter-apk/app-release.apk" ]]; then
  cp "$ROOT_DIR/build/app/outputs/flutter-apk/app-release.apk" "$DIST_DIR/emprestimos_app_luciano-v${VERSION_NAME}+${VERSION_CODE}.apk"
fi
if [[ -f "$ROOT_DIR/build/app/outputs/bundle/release/app-release.aab" ]]; then
  cp "$ROOT_DIR/build/app/outputs/bundle/release/app-release.aab" "$DIST_DIR/emprestimos_app_luciano-v${VERSION_NAME}+${VERSION_CODE}.aab"
fi

echo
echo "Build finalizada."
[[ -f "$ROOT_DIR/build/app/outputs/flutter-apk/app-release.apk" ]] && echo "APK: build/app/outputs/flutter-apk/app-release.apk"
[[ -f "$ROOT_DIR/build/app/outputs/bundle/release/app-release.aab" ]] && echo "AAB: build/app/outputs/bundle/release/app-release.aab"
[[ -d "$DIST_DIR" ]] && echo "Arquivos versionados: build/dist/"
