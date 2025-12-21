return {
  -- Mason: Package manager for LSP servers, formatters, linters
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    build = ":MasonUpdate",
    opts = {
      ui = {
        border = "rounded",
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    },
    config = function(_, opts)
      require("mason").setup(opts)

      -- Auto-install formatters and linters (deferred to avoid conflicts)
      vim.defer_fn(function()
        local ensure_installed = {
          -- Formatters
          "stylua",
          "black",
          "isort",
          "prettierd",
          "shfmt",
          "gofumpt",
          "goimports",
          "clang-format",
          "google-java-format",
          "taplo",
          "sql-formatter",
          -- Linters
          "eslint_d",
          "ruff",
          "golangci-lint",
          "shellcheck",
        }

        local registry = require("mason-registry")
        registry.refresh(function()
          for _, tool in ipairs(ensure_installed) do
            local ok, pkg = pcall(registry.get_package, tool)
            if ok and not pkg:is_installed() then
              pkg:install()
            end
          end
        end)
      end, 100)
    end,
  },



  -- Mason-lspconfig bridge with handlers
  {
    "williamboman/mason-lspconfig.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "mason.nvim",
      "neovim/nvim-lspconfig",
      "hrsh7th/cmp-nvim-lsp",
      { "j-hui/fidget.nvim", opts = {} },
    },
    config = function()
      -- Get capabilities from cmp
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      local ok_cmp, cmp_lsp = pcall(require, "cmp_nvim_lsp")
      if ok_cmp then
        capabilities = cmp_lsp.default_capabilities(capabilities)
      end

      -- Common on_attach function
      local on_attach = function(client, bufnr)
        -- Enable inlay hints for Neovim 0.10+
        if client.supports_method("textDocument/inlayHint") then
          vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
        end

        -- Buffer-local keymaps
        local map = function(keys, func, desc)
          vim.keymap.set("n", keys, func, { buffer = bufnr, desc = "LSP: " .. desc })
        end

        -- Navigation
        map("gd", vim.lsp.buf.definition, "Go to Definition")
        map("gD", vim.lsp.buf.declaration, "Go to Declaration")
        map("gr", "<cmd>Telescope lsp_references<cr>", "Go to References")
        map("gi", vim.lsp.buf.implementation, "Go to Implementation")
        map("gy", vim.lsp.buf.type_definition, "Go to Type Definition")
        map("K", vim.lsp.buf.hover, "Hover Documentation")
        map("<C-k>", vim.lsp.buf.signature_help, "Signature Help")

        -- Leader keymaps (AstroNvim style)
        map("<leader>la", vim.lsp.buf.code_action, "Code Action")
        map("<leader>ld", vim.diagnostic.open_float, "Line Diagnostics")
        map("<leader>lf", function() vim.lsp.buf.format({ async = true }) end, "Format")
        map("<leader>lh", vim.lsp.buf.signature_help, "Signature Help")
        map("<leader>li", "<cmd>LspInfo<cr>", "LSP Info")
        map("<leader>lI", "<cmd>Mason<cr>", "Mason Info")
        map("<leader>lr", vim.lsp.buf.rename, "Rename")
        map("<leader>lR", "<cmd>Telescope lsp_references<cr>", "References")
        map("<leader>ls", "<cmd>Telescope lsp_document_symbols<cr>", "Document Symbols")
        map("<leader>lS", "<cmd>Telescope lsp_workspace_symbols<cr>", "Workspace Symbols")

        -- Toggle inlay hints
        map("<leader>uh", function()
          vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }), { bufnr = bufnr })
        end, "Toggle Inlay Hints")

        -- Diagnostics
        map("[d", vim.diagnostic.goto_prev, "Previous Diagnostic")
        map("]d", vim.diagnostic.goto_next, "Next Diagnostic")
      end

      local lspconfig = require("lspconfig")

      -- Setup mason-lspconfig with handlers
      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls",
          "html",
          "cssls",
          "tailwindcss",
          "ts_ls",
          "svelte",
          "emmet_ls",
          "pyright",
          "gopls",
          "clangd",
          "jsonls",
          "yamlls",
          "taplo",
          "bashls",
        },
        automatic_installation = true,
        handlers = {
          -- Default handler for all servers
          function(server_name)
            lspconfig[server_name].setup({
              capabilities = capabilities,
              on_attach = on_attach,
            })
          end,

          -- Lua
          ["lua_ls"] = function()
            lspconfig.lua_ls.setup({
              capabilities = capabilities,
              on_attach = on_attach,
              settings = {
                Lua = {
                  runtime = { version = "LuaJIT" },
                  workspace = {
                    checkThirdParty = false,
                    library = vim.api.nvim_get_runtime_file("", true),
                  },
                  diagnostics = { globals = { "vim" } },
                  telemetry = { enable = false },
                  hint = { enable = true },
                  completion = { callSnippet = "Replace" },
                },
              },
            })
          end,

          -- TypeScript/JavaScript
          ["ts_ls"] = function()
            lspconfig.ts_ls.setup({
              capabilities = capabilities,
              on_attach = on_attach,
              settings = {
                typescript = {
                  inlayHints = {
                    includeInlayParameterNameHints = "all",
                    includeInlayFunctionParameterTypeHints = true,
                    includeInlayVariableTypeHints = true,
                    includeInlayPropertyDeclarationTypeHints = true,
                    includeInlayFunctionLikeReturnTypeHints = true,
                  },
                },
                javascript = {
                  inlayHints = {
                    includeInlayParameterNameHints = "all",
                    includeInlayFunctionParameterTypeHints = true,
                    includeInlayVariableTypeHints = true,
                    includeInlayPropertyDeclarationTypeHints = true,
                    includeInlayFunctionLikeReturnTypeHints = true,
                  },
                },
              },
            })
          end,

          -- Python
          ["pyright"] = function()
            lspconfig.pyright.setup({
              capabilities = capabilities,
              on_attach = on_attach,
              settings = {
                python = {
                  analysis = {
                    typeCheckingMode = "basic",
                    autoSearchPaths = true,
                    useLibraryCodeForTypes = true,
                  },
                },
              },
            })
          end,

          -- Go
          ["gopls"] = function()
            lspconfig.gopls.setup({
              capabilities = capabilities,
              on_attach = on_attach,
              settings = {
                gopls = {
                  gofumpt = true,
                  hints = {
                    assignVariableTypes = true,
                    compositeLiteralFields = true,
                    constantValues = true,
                    functionTypeParameters = true,
                    parameterNames = true,
                    rangeVariableTypes = true,
                  },
                  analyses = {
                    unusedparams = true,
                    unusedwrite = true,
                  },
                  usePlaceholders = true,
                  completeUnimported = true,
                  staticcheck = true,
                },
              },
            })
          end,

          -- C/C++
          ["clangd"] = function()
            lspconfig.clangd.setup({
              capabilities = capabilities,
              on_attach = on_attach,
              cmd = {
                "clangd",
                "--background-index",
                "--clang-tidy",
                "--header-insertion=iwyu",
                "--completion-style=detailed",
              },
            })
          end,

          -- JSON
          ["jsonls"] = function()
            local settings = { json = { validate = { enable = true } } }
            local ok, schemastore = pcall(require, "schemastore")
            if ok then
              settings.json.schemas = schemastore.json.schemas()
            end
            lspconfig.jsonls.setup({
              capabilities = capabilities,
              on_attach = on_attach,
              settings = settings,
            })
          end,

          -- YAML
          ["yamlls"] = function()
            local settings = { yaml = { schemaStore = { enable = true } } }
            local ok, schemastore = pcall(require, "schemastore")
            if ok then
              settings.yaml.schemaStore = { enable = false, url = "" }
              settings.yaml.schemas = schemastore.yaml.schemas()
            end
            lspconfig.yamlls.setup({
              capabilities = capabilities,
              on_attach = on_attach,
              settings = settings,
            })
          end,

          -- Emmet
          ["emmet_ls"] = function()
            lspconfig.emmet_ls.setup({
              capabilities = capabilities,
              on_attach = on_attach,
              filetypes = { "html", "css", "scss", "javascript", "javascriptreact", "typescript", "typescriptreact", "vue", "svelte" },
            })
          end,

          -- Skip jdtls (handled by nvim-jdtls in ftplugin)
          ["jdtls"] = function() end,

          -- Skip rust_analyzer (handled by rustaceanvim)
          ["rust_analyzer"] = function() end,
        },
      })
    end,
  },

  -- nvim-lspconfig (loaded as dependency)
  {
    "neovim/nvim-lspconfig",
    lazy = true,
  },

  -- SchemaStore for JSON/YAML schemas
  {
    "b0o/schemastore.nvim",
    lazy = true,
  },

  -- Rustaceanvim: Enhanced Rust support
  {
    "mrcjkb/rustaceanvim",
    version = "^5",
    lazy = false,
    ft = { "rust" },
    opts = {
      server = {
        on_attach = function(_, bufnr)
          if vim.lsp.inlay_hint then
            vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
          end

          local map = function(keys, func, desc)
            vim.keymap.set("n", keys, func, { buffer = bufnr, desc = "Rust: " .. desc })
          end

          map("<leader>ca", function() vim.cmd.RustLsp("codeAction") end, "Code Action")
          map("<leader>dr", function() vim.cmd.RustLsp("debuggables") end, "Debuggables")
          map("<leader>rr", function() vim.cmd.RustLsp("runnables") end, "Runnables")
          map("<leader>rt", function() vim.cmd.RustLsp("testables") end, "Testables")
          map("<leader>rm", function() vim.cmd.RustLsp("expandMacro") end, "Expand Macro")
          map("K", function() vim.cmd.RustLsp({ "hover", "actions" }) end, "Hover Actions")
        end,
        default_settings = {
          ["rust-analyzer"] = {
            cargo = { allFeatures = true, buildScripts = { enable = true } },
            checkOnSave = true,
            procMacro = { enable = true },
            inlayHints = {
              chainingHints = { enable = true },
              parameterHints = { enable = true },
              typeHints = { enable = true },
            },
          },
        },
      },
    },
    config = function(_, opts)
      vim.g.rustaceanvim = vim.tbl_deep_extend("force", {}, opts or {})
    end,
  },

  -- nvim-jdtls: Java LSP (config in ftplugin/java.lua)
  {
    "mfussenegger/nvim-jdtls",
    ft = "java",
    dependencies = { "mason.nvim" },
  },

  -- Conform.nvim: Formatting
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      {
        "<leader>lf",
        function()
          require("conform").format({ async = true, lsp_fallback = true })
        end,
        mode = "",
        desc = "Format buffer",
      },
    },
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        python = { "black", "isort" },
        javascript = { "prettierd", "prettier", stop_after_first = true },
        typescript = { "prettierd", "prettier", stop_after_first = true },
        javascriptreact = { "prettierd", "prettier", stop_after_first = true },
        typescriptreact = { "prettierd", "prettier", stop_after_first = true },
        vue = { "prettierd", "prettier", stop_after_first = true },
        svelte = { "prettierd", "prettier", stop_after_first = true },
        json = { "prettierd", "prettier", stop_after_first = true },
        html = { "prettierd", "prettier", stop_after_first = true },
        css = { "prettierd", "prettier", stop_after_first = true },
        scss = { "prettierd", "prettier", stop_after_first = true },
        markdown = { "prettierd", "prettier", stop_after_first = true },
        yaml = { "prettierd", "prettier", stop_after_first = true },
        java = { "google-java-format" },
        go = { "gofumpt", "goimports" },
        rust = { "rustfmt" },
        c = { "clang-format" },
        cpp = { "clang-format" },
        sh = { "shfmt" },
        bash = { "shfmt" },
        sql = { "sql_formatter" },
        toml = { "taplo" },
      },
      format_on_save = {
        timeout_ms = 1000,
        lsp_fallback = true,
      },
    },
  },

  -- nvim-lint: Linting
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local lint = require("lint")
      lint.linters_by_ft = {
        javascript = { "eslint_d" },
        typescript = { "eslint_d" },
        javascriptreact = { "eslint_d" },
        typescriptreact = { "eslint_d" },
        vue = { "eslint_d" },
        svelte = { "eslint_d" },
        python = { "ruff" },
        go = { "golangcilint" },
        sh = { "shellcheck" },
        bash = { "shellcheck" },
      }

      vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
        callback = function()
          -- Wrap in pcall to gracefully handle missing linters
          pcall(lint.try_lint)
        end,
      })
    end,
  },

  -- LSP Signature
  {
    "ray-x/lsp_signature.nvim",
    event = "LspAttach",
    opts = {
      bind = true,
      handler_opts = { border = "rounded" },
      hint_enable = true,
      hint_prefix = " ",
      floating_window = true,
    },
  },
}
