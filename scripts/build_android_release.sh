#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION_FILE="$ROOT_DIR/android/version.properties"

usage() {
  cat <<'EOF'
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
EOF
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

echo "Versão atual:"
grep -E '^VERSION_(CODE|NAME)=' "$VERSION_FILE" || true
echo

cd "$ROOT_DIR"
flutter pub get

if [[ "$TARGET" == "apk" || "$TARGET" == "both" ]]; then
  echo "Gerando APK release assinado..."
  flutter build apk --release
fi

if [[ "$TARGET" == "aab" || "$TARGET" == "both" ]]; then
  echo "Gerando AAB release assinado..."
  flutter build appbundle --release
fi

echo
echo "Build finalizada."
[[ -f "$ROOT_DIR/build/app/outputs/flutter-apk/app-release.apk" ]] && echo "APK: build/app/outputs/flutter-apk/app-release.apk"
[[ -f "$ROOT_DIR/build/app/outputs/bundle/release/app-release.aab" ]] && echo "AAB: build/app/outputs/bundle/release/app-release.aab"
