return {
  -- Discord Presence (from user.lua)
  {
    "andweeb/presence.nvim",
    event = "VeryLazy",
    opts = {
      auto_update = true,
      neovim_image_text = "KRAKENVIM",
      main_image = "neovim",
      log_level = nil,
      debounce_timeout = 10,
      enable_line_number = false,
    },
  },

  -- Pomo: Pomodoro timer (from user.lua)
  {
    "epwalsh/pomo.nvim",
    version = "*",
    lazy = true,
    cmd = { "TimerStart", "TimerRepeat", "TimerSession" },
    dependencies = { "rcarriga/nvim-notify" },
    opts = {},
    keys = {
      { "<leader>tp", "<cmd>TimerStart 25m<cr>", desc = "Start Pomodoro (25m)" },
      { "<leader>tb", "<cmd>TimerStart 5m<cr>", desc = "Start Break (5m)" },
      { "<leader>ts", "<cmd>TimerSession pomodoro<cr>", desc = "Start Pomodoro Session" },
    },
  },

  -- Typr: Typing practice (from user.lua)
  {
    "nvzone/typr",
    dependencies = "nvzone/volt",
    cmd = { "Typr", "TyprStats" },
    opts = {},
    keys = {
      { "<leader>ty", "<cmd>Typr<cr>", desc = "Start Typr" },
    },
  },

  -- Obsidian.nvim (FIXED from dormant user.lua config)
  {
    "epwalsh/obsidian.nvim",
    version = "*",
    lazy = true,
    ft = "markdown",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      workspaces = {
        { name = "personal", path = "~/vaults/personal" },
        { name = "work", path = "~/vaults/work" },
      },
      notes_subdir = "notes",
      daily_notes = {
        folder = "daily",
        date_format = "%Y-%m-%d",
      },
      completion = {
        nvim_cmp = true,
        min_chars = 2,
      },
      mappings = {
        ["gf"] = {
          action = function()
            return require("obsidian").util.gf_passthrough()
          end,
          opts = { noremap = false, expr = true, buffer = true },
        },
      },
      ui = {
        enable = true,
        checkboxes = {
          [" "] = { char = "󰄱", hl_group = "ObsidianTodo" },
          ["x"] = { char = "", hl_group = "ObsidianDone" },
        },
      },
    },
    keys = {
      { "<leader>On", "<cmd>ObsidianNew<cr>", desc = "New Obsidian Note" },
      { "<leader>Oo", "<cmd>ObsidianOpen<cr>", desc = "Open in Obsidian" },
      { "<leader>Os", "<cmd>ObsidianSearch<cr>", desc = "Search Obsidian" },
      { "<leader>Oq", "<cmd>ObsidianQuickSwitch<cr>", desc = "Quick Switch" },
      { "<leader>Ob", "<cmd>ObsidianBacklinks<cr>", desc = "Show Backlinks" },
      { "<leader>Od", "<cmd>ObsidianToday<cr>", desc = "Daily Note" },
    },
  },
}
