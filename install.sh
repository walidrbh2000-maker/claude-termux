#!/data/data/com.termux/files/usr/bin/bash
# install.sh — Install Claude Code on Termux (Android ARM64)
# Usage: curl -fsSL https://raw.githubusercontent.com/walidrbh2000-maker/claude-termux/main/install.sh | bash
set -euo pipefail

PREFIX="${PREFIX:-/data/data/com.termux/files/usr}"
VERSIONS_DIR="$HOME/.local/share/claude/versions"
BIN_DIR="$PREFIX/bin"

echo "==> [1/5] Installing dependencies..."
pkg install -y curl jq patchelf glibc-repo glibc 2>/dev/null || pkg install -y curl jq patchelf

echo "==> [2/5] Resolving latest version..."
LATEST=$(curl -fsSL --max-time 15 https://registry.npmjs.org/@anthropic-ai/claude-code/latest | jq -r .version)
echo "    latest = $LATEST"
mkdir -p "$VERSIONS_DIR" "$HOME/.local/bin"

echo "==> [3/5] Downloading claude binary ($LATEST)..."
DL="https://downloads.claude.ai/claude-code-releases/$LATEST"
curl -fsSL --max-time 300 "$DL/linux-arm64/claude" -o "$VERSIONS_DIR/$LATEST.tmp"

echo "==> [4/5] Verifying checksum..."
EXP=$(curl -fsSL --max-time 15 "$DL/manifest.json" | jq -er '.platforms["linux-arm64"].checksum')
ACT=$(sha256sum "$VERSIONS_DIR/$LATEST.tmp" | cut -d' ' -f1)
if [ "$EXP" != "$ACT" ]; then
  rm -f "$VERSIONS_DIR/$LATEST.tmp"
  echo "ERROR: checksum mismatch (expected $EXP, got $ACT)" >&2
  exit 1
fi
chmod +x "$VERSIONS_DIR/$LATEST.tmp"

echo "==> [5/5] Patching interpreter + smoke test..."
GLIBC_LD="$PREFIX/glibc/lib/ld-linux-aarch64.so.1"
LD_PRELOAD= patchelf --set-interpreter "$GLIBC_LD" "$VERSIONS_DIR/$LATEST.tmp"
if ! bash "$(dirname "$0")/lib/smoke-test.sh" "$VERSIONS_DIR/$LATEST.tmp" "$VERSIONS_DIR"; then
  rm -f "$VERSIONS_DIR/$LATEST.tmp"
  echo "ERROR: $LATEST crashes on this device (smoke test failed)" >&2
  exit 1
fi
mv "$VERSIONS_DIR/$LATEST.tmp" "$VERSIONS_DIR/$LATEST"
printf '%s\n' "$LATEST" > "$VERSIONS_DIR/.verified"

cp "$(dirname "$0")/bin/claude" "$BIN_DIR/claude"
chmod +x "$BIN_DIR/claude"

echo ""
echo "✅ Claude Code $LATEST installed. Run: claude --version"
