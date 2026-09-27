# Claude Code on Termux (Android ARM64)

One-command installer + self-updating launcher for [Claude Code](https://claude.com/claude-code) on Termux. The official binary needs a glibc interpreter patch plus crash-guard logic to survive on Android — this repo automates all of it.

## Install

```bash
pkg install -y git
git clone https://github.com/walidrbh2000-maker/claude-termux
cd claude-termux
bash install.sh
```

Then:

```bash
claude --version   # login on first run
```

## What it does

1. Installs deps (`curl`, `jq`, `patchelf`, `glibc`)
2. Downloads the latest `linux-arm64` binary from `downloads.claude.ai`
3. Verifies the SHA-256 checksum against the release manifest
4. Patches the ELF interpreter to Termux glibc via `patchelf`
5. Smoke-tests with `--init-only` in an isolated `HOME` before promoting
6. Installs the `claude` launcher to `$PREFIX/bin`

## Launcher features (`bin/claude`)

- **Daily auto-update** (checks npm registry max once/24h, `claude --update-now` forces it)
- **Self-healing rollback**: crashing releases fail the smoke test → blocklisted → previous working version runs
- **Keeps latest + previous** binary, prunes older ones
- **DNS fix**: preloads Google DNS (`8.8.8.8`) — Termux DNS often breaks Bun's resolver
- **Unsets `LD_PRELOAD`** before exec so no shim leaks into the runtime

## Requirements

- Termux on Android, `aarch64` (`uname -m`)
- ~500 MB free (binary is ~230 MB × 2 retained versions)
- Internet

## Files

| File | Purpose |
|---|---|
| `install.sh` | One-shot installer |
| `bin/claude` | Launcher wrapper (installed to `$PREFIX/bin`) |
| `lib/smoke-test.sh` | Launch-probe used by installer + launcher |

## License

MIT
