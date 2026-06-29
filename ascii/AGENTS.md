# ASCII Headers

## Context
This directory contains the dashboard header system for KRAKENVIM, supporting both image-based headers (via chafa) and ASCII art headers. Parent context: [../AGENTS.md](../AGENTS.md).

## Structure

```
ascii/
├── README.md                  # Documentation
├── headers/                   # Source Lua files for ASCII art
│   ├── rocket.lua             # "To the Moon!" rocket header
│   ├── neovim.lua             # Neovim logo header
│   ├── test.lua               # Test header
│   ├── logos/
│   │   ├── neovim_official.lua
│   │   └── krakenvim.lua      # KRAKENVIM custom logo
│   ├── minimal/
│   │   └── simple_nvim.lua    # Minimal design
│   └── anime/                 # 8 anime-style headers
│       ├── color_eyes.lua
│       ├── girl_bandaged_eyes.lua
│       ├── red_jpa.lua
│       ├── blue_bubblegum.lua
│       ├── calm_eyes.lua
│       ├── cat_girl.lua
│       ├── black_cat.lua
│       └── abstract_portrait.lua
└── cache/                     # Cached ASCII conversions (gitignored)
```

## Header File Format
Every `.lua` file in `ascii/headers/` must return a table with a `header` key:
```lua
return {
  header = {
    "    __    __  ________   ______  ",
    "   / /   / / / / __/ /  / __/ /  ",
    ...
  }
}
```

## How It Works
1. `lua/ascii/loader.lua` scans `ascii/headers/` recursively at startup, loads all `.lua` files via `dofile`, and collects headers that match the `{ header = {...} }` format.
2. The loader provides `get_ascii_cmd()` which generates a shell command (`echo ... && echo ...`) that the dashboard (snacks.nvim) runs in a terminal section.
3. The `header_mode` variable in `lua/plugins/ui.lua` toggles between `"image"` (chafa from `img/`) and `"ascii"` (this system).

## Key Paths

| Path | Purpose |
|---|---|
| `lua/ascii/loader.lua` | Header scanning, loading, cycling, and command generation |
| `ascii/headers/` | Source Lua header files (11 built-in) |
| `scripts/img2ascii.sh` | Convert images to ASCII art headers (uses img2txt/libcaca) |

## Patterns
- **Category subdirectories**: `logos/`, `minimal/`, `anime/`, `custom/` — provides logical grouping.
- **Cyclic index**: `next()` wraps around (`current_index % #headers + 1`).
- **Persistent state**: the loader does NOT persist the current header index (unlike `img_manager.lua`), but image mode does via `.nvim_state/last_image.txt`.

## Constraints
- Adding a new header: create a `.lua` file in `ascii/headers/`, reload Neovim (or restart).
- The `scripts/img2ascii.sh` script outputs to `ascii/headers/custom/`.
- `lua/ascii/loader.lua` only loads files at startup — no hot-reload.

## Ownership
- Creative/art profile: header content
- Generalist: loader module, integration with dashboard
