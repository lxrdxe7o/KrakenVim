-- Colorscheme plugins
-- All theme plugins are centralized here
-- The persistent picker logic is in lua/config/colorscheme.lua

return {
  -- Bamboo (default theme)
  {
    "ribru17/bamboo.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("bamboo").setup({
        style = "multiplex",
        toggle_style_key = nil,
        toggle_style_list = { "vulgaris", "multiplex", "light" },
        transparent = true,
        dim_inactive = false,
        term_colors = false,
        ending_tildes = true,
        cmp_itemkind_reverse = false,
        code_style = {
          comments = { italic = true },
          conditionals = { italic = true },
          keywords = {},
          functions = {},
          namespaces = { italic = true },
          parameters = { italic = true },
          strings = {},
          variables = {},
        },
        lualine = { transparent = true },
        colors = {},
        highlights = {},
        diagnostics = {
          darker = false,
          undercurl = false,
          background = true,
        },
      })
      -- Don't load here - let config/colorscheme.lua handle it
    end,
  },

  -- Miasma
  {
    "xero/miasma.nvim",
    lazy = false,
    priority = 1000,
  },

  -- Cyberdream
  {
    "scottmckendry/cyberdream.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      variant = "default",
      transparent = true,
      saturation = 1,
      italic_comments = true,
      hide_fillchars = false,
      borderless_pickers = true,
      terminal_colors = true,
      cache = true,
      extensions = {
        cmp = true,
        gitsigns = true,
        indentblankline = true,
        lazy = false,
        markdown = true,
        mini = true,
        notify = true,
        telescope = true,
        treesitter = true,
        treesittercontext = true,
        trouble = true,
        whichkey = true,
      },
    },
  },

  -- Gruvbox
  {
    "ellisonleao/gruvbox.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      terminal_colors = true,
      undercurl = true,
      underline = true,
      bold = true,
      italic = {
        strings = true,
        emphasis = true,
        comments = true,
        operators = false,
        folds = true,
      },
      strikethrough = true,
      invert_selection = false,
      invert_signs = false,
      invert_tabline = false,
      invert_intend_guides = false,
      inverse = true,
      contrast = "",
      palette_overrides = {},
      overrides = {},
      dim_inactive = false,
      transparent_mode = true,
    },
  },

  -- Catppuccin
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    opts = {
      flavour = "mocha",
      background = {
        light = "latte",
        dark = "mocha",
      },
      transparent_background = true,
      show_end_of_buffer = false,
      term_colors = true,
      dim_inactive = {
        enabled = false,
        shade = "dark",
        percentage = 0.15,
      },
      styles = {
        comments = { "italic" },
        conditionals = { "italic" },
        loops = {},
        functions = {},
        keywords = {},
        strings = {},
        variables = {},
        numbers = {},
        booleans = {},
        properties = {},
        types = {},
        operators = {},
      },
      integrations = {
        cmp = true,
        gitsigns = true,
        nvimtree = true,
        treesitter = true,
        notify = true,
        mini = { enabled = true },
        telescope = { enabled = true },
        which_key = true,
        indent_blankline = { enabled = true },
        native_lsp = {
          enabled = true,
          underlines = {
            errors = { "undercurl" },
            hints = { "undercurl" },
            warnings = { "undercurl" },
            information = { "undercurl" },
          },
        },
      },
    },
  },

  -- TokyoNight
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      style = "night",
      transparent = true,
      terminal_colors = true,
      styles = {
        comments = { italic = true },
        keywords = { italic = true },
        functions = {},
        variables = {},
        sidebars = "transparent",
        floats = "transparent",
      },
      sidebars = { "qf", "help" },
      day_brightness = 0.3,
      hide_inactive_statusline = false,
      dim_inactive = false,
      lualine_bold = false,
    },
  },

  -- OneDark
  {
    "navarasu/onedark.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      style = "dark",
      transparent = true,
      term_colors = true,
      ending_tildes = false,
      cmp_itemkind_reverse = false,
      toggle_style_key = nil,
      code_style = {
        comments = "italic",
        keywords = "none",
        functions = "none",
        strings = "none",
        variables = "none",
      },
      lualine = { transparent = true },
      diagnostics = {
        darker = true,
        undercurl = true,
        background = true,
      },
    },
  },

  -- Kanagawa
  {
    "rebelot/kanagawa.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      compile = false,
      undercurl = true,
      commentStyle = { italic = true },
      functionStyle = {},
      keywordStyle = { italic = true },
      statementStyle = { bold = true },
      typeStyle = {},
      transparent = true,
      dimInactive = false,
      terminalColors = true,
      theme = "wave",
      background = { dark = "wave", light = "lotus" },
    },
  },

  -- Rose Pine
  {
    "rose-pine/neovim",
    name = "rose-pine",
    lazy = false,
    priority = 1000,
    opts = {
      variant = "auto",
      dark_variant = "main",
      dim_inactive_windows = false,
      extend_background_behind_borders = true,
      enable = { terminal = true },
      styles = {
        bold = true,
        italic = true,
        transparency = true,
      },
    },
  },

  -- Nightfox
  {
    "EdenEast/nightfox.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      options = {
        compile_path = vim.fn.stdpath("cache") .. "/nightfox",
        compile_file_suffix = "_compiled",
        transparent = true,
        terminal_colors = true,
        dim_inactive = false,
        module_default = true,
        styles = {
          comments = "italic",
          conditionals = "NONE",
          constants = "NONE",
          functions = "NONE",
          keywords = "NONE",
          numbers = "NONE",
          operators = "NONE",
          strings = "NONE",
          types = "NONE",
          variables = "NONE",
        },
        inverse = {
          match_paren = false,
          visual = false,
          search = false,
        },
      },
    },
  },

  -- Dracula
  {
    "Mofiqul/dracula.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      colors = {},
      show_end_of_buffer = true,
      transparent_bg = true,
      lualine_bg_color = "#44475a",
      italic_comment = true,
    },
  },

  -- Nord
  {
    "shaunsingh/nord.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.g.nord_contrast = true
      vim.g.nord_borders = false
      vim.g.nord_disable_background = true
      vim.g.nord_italic = true
      vim.g.nord_uniform_diff_background = true
      vim.g.nord_bold = false
    end,
  },

  -- Everforest
  {
    "sainnhe/everforest",
    lazy = false,
    priority = 1000,
    config = function()
      vim.g.everforest_background = "medium"
      vim.g.everforest_transparent_background = 2
      vim.g.everforest_ui_contrast = "high"
      vim.g.everforest_enable_italic = 1
      vim.g.everforest_diagnostic_text_highlight = 1
      vim.g.everforest_diagnostic_virtual_text = "colored"
      vim.g.everforest_better_performance = 1
    end,
  },

  -- Solarized Osaka
  {
    "craftzdog/solarized-osaka.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      transparent = true,
      terminal_colors = true,
      styles = {
        comments = { italic = true },
        keywords = { italic = true },
        functions = {},
        variables = {},
        sidebars = "transparent",
        floats = "transparent",
      },
      sidebars = { "qf", "help" },
      day_brightness = 0.3,
      hide_inactive_statusline = false,
      dim_inactive = false,
      lualine_bold = false,
    },
  },
}
