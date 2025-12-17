return {
  -- Core DAP client
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      -- DAP UI for a better debugging experience
      {
        "rcarriga/nvim-dap-ui",
        dependencies = { "nvim-neotest/nvim-nio" },
        keys = {
          { "<leader>du", function() require("dapui").toggle({}) end, desc = "Toggle DAP UI" },
          { "<leader>de", function() require("dapui").eval() end, desc = "Eval Expression", mode = { "n", "v" } },
        },
        opts = {
          layouts = {
            {
              elements = {
                { id = "scopes", size = 0.25 },
                { id = "breakpoints", size = 0.25 },
                { id = "stacks", size = 0.25 },
                { id = "watches", size = 0.25 },
              },
              size = 40,
              position = "left",
            },
            {
              elements = {
                { id = "repl", size = 0.5 },
                { id = "console", size = 0.5 },
              },
              size = 10,
              position = "bottom",
            },
          },
        },
        config = function(_, opts)
          local dap = require("dap")
          local dapui = require("dapui")
          dapui.setup(opts)

          -- Auto open/close DAP UI
          dap.listeners.after.event_initialized["dapui_config"] = function()
            dapui.open({})
          end
          dap.listeners.before.event_terminated["dapui_config"] = function()
            dapui.close({})
          end
          dap.listeners.before.event_exited["dapui_config"] = function()
            dapui.close({})
          end
        end,
      },

      -- Virtual text for variable values
      {
        "theHamsta/nvim-dap-virtual-text",
        opts = {
          enabled = true,
          enabled_commands = true,
          highlight_changed_variables = true,
          highlight_new_as_changed = false,
          show_stop_reason = true,
          commented = false,
          virt_text_pos = "eol",
        },
      },

      -- Mason integration for auto-installing debug adapters
      {
        "jay-babu/mason-nvim-dap.nvim",
        dependencies = { "mason.nvim" },
        cmd = { "DapInstall", "DapUninstall" },
        opts = {
          automatic_installation = true,
          ensure_installed = {
            "python",    -- debugpy
            "delve",     -- Go
            "codelldb",  -- C/C++/Rust
            "js",        -- vscode-js-debug
          },
          handlers = {},
        },
      },
    },

    keys = {
      -- Breakpoints
      { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle Breakpoint" },
      { "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: ")) end, desc = "Conditional Breakpoint" },
      { "<leader>dL", function() require("dap").set_breakpoint(nil, nil, vim.fn.input("Log point message: ")) end, desc = "Log Point" },

      -- Execution control
      { "<leader>dc", function() require("dap").continue() end, desc = "Continue" },
      { "<leader>dC", function() require("dap").run_to_cursor() end, desc = "Run to Cursor" },
      { "<leader>di", function() require("dap").step_into() end, desc = "Step Into" },
      { "<leader>do", function() require("dap").step_over() end, desc = "Step Over" },
      { "<leader>dO", function() require("dap").step_out() end, desc = "Step Out" },
      { "<leader>dp", function() require("dap").pause() end, desc = "Pause" },
      { "<leader>dt", function() require("dap").terminate() end, desc = "Terminate" },
      { "<leader>dr", function() require("dap").repl.toggle() end, desc = "Toggle REPL" },
      { "<leader>dl", function() require("dap").run_last() end, desc = "Run Last" },
      { "<leader>ds", function() require("dap").session() end, desc = "Session Info" },
      { "<leader>dw", function() require("dap.ui.widgets").hover() end, desc = "Widgets" },

      -- Function keys (standard debugging shortcuts)
      { "<F5>", function() require("dap").continue() end, desc = "Debug: Continue" },
      { "<F9>", function() require("dap").toggle_breakpoint() end, desc = "Debug: Toggle Breakpoint" },
      { "<F10>", function() require("dap").step_over() end, desc = "Debug: Step Over" },
      { "<F11>", function() require("dap").step_into() end, desc = "Debug: Step Into" },
      { "<S-F11>", function() require("dap").step_out() end, desc = "Debug: Step Out" },
    },

    config = function()
      local dap = require("dap")

      -- Set up nice icons
      vim.fn.sign_define("DapBreakpoint", { text = "", texthl = "DiagnosticError", linehl = "", numhl = "" })
      vim.fn.sign_define("DapBreakpointCondition", { text = "", texthl = "DiagnosticWarn", linehl = "", numhl = "" })
      vim.fn.sign_define("DapLogPoint", { text = "", texthl = "DiagnosticInfo", linehl = "", numhl = "" })
      vim.fn.sign_define("DapStopped", { text = "", texthl = "DiagnosticOk", linehl = "DapStoppedLine", numhl = "" })
      vim.fn.sign_define("DapBreakpointRejected", { text = "", texthl = "DiagnosticError", linehl = "", numhl = "" })

      -- Highlight for stopped line
      vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "Visual" })

      -- ╔══════════════════════════════════════════════════════════════════════╗
      -- ║                         PYTHON CONFIGURATION                          ║
      -- ╚══════════════════════════════════════════════════════════════════════╝
      dap.adapters.python = function(cb, config)
        if config.request == "attach" then
          local port = (config.connect or config).port
          local host = (config.connect or config).host or "127.0.0.1"
          cb({
            type = "server",
            port = assert(port, "`connect.port` is required for attach"),
            host = host,
            options = { source_filetype = "python" },
          })
        else
          cb({
            type = "executable",
            command = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python",
            args = { "-m", "debugpy.adapter" },
            options = { source_filetype = "python" },
          })
        end
      end

      dap.configurations.python = {
        {
          type = "python",
          request = "launch",
          name = "Launch file",
          program = "${file}",
          pythonPath = function()
            -- Check for virtual environment
            local venv = os.getenv("VIRTUAL_ENV")
            if venv then
              return venv .. "/bin/python"
            end
            -- Check for conda
            local conda = os.getenv("CONDA_PREFIX")
            if conda then
              return conda .. "/bin/python"
            end
            -- Fallback to system python
            return "/usr/bin/python3"
          end,
        },
        {
          type = "python",
          request = "launch",
          name = "Launch file with arguments",
          program = "${file}",
          args = function()
            local args_string = vim.fn.input("Arguments: ")
            return vim.split(args_string, " +")
          end,
          pythonPath = function()
            local venv = os.getenv("VIRTUAL_ENV")
            if venv then return venv .. "/bin/python" end
            return "/usr/bin/python3"
          end,
        },
        {
          type = "python",
          request = "launch",
          name = "Launch Django",
          program = "${workspaceFolder}/manage.py",
          args = { "runserver", "--noreload" },
          pythonPath = function()
            local venv = os.getenv("VIRTUAL_ENV")
            if venv then return venv .. "/bin/python" end
            return "/usr/bin/python3"
          end,
        },
        {
          type = "python",
          request = "launch",
          name = "Launch Flask",
          module = "flask",
          args = { "run", "--no-debugger", "--no-reload" },
          env = { FLASK_APP = "${file}", FLASK_ENV = "development" },
          pythonPath = function()
            local venv = os.getenv("VIRTUAL_ENV")
            if venv then return venv .. "/bin/python" end
            return "/usr/bin/python3"
          end,
        },
        {
          type = "python",
          request = "attach",
          name = "Attach to process",
          connect = function()
            local host = vim.fn.input("Host [127.0.0.1]: ")
            host = host ~= "" and host or "127.0.0.1"
            local port = tonumber(vim.fn.input("Port [5678]: ")) or 5678
            return { host = host, port = port }
          end,
        },
      }

      -- ╔══════════════════════════════════════════════════════════════════════╗
      -- ║                           GO CONFIGURATION                            ║
      -- ╚══════════════════════════════════════════════════════════════════════╝
      dap.adapters.delve = {
        type = "server",
        port = "${port}",
        executable = {
          command = vim.fn.stdpath("data") .. "/mason/packages/delve/dlv",
          args = { "dap", "-l", "127.0.0.1:${port}" },
        },
      }

      dap.configurations.go = {
        {
          type = "delve",
          name = "Launch file",
          request = "launch",
          program = "${file}",
        },
        {
          type = "delve",
          name = "Launch package",
          request = "launch",
          program = "${fileDirname}",
        },
        {
          type = "delve",
          name = "Launch workspace",
          request = "launch",
          program = "${workspaceFolder}",
        },
        {
          type = "delve",
          name = "Debug test",
          request = "launch",
          mode = "test",
          program = "${file}",
        },
        {
          type = "delve",
          name = "Debug test (go.mod)",
          request = "launch",
          mode = "test",
          program = "./${relativeFileDirname}",
        },
        {
          type = "delve",
          name = "Attach to process",
          request = "attach",
          mode = "local",
          processId = require("dap.utils").pick_process,
        },
      }

      -- ╔══════════════════════════════════════════════════════════════════════╗
      -- ║                     C/C++/RUST CONFIGURATION (LLDB)                   ║
      -- ╚══════════════════════════════════════════════════════════════════════╝
      dap.adapters.codelldb = {
        type = "server",
        port = "${port}",
        executable = {
          command = vim.fn.stdpath("data") .. "/mason/packages/codelldb/extension/adapter/codelldb",
          args = { "--port", "${port}" },
        },
      }

      -- C configurations
      dap.configurations.c = {
        {
          type = "codelldb",
          name = "Launch file",
          request = "launch",
          program = function()
            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
          end,
          cwd = "${workspaceFolder}",
          stopOnEntry = false,
        },
        {
          type = "codelldb",
          name = "Launch file with arguments",
          request = "launch",
          program = function()
            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
          end,
          args = function()
            local args_string = vim.fn.input("Arguments: ")
            return vim.split(args_string, " +")
          end,
          cwd = "${workspaceFolder}",
          stopOnEntry = false,
        },
        {
          type = "codelldb",
          name = "Attach to process",
          request = "attach",
          pid = require("dap.utils").pick_process,
          cwd = "${workspaceFolder}",
        },
      }

      -- C++ uses the same configurations as C
      dap.configurations.cpp = dap.configurations.c

      -- Rust configurations
      dap.configurations.rust = {
        {
          type = "codelldb",
          name = "Launch (Cargo debug)",
          request = "launch",
          program = function()
            -- Try to find the binary in target/debug
            local cwd = vim.fn.getcwd()
            local cargo_toml = cwd .. "/Cargo.toml"
            if vim.fn.filereadable(cargo_toml) == 1 then
              -- Parse Cargo.toml to get package name
              for line in io.lines(cargo_toml) do
                local name = line:match('^name%s*=%s*"([^"]+)"')
                if name then
                  local debug_path = cwd .. "/target/debug/" .. name
                  if vim.fn.filereadable(debug_path) == 1 then
                    return debug_path
                  end
                end
              end
            end
            return vim.fn.input("Path to executable: ", cwd .. "/target/debug/", "file")
          end,
          cwd = "${workspaceFolder}",
          stopOnEntry = false,
        },
        {
          type = "codelldb",
          name = "Launch file",
          request = "launch",
          program = function()
            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/target/debug/", "file")
          end,
          cwd = "${workspaceFolder}",
          stopOnEntry = false,
        },
        {
          type = "codelldb",
          name = "Attach to process",
          request = "attach",
          pid = require("dap.utils").pick_process,
          cwd = "${workspaceFolder}",
        },
      }

      -- ╔══════════════════════════════════════════════════════════════════════╗
      -- ║                    JAVASCRIPT/TYPESCRIPT CONFIGURATION                ║
      -- ╚══════════════════════════════════════════════════════════════════════╝
      -- Using vscode-js-debug
      local js_debug_path = vim.fn.stdpath("data") .. "/mason/packages/js-debug-adapter"

      dap.adapters["pwa-node"] = {
        type = "server",
        host = "localhost",
        port = "${port}",
        executable = {
          command = "node",
          args = { js_debug_path .. "/js-debug/src/dapDebugServer.js", "${port}" },
        },
      }

      dap.adapters["pwa-chrome"] = {
        type = "server",
        host = "localhost",
        port = "${port}",
        executable = {
          command = "node",
          args = { js_debug_path .. "/js-debug/src/dapDebugServer.js", "${port}" },
        },
      }

      -- Shared JS/TS configurations
      local js_configs = {
        {
          type = "pwa-node",
          request = "launch",
          name = "Launch file",
          program = "${file}",
          cwd = "${workspaceFolder}",
        },
        {
          type = "pwa-node",
          request = "launch",
          name = "Launch file (with args)",
          program = "${file}",
          args = function()
            local args_string = vim.fn.input("Arguments: ")
            return vim.split(args_string, " +")
          end,
          cwd = "${workspaceFolder}",
        },
        {
          type = "pwa-node",
          request = "attach",
          name = "Attach to Node process",
          processId = require("dap.utils").pick_process,
          cwd = "${workspaceFolder}",
        },
        {
          type = "pwa-node",
          request = "launch",
          name = "Debug Jest tests",
          runtimeExecutable = "node",
          runtimeArgs = {
            "./node_modules/jest/bin/jest.js",
            "--runInBand",
          },
          rootPath = "${workspaceFolder}",
          cwd = "${workspaceFolder}",
          console = "integratedTerminal",
          internalConsoleOptions = "neverOpen",
        },
        {
          type = "pwa-node",
          request = "launch",
          name = "Debug Mocha tests",
          runtimeExecutable = "node",
          runtimeArgs = { "./node_modules/mocha/bin/mocha.js" },
          rootPath = "${workspaceFolder}",
          cwd = "${workspaceFolder}",
          console = "integratedTerminal",
          internalConsoleOptions = "neverOpen",
        },
        {
          type = "pwa-chrome",
          request = "launch",
          name = "Launch Chrome (localhost:3000)",
          url = "http://localhost:3000",
          webRoot = "${workspaceFolder}",
        },
        {
          type = "pwa-chrome",
          request = "launch",
          name = "Launch Chrome (custom URL)",
          url = function()
            return vim.fn.input("URL: ", "http://localhost:")
          end,
          webRoot = "${workspaceFolder}",
        },
      }

      dap.configurations.javascript = js_configs
      dap.configurations.typescript = js_configs
      dap.configurations.javascriptreact = js_configs
      dap.configurations.typescriptreact = js_configs

      -- ╔══════════════════════════════════════════════════════════════════════╗
      -- ║                              JAVA NOTE                                ║
      -- ╚══════════════════════════════════════════════════════════════════════╝
      -- Java debugging is handled by nvim-jdtls in ftplugin/java.lua
      -- The jdtls plugin provides built-in DAP support via java-debug-adapter
      -- Use <leader>jt to test class, <leader>jn to test nearest method
    end,
  },
}
