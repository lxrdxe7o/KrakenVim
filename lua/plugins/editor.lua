return {
  -- Treesitter: Syntax highlighting and code understanding
  -- Using nvim-treesitter 1.0+ with new simplified API
  {
    "nvim-treesitter/nvim-treesitter",
    version = false,
    build = ":TSUpdate",
    event = { "BufReadPre", "BufNewFile" },
    cmd = { "TSInstall", "TSUpdate", "TSUpdateSync" },
    config = function()
      -- In Neovim 0.10+, treesitter highlighting is built-in and enabled by default
      -- We just need to ensure parsers are installed
      
      -- List of parsers to auto-install
      local parsers = {
        "bash", "c", "cpp", "css", "dockerfile", "gitcommit", "gitignore",
        "go", "gomod", "gosum", "html", "java", "javascript", "json",
        "json5", "jsonc", "lua", "luadoc", "markdown", "markdown_inline",
        "python", "query", "regex", "rust", "scss", "sql", "svelte",
        "toml", "tsx", "typescript", "vim", "vimdoc", "vue", "xml", "yaml",
      }

      -- Auto-install parsers on first buffer read
      vim.api.nvim_create_autocmd("FileType", {
        once = false,
        callback = function(args)
          local ft = vim.bo[args.buf].filetype
          local lang = vim.treesitter.language.get_lang(ft)
          
          if lang and vim.tbl_contains(parsers, lang) then
            -- Check if parser is installed
            local has_parser = pcall(vim.treesitter.language.inspect, lang)
            if not has_parser then
              vim.notify("Installing treesitter parser for " .. lang, vim.log.levels.INFO)
              vim.cmd("TSInstall " .. lang)
            end
            
            -- Enable highlighting for this buffer
            pcall(vim.treesitter.start, args.buf, lang)
          end
        end,
      })

      -- Enable treesitter-based folding
      vim.opt.foldmethod = "expr"
      vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
      vim.opt.foldenable = false
    end,
  },

  -- NOTE: nvim-treesitter-textobjects is incompatible with treesitter 1.0
  -- Using mini.ai instead for textobjects (configured below)

  -- Neo-tree: File explorer
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    cmd = "Neotree",
    keys = {
      { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "Toggle Explorer" },
      { 
        "<leader>o", 
        function()
          -- Check if we're in a neo-tree window
          local is_neotree = vim.bo.filetype == "neo-tree"
          
          if is_neotree then
            -- We're in neo-tree, go back to previous window
            vim.cmd("wincmd p")
          else
            -- We're not in neo-tree, focus it (or show it if hidden)
            vim.cmd("Neotree focus")
          end
        end,
        desc = "Toggle Explorer Focus"
      },
    },
    opts = {
      filesystem = {
        follow_current_file = { enabled = true },
        use_libuv_file_watcher = true,
        filtered_items = {
          visible = true,
          hide_dotfiles = false,
          hide_gitignored = false,
        },
      },
      window = {
        width = 30,
        mappings = {
          ["<space>"] = "none",
        },
      },
    },
  },

  -- Indent Blankline with Rainbow
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      local highlight = {
        "RainbowRed",
        "RainbowYellow",
        "RainbowBlue",
        "RainbowOrange",
        "RainbowGreen",
        "RainbowViolet",
        "RainbowCyan",
      }

      local hooks = require("ibl.hooks")
      hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
        vim.api.nvim_set_hl(0, "RainbowRed", { fg = "#E06C75" })
        vim.api.nvim_set_hl(0, "RainbowYellow", { fg = "#E5C07B" })
        vim.api.nvim_set_hl(0, "RainbowBlue", { fg = "#61AFEF" })
        vim.api.nvim_set_hl(0, "RainbowOrange", { fg = "#D19A66" })
        vim.api.nvim_set_hl(0, "RainbowGreen", { fg = "#98C379" })
        vim.api.nvim_set_hl(0, "RainbowViolet", { fg = "#C678DD" })
        vim.api.nvim_set_hl(0, "RainbowCyan", { fg = "#56B6C2" })
      end)

      require("ibl").setup({
        indent = { highlight = highlight },
        scope = { enabled = true },
      })
    end,
  },

  -- Better escape
  {
    "max397574/better-escape.nvim",
    event = "InsertEnter",
    opts = {
      timeout = 300,
      default_mappings = true,
    },
  },

  -- Neoscroll: Smooth scrolling
  {
    "karb94/neoscroll.nvim",
    event = "VeryLazy",
    opts = {
      mappings = { "<C-u>", "<C-d>", "<C-b>", "<C-f>", "zt", "zz", "zb" },
      hide_cursor = true,
      stop_eof = true,
      respect_scrolloff = false,
      cursor_scrolls_alone = true,
    },
  },

  -- Which-key: Keybinding hints
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      plugins = { spelling = true },
      defaults = {},
    },
    config = function(_, opts)
      local wk = require("which-key")
      wk.setup(opts)

      -- Register all AstroNvim-style group labels
      wk.add({
        { "<leader>A", group = "AI/Claude" },
        { "<leader>b", group = "Buffers" },
        { "<leader>c", group = "Code" },
        { "<leader>d", group = "Debug" },
        { "<leader>f", group = "Find" },
        { "<leader>g", group = "Git" },
        { "<leader>gh", group = "Hunks" },
        { "<leader>j", group = "Java" },
        { "<leader>l", group = "LSP" },
        { "<leader>m", group = "Markdown" },
        { "<leader>n", group = "Swap Next" },
        { "<leader>O", group = "Obsidian" },
        { "<leader>p", group = "Packages" },
        { "<leader>s", group = "Search/Session" },
        { "<leader>t", group = "Terminal/Timer" },
        { "<leader>u", group = "UI/Toggle" },
        { "<leader>W", group = "Windows" },
        { "<leader>x", group = "Trouble" },
      })
    end,
  },

  -- Gitsigns: Git integration
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = {
        add = { text = "+" },
        change = { text = "~" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" },
      },
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns
        local map = function(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
        end

        -- Navigation
        map("n", "]h", gs.next_hunk, "Next Hunk")
        map("n", "[h", gs.prev_hunk, "Prev Hunk")

        -- Actions (AstroNvim style: <leader>gh*)
        map("n", "<leader>ghs", gs.stage_hunk, "Stage Hunk")
        map("n", "<leader>ghr", gs.reset_hunk, "Reset Hunk")
        map("v", "<leader>ghs", function() gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Stage Hunk")
        map("v", "<leader>ghr", function() gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Reset Hunk")
        map("n", "<leader>ghS", gs.stage_buffer, "Stage Buffer")
        map("n", "<leader>ghu", gs.undo_stage_hunk, "Undo Stage Hunk")
        map("n", "<leader>ghR", gs.reset_buffer, "Reset Buffer")
        map("n", "<leader>ghp", gs.preview_hunk, "Preview Hunk")
        map("n", "<leader>ghb", function() gs.blame_line({ full = true }) end, "Blame Line")
        map("n", "<leader>ghd", gs.diffthis, "Diff This")
        map("n", "<leader>ghD", function() gs.diffthis("~") end, "Diff This ~")
        map("n", "<leader>gtb", gs.toggle_current_line_blame, "Toggle Line Blame")
        map("n", "<leader>gtd", gs.toggle_deleted, "Toggle Deleted")

        -- Text object
        map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "Select Hunk")
      end,
    },
  },

  -- Comment.nvim
  {
    "numToStr/Comment.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = {},
  },

  -- Todo Comments
  {
    "folke/todo-comments.nvim",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
    keys = {
      { "]t", function() require("todo-comments").jump_next() end, desc = "Next Todo" },
      { "[t", function() require("todo-comments").jump_prev() end, desc = "Prev Todo" },
      { "<leader>fT", "<cmd>Trouble todo toggle<cr>", desc = "Find Todos" },
      { "<leader>xt", "<cmd>Trouble todo toggle<cr>", desc = "Todo (Trouble)" },
      { "<leader>xT", "<cmd>Trouble todo toggle filter = {tag = {TODO,FIX,FIXME}}<cr>", desc = "Todo/Fix/Fixme (Trouble)" },
    },
  },

  -- Mini.surround for surround operations (like vim-surround)
  {
    "echasnovski/mini.surround",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      mappings = {
        add = "gsa",            -- Add surrounding in Normal and Visual modes
        delete = "gsd",         -- Delete surrounding
        find = "gsf",           -- Find surrounding (to the right)
        find_left = "gsF",      -- Find surrounding (to the left)
        highlight = "gsh",      -- Highlight surrounding
        replace = "gsr",        -- Replace surrounding
        update_n_lines = "gsn", -- Update `n_lines`
      },
    },
  },

  -- Mini.ai for extended text objects (replacement for treesitter-textobjects)
  {
    "echasnovski/mini.ai",
    event = { "BufReadPost", "BufNewFile" },
    opts = function()
      local ai = require("mini.ai")
      return {
        n_lines = 500,
        custom_textobjects = {
          o = ai.gen_spec.treesitter({
            a = { "@block.outer", "@conditional.outer", "@loop.outer" },
            i = { "@block.inner", "@conditional.inner", "@loop.inner" },
          }, {}),
          f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }, {}),
          c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }, {}),
          a = ai.gen_spec.treesitter({ a = "@parameter.outer", i = "@parameter.inner" }, {}),
          t = { "<([%p%w]-)%f[^<%w][^<>]->.-</%1>", "^<.->().-(googletag)googletag.-%1>$" },
          d = { "%f[%d]%d+" }, -- digits
          e = { -- Word with case
            {
              "%u[%l%d]+%f[^%l%d]",
              "%f[%S][%l%d]+%f[^%l%d]",
              "%f[%P][%l%d]+%f[^%l%d]",
              "^[%l%d]+%f[^%l%d]",
            },
            "^().*()$",
          },
          u = ai.gen_spec.function_call(), -- u for "Usage"
          U = ai.gen_spec.function_call({ name_pattern = "[%w_]" }), -- without dot in function name
        },
      }
    end,
  },

  -- Mini.bracketed for bracket navigation (]m, [m, ]f, [f, etc.)
  {
    "echasnovski/mini.bracketed",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      -- Disable some that conflict with other mappings
      buffer     = { suffix = "b", options = {} },
      comment    = { suffix = "c", options = {} },
      conflict   = { suffix = "x", options = {} },
      diagnostic = { suffix = "d", options = {} },
      file       = { suffix = "f", options = {} },
      indent     = { suffix = "i", options = {} },
      jump       = { suffix = "j", options = {} },
      location   = { suffix = "l", options = {} },
      oldfile    = { suffix = "o", options = {} },
      quickfix   = { suffix = "q", options = {} },
      treesitter = { suffix = "t", options = {} },
      undo       = { suffix = "u", options = {} },
      window     = { suffix = "w", options = {} },
      yank       = { suffix = "y", options = {} },
    },
  },

  -- Mini.move for moving lines/selections
  {
    "echasnovski/mini.move",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      mappings = {
        -- Move visual selection
        left = "<M-h>",
        right = "<M-l>",
        down = "<M-j>",
        up = "<M-k>",
        -- Move current line
        line_left = "<M-h>",
        line_right = "<M-l>",
        line_down = "<M-j>",
        line_up = "<M-k>",
      },
    },
  },
}
