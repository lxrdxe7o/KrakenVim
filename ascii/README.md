# Custom Header System for Alpha Dashboard

A custom header cycling system for Neovim's Alpha dashboard with support for ASCII art headers, ANSI colors, and image conversion.

## 📁 Directory Structure

```
ascii/
├── headers/              # Header files organized by category
│   ├── anime/           # Alpha-ASCII anime headers (8 headers with ANSI colors)
│   ├── logos/           # Logo headers (KRAKENVIM, Neovim official)
│   ├── minimal/         # Minimal/compact headers
│   └── custom/          # Your custom headers and converted images
├── images/              # Source images for conversion
│   ├── examples/        # Example images
│   └── custom/          # Your custom images
├── cache/               # Temporary conversion cache (gitignored)
└── README.md            # This file
```

## 🎨 Available Headers

### Categories

- **anime/** - 8 colorful anime-style headers from alpha-ascii.nvim
  - abstract_portrait, black_cat, blue_bubblegum, calm_eyes
  - cat_girl, color_eyes, girl_bandaged_eyes, red_jpa
  
- **logos/** - Logo headers
  - krakenvim - Your custom KRAKENVIM logo
  - neovim_official - Standard Neovim logo
  
- **minimal/** - Compact headers
  - simple_nvim - Minimal Neovim logo

- **custom/** - Your custom headers (add your own here!)

## ⌨️ Keybindings

| Key | Command | Description |
|-----|---------|-------------|
| `<leader>ah` | `:Alpha` | Open Alpha dashboard |
| `<leader>an` | `:AlphaHeaderNext` | Cycle to next header |
| `<leader>ap` | `:AlphaHeaderPrev` | Cycle to previous header |
| `<leader>ar` | `:AlphaHeaderRandom` | Jump to random header |
| `<leader>ai` | `:AlphaHeaderName` | Show current header name |
| `i` (on dashboard) | Cycle to next header | Quick cycling |

## 🔧 Commands

- `:AlphaHeaderNext` - Cycle forward through all headers
- `:AlphaHeaderPrev` - Cycle backward through all headers
- `:AlphaHeaderRandom` - Jump to a random header
- `:AlphaHeaderName` - Display current header name and position

## 📝 Adding Custom Headers

### Method 1: Create a Lua File

Create a file in `headers/custom/myheader.lua`:

```lua
-- My Custom Header
local header = {
    "  ╔═══════════════╗",
    "  ║  MY HEADER    ║",
    "  ╚═══════════════╝",
}

return { header = header }
```

**Simple format** - Just an array of strings:
```lua
local header = {
    "Line 1",
    "Line 2",
}
return { header = header }
```

**Advanced format** - With ANSI colors (like alpha-ascii):
```lua
-- Define highlight groups
vim.api.nvim_set_hl(0, "MyHL0", { fg="#ff0000" })
vim.api.nvim_set_hl(0, "MyHL1", { fg="#00ff00" })

local header = {
    type = 'text',
    opts = {
        position = 'center',
        hl = {
            { { "MyHL0", 0, 5 }, { "MyHL1", 5, 10 } },  -- Line 1 colors
            { { "MyHL0", 0, 5 }, { "MyHL1", 5, 10 } },  -- Line 2 colors
        }
    },
    val = {
        "ColoredLine1",
        "ColoredLine2",
    }
}
return { header = header }
```

### Method 2: Convert an Image

Use the included `img2ascii.sh` script:

```bash
# Basic usage (48x24 default)
./scripts/img2ascii.sh path/to/image.png my_header

# Custom dimensions
./scripts/img2ascii.sh path/to/logo.jpg cool_logo 60 30

# From any location
~/.config/nvim/scripts/img2ascii.sh ~/Pictures/cat.png my_cat
```

**Generated file:** `headers/custom/my_header.lua`

**Supported formats:** PNG, JPG, GIF, WebP

**Requirements:** `img2txt` from `libcaca-utils`
- Arch: `sudo pacman -S libcaca`
- Ubuntu/Debian: `sudo apt install caca-utils`

## ⚙️ Configuration

Settings are in `lua/utils/header_manager.lua`:

```lua
M.config = {
    headers_path = vim.fn.stdpath("config") .. "/ascii/headers",
    max_width = 48,           -- Max header width (characters)
    max_height = 24,          -- Max header height (lines)
    remember_last = true,     -- Remember last header across sessions
    random_on_start = false,  -- Use random header on each startup
}
```

### Customization Options

**Remember last header (default):**
```lua
remember_last = true      -- Restores last used header
random_on_start = false
```

**Random header on each start:**
```lua
remember_last = false
random_on_start = true    -- New random header every time
```

**Always start with same header:**
```lua
remember_last = false
random_on_start = false   -- Always starts with first header
```

## 🔄 How It Works

1. **Startup:** HeaderManager scans `ascii/headers/` recursively
2. **Loading:** Headers are loaded on-demand when cycling
3. **State:** Last header saved to `.nvim_state/last_header.txt`
4. **Cycling:** Wraps around (next after last = first)
5. **Categories:** All categories cycle together (anime → logos → minimal → custom)

## 📐 Header Specifications

**Size Limits:**
- Max width: 48 characters (alpha-ascii compatible)
- Max height: 24 lines
- Larger headers may work but aren't enforced

**Format Support:**
- ✅ Simple text (array of strings)
- ✅ ANSI colors (alpha-ascii format)
- ✅ UTF-8 characters and symbols
- ✅ Box drawing characters

## 🎯 Tips & Tricks

### Quick Header Testing

After adding a new header:
```
:lua require('utils.header_manager').init()  -- Rescan headers
:AlphaHeaderRandom                           -- Load random header
```

### Create ASCII Art Online

**Text generators:**
- https://patorjk.com/software/taag/ - ASCII text art
- https://www.asciiart.eu/ - Pre-made ASCII art

**Image to ASCII:**
- https://www.text-image.com/convert/ascii.html
- Or use included `img2ascii.sh` script

### Finding Your Last Header

```
:!cat ~/.config/nvim/.nvim_state/last_header.txt
```

### Disable Header Memory

Edit `lua/utils/header_manager.lua`:
```lua
remember_last = false,
random_on_start = true,  -- Random every time
```

## 🐛 Troubleshooting

**"No headers found"**
- Check that header files exist in `ascii/headers/`
- Ensure files end with `.lua`
- Verify file format (must return `{ header = {...} }`)

**Header not showing**
- Check Lua syntax: `luac -p headers/custom/myheader.lua`
- Verify return format: `{ header = {...} }`
- Check for special characters that need escaping

**Colors not working**
- Ensure using advanced format with highlight definitions
- Check that highlight groups are defined before header table
- Terminal must support 256 colors

**Image conversion fails**
- Install libcaca: `sudo pacman -S libcaca`
- Check image file exists and is readable
- Try with smaller dimensions first

**Script not executable**
- Run: `chmod +x ~/.config/nvim/scripts/img2ascii.sh`

## 📚 Examples

### Example 1: Simple Custom Header

`headers/custom/welcome.lua`:
```lua
local header = {
    "                ",
    "  Welcome Back  ",
    "                ",
}
return { header = header }
```

### Example 2: Convert Your Avatar

```bash
# Download or place your image in ascii/images/custom/
./scripts/img2ascii.sh ascii/images/custom/avatar.png my_avatar 40 20
```

### Example 3: Seasonal Headers

Create `headers/custom/winter.lua`, `summer.lua`, etc., and cycle through them!

## 🔗 Integration

The header system integrates with:
- **Alpha Dashboard:** Automatic header application
- **Lazy.nvim:** No impact on startup time (on-demand loading)
- **Git:** State file and cache are gitignored
- **Colorschemes:** ANSI colors work with any colorscheme

## 📄 License

Part of your Neovim configuration. Headers from alpha-ascii.nvim retain their original licensing.

---

**Enjoy your custom headers!** 🎨

For issues or suggestions, check your configuration in:
- `lua/utils/header_manager.lua` - Core logic
- `lua/plugins/ui.lua` - Dashboard integration
- `lua/config/keymaps.lua` - Keybindings
