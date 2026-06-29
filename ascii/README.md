# Custom Header System for Snacks Dashboard

A custom header cycling system for Neovim's Snacks dashboard with support for high-quality terminal graphics (via Chafa) and ASCII art headers.

## 📁 Directory Structure

```
.
├── img/                  # High-quality images for the dashboard
│   ├── asuka.jpg
│   ├── calico.jpg
│   └── ...
├── ascii/
│   ├── headers/          # ASCII Header files organized by category
│   │   ├── anime/        # Anime headers (8 headers with ANSI colors)
│   │   ├── logos/        # Logo headers (KRAKENVIM, Neovim official)
│   │   ├── minimal/      # Minimal/compact headers
│   │   └── custom/       # Your custom ASCII headers
│   ├── cache/            # Temporary conversion cache (gitignored)
│   └── README.md         # This file
├── lua/
│   ├── plugins/
│   │   └── ui.lua        # Snacks dashboard configuration
│   └── utils/
│       └── img_manager.lua # Image cycling logic
└── scripts/
    └── img2ascii.sh      # Script to convert images to ASCII art
```

## 🎨 Available Headers

### Image Mode (Default)

- Supports high-resolution rendering using `chafa`.
- Place your images in the `img/` directory.

### ASCII Categories

- **anime/** - 8 colorful anime-style headers
  - abstract_portrait, black_cat, blue_bubblegum, calm_eyes
  - cat_girl, color_eyes, girl_bandaged_eyes, red_jpa
  
- **logos/** - Logo headers
  - krakenvim - Custom KRAKENVIM logo
  - neovim_official - Standard Neovim logo
  
- **minimal/** - Compact headers
  - simple_nvim - Minimal Neovim logo

- **custom/** - Your custom ASCII headers

## ⌨️ Keybindings

| Key | Action | Description |
|-----|--------|-------------|
| `<leader>h` | `require("snacks").dashboard()` | Open dashboard |
| `<leader>An` | `:SnacksDashboardImageNext` | Cycle to next image/header |
| `<leader>Ap` | `:SnacksDashboardImagePrev` | Cycle to previous image/header |
| `<leader>Ar` | `:SnacksDashboardImageRandom` | Jump to random image/header |
| `<leader>Ai` | `:SnacksDashboardImageName` | Show current header name |
| `i` (on dashboard) | Cycle to next | Quick cycling |

## 🔧 Commands

- `:SnacksDashboardImageNext` - Cycle forward through images/headers
- `:SnacksDashboardImagePrev` - Cycle backward through images/headers
- `:SnacksDashboardImageRandom` - Jump to a random image/header
- `:SnacksDashboardImageName` - Display current header name and position
- `:CycleHeader` - Generic command to cycle based on current mode

## 📝 Adding Custom Headers

### Method 1: Add an Image (Recommended)

Place any PNG, JPG, or GIF in the `img/` directory at the root of your config.

### Method 2: Create a Lua ASCII File

Create a file in `ascii/headers/custom/myheader.lua`:

```lua
-- My Custom Header
local header = {
    "  ╔═══════════════╗",
    "  ║  MY HEADER    ║",
    "  ╚═══════════════╝",
}

return { header = header }
```

### Method 3: Convert an Image to ASCII

Use the included `img2ascii.sh` script (requires `libcaca`):

```bash
./scripts/img2ascii.sh path/to/image.png my_header
```

## ⚙️ Configuration

The system is configured in `lua/plugins/ui.lua`. You can switch between "image" and "ascii" modes:

```lua
-- lua/plugins/ui.lua
local header_mode = "image" -- change to "ascii" to use ASCII headers
```

## 📐 Requirements

- **Image Mode**: Requires `chafa` installed on your system.
- **ASCII Mode**: No external dependencies for built-in headers.
- **Image Conversion**: Requires `img2txt` from `libcaca-utils`.

## 🐛 Troubleshooting

**"Images look blurry or broken"**
- Ensure `chafa` is installed.
- Check terminal window size; terminal graphics require enough space to render correctly.
- Verify 24-bit color support: `echo $COLORTERM` (should be `truecolor` or `24bit`).

**"Custom image not showing"**
- Check that the image is in the `img/` folder.
- Run `:CycleHeader` or restart Neovim.
- Verify the image format is supported by Chafa.

---

**Enjoy your custom dashboard!** 🎨
