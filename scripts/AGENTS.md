# Utility Scripts

## Context
Utility scripts for the KRAKENVIM Neovim configuration. Parent context: [../AGENTS.md](../AGENTS.md).

## Files

| Path | Purpose |
|---|---|
| `scripts/img2ascii.sh` | Convert images to ASCII art Lua headers |

## `img2ascii.sh` — Image to ASCII Converter

Converts an image (PNG, JPG, GIF, WebP) into a Lua-formatted ASCII art header for the dashboard. Requires `img2txt` from the `libcaca-utils` package.

### Usage
```bash
./scripts/img2ascii.sh IMAGE OUTPUT_NAME [WIDTH=48] [HEIGHT=24]
```

### Output
- Generates `ascii/headers/custom/<OUTPUT_NAME>.lua` with the correct `return { header = { ... } }` format
- Creates intermediate text file in `ascii/cache/` (deleted after conversion)
- Caches images to `ascii/cache/`

### Dependencies
- `img2txt` (libcaca-utils) — Arch: `sudo pacman -S libcaca`, Ubuntu: `sudo apt install caca-utils`

## Scripts Pattern
- Scripts in `scripts/` are standalone shell tools, not invoked by Neovim directly.
- They support the `ascii/headers/` pipeline — converting external images into the internal header format.
- New scripts added here should follow the `set -euo pipefail` strict mode convention.

## Ownership
- DevOps / generalist
