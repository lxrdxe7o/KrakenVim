-- Java specific configuration using nvim-jdtls
-- This file is automatically loaded for Java files

local jdtls_ok, jdtls = pcall(require, "jdtls")
if not jdtls_ok then
  vim.notify("nvim-jdtls not found, install it with Mason", vim.log.levels.WARN)
  return
end

-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║                      DYNAMIC JAVA RUNTIME DETECTION                       ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

--- Find all available Java runtimes on the system
---@return table[] List of runtime configurations for jdtls
local function find_java_runtimes()
  local runtimes = {}
  local seen_paths = {}

  -- Helper to add a runtime if it exists and is unique
  local function add_runtime(path, name)
    -- Normalize path (remove trailing slash)
    path = path:gsub("/$", "")

    -- Skip if already seen
    if seen_paths[path] then
      return
    end

    -- Verify the path exists and contains a Java installation
    local java_bin = path .. "/bin/java"
    if vim.fn.executable(java_bin) == 1 then
      seen_paths[path] = true
      table.insert(runtimes, {
        name = name,
        path = path .. "/",
      })
    end
  end

  -- Check JAVA_HOME first (user's preferred JDK)
  local java_home = os.getenv("JAVA_HOME")
  if java_home then
    local version = java_home:match("java%-?(%d+)") or "default"
    add_runtime(java_home, "JavaSE-" .. version)
  end

  -- Common JVM base directories
  local jvm_bases = {
    "/usr/lib/jvm",           -- Arch, Debian, Ubuntu
    "/usr/lib64/jvm",         -- Some RPM-based distros
    "/usr/java",              -- Oracle RPM installs
    "/opt/java",              -- Manual installs
    "/Library/Java/JavaVirtualMachines", -- macOS
  }

  for _, jvm_base in ipairs(jvm_bases) do
    if vim.fn.isdirectory(jvm_base) == 1 then
      -- Use vim.fn.glob to find Java directories
      local patterns = {
        jvm_base .. "/java-*",
        jvm_base .. "/jdk-*",
        jvm_base .. "/openjdk-*",
        jvm_base .. "/*/Contents/Home", -- macOS structure
      }

      for _, pattern in ipairs(patterns) do
        local dirs = vim.fn.glob(pattern, false, true)
        for _, dir in ipairs(dirs) do
          -- Extract version number from directory name
          local version = dir:match("java%-(%d+)")
            or dir:match("jdk%-(%d+)")
            or dir:match("openjdk%-(%d+)")
            or dir:match("/(%d+)/")

          if version then
            add_runtime(dir, "JavaSE-" .. version)
          end
        end
      end
    end
  end

  -- Check for SDKMAN installations
  local sdkman_dir = os.getenv("SDKMAN_DIR") or (os.getenv("HOME") .. "/.sdkman")
  local sdkman_java = sdkman_dir .. "/candidates/java"
  if vim.fn.isdirectory(sdkman_java) == 1 then
    local dirs = vim.fn.glob(sdkman_java .. "/*", false, true)
    for _, dir in ipairs(dirs) do
      if vim.fn.isdirectory(dir) == 1 and not dir:match("current$") then
        local version = dir:match("(%d+)%.") or dir:match("%-(%d+)")
        if version then
          add_runtime(dir, "JavaSE-" .. version)
        end
      end
    end
  end

  -- Check for asdf installations
  local asdf_java = os.getenv("HOME") .. "/.asdf/installs/java"
  if vim.fn.isdirectory(asdf_java) == 1 then
    local dirs = vim.fn.glob(asdf_java .. "/*", false, true)
    for _, dir in ipairs(dirs) do
      if vim.fn.isdirectory(dir) == 1 then
        local version = dir:match("openjdk%-(%d+)") or dir:match("(%d+)%.")
        if version then
          add_runtime(dir, "JavaSE-" .. version)
        end
      end
    end
  end

  -- Sort by version (newest first)
  table.sort(runtimes, function(a, b)
    local va = tonumber(a.name:match("%d+")) or 0
    local vb = tonumber(b.name:match("%d+")) or 0
    return va > vb
  end)

  return runtimes
end

-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║                           PROJECT CONFIGURATION                           ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

-- Find root of project
local root_markers = { "gradlew", "mvnw", ".git", "pom.xml", "build.gradle", "settings.gradle" }
local root_dir = vim.fs.dirname(vim.fs.find(root_markers, { upward = true })[1])

-- If no project root found, use current working directory
if not root_dir then
  root_dir = vim.fn.getcwd()
end

-- Eclipse workspace directory (unique per project)
local project_name = vim.fn.fnamemodify(root_dir, ":p:h:t")
local workspace_dir = vim.fn.stdpath("data") .. "/jdtls-workspace/" .. project_name

-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║                             MASON PATHS                                   ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

local mason_path = vim.fn.stdpath("data") .. "/mason"
local jdtls_path = mason_path .. "/packages/jdtls"

-- Find the launcher jar
local launcher_jar = vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar")
if launcher_jar == "" then
  vim.notify("JDTLS launcher not found. Run :MasonInstall jdtls", vim.log.levels.ERROR)
  return
end

-- Determine OS-specific config path
local os_config = "config_linux"
if vim.fn.has("mac") == 1 then
  os_config = "config_mac"
elseif vim.fn.has("win32") == 1 then
  os_config = "config_win"
end
local config_path = jdtls_path .. "/" .. os_config

-- Lombok support (if installed via Mason)
local lombok_path = mason_path .. "/packages/lombok-nightly/lombok.jar"
local lombok_args = {}
if vim.fn.filereadable(lombok_path) == 1 then
  lombok_args = { "-javaagent:" .. lombok_path }
end

-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║                          DEBUG ADAPTER BUNDLES                            ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

local bundles = {}

-- java-debug-adapter
local java_debug_path = mason_path .. "/packages/java-debug-adapter/extension/server"
if vim.fn.isdirectory(java_debug_path) == 1 then
  local debug_jars = vim.fn.glob(java_debug_path .. "/com.microsoft.java.debug.plugin-*.jar", false, true)
  for _, jar in ipairs(debug_jars) do
    table.insert(bundles, jar)
  end
end

-- java-test
local java_test_path = mason_path .. "/packages/java-test/extension/server"
if vim.fn.isdirectory(java_test_path) == 1 then
  local test_jars = vim.fn.glob(java_test_path .. "/*.jar", false, true)
  for _, jar in ipairs(test_jars) do
    table.insert(bundles, jar)
  end
end

-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║                           JDTLS CONFIGURATION                             ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

local config = {
  cmd = {
    "java",
    "-Declipse.application=org.eclipse.jdt.ls.core.id1",
    "-Dosgi.bundles.defaultStartLevel=4",
    "-Declipse.product=org.eclipse.jdt.ls.core.product",
    "-Dlog.protocol=true",
    "-Dlog.level=ALL",
    "-Xmx2g",
    "-XX:+UseG1GC",
    "-XX:+UseStringDeduplication",
    "--add-modules=ALL-SYSTEM",
    "--add-opens", "java.base/java.util=ALL-UNNAMED",
    "--add-opens", "java.base/java.lang=ALL-UNNAMED",
    table.unpack(lombok_args),
    "-jar", launcher_jar,
    "-configuration", config_path,
    "-data", workspace_dir,
  },

  root_dir = root_dir,

  settings = {
    java = {
      -- Use dynamically detected runtimes
      configuration = {
        runtimes = find_java_runtimes(),
      },
      format = {
        enabled = true,
        settings = {
          url = "https://raw.githubusercontent.com/google/styleguide/gh-pages/eclipse-java-google-style.xml",
          profile = "GoogleStyle",
        },
      },
      eclipse = { downloadSources = true },
      maven = { downloadSources = true },
      implementationsCodeLens = { enabled = true },
      referencesCodeLens = { enabled = true },
      references = { includeDecompiledSources = true },
      inlayHints = {
        parameterNames = { enabled = "all" },
      },
      signatureHelp = { enabled = true },
      completion = {
        favoriteStaticMembers = {
          "org.junit.jupiter.api.Assertions.*",
          "org.junit.Assert.*",
          "org.mockito.Mockito.*",
          "org.mockito.ArgumentMatchers.*",
          "org.assertj.core.api.Assertions.*",
          "java.util.Objects.requireNonNull",
          "java.util.Objects.requireNonNullElse",
        },
        filteredTypes = {
          "com.sun.*",
          "io.micrometer.shaded.*",
          "java.awt.*",
          "jdk.*",
          "sun.*",
        },
      },
      sources = {
        organizeImports = {
          starThreshold = 9999,
          staticStarThreshold = 9999,
        },
      },
      codeGeneration = {
        toString = {
          template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
        },
        useBlocks = true,
      },
    },
  },

  init_options = {
    bundles = bundles,
  },

  on_attach = function(_, bufnr)
    -- Enable inlay hints
    if vim.lsp.inlay_hint then
      vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
    end

    -- Set up java-specific commands after attach
    -- Give jdtls a moment to initialize
    vim.defer_fn(function()
      pcall(function()
        require("jdtls").setup_dap({ hotcodereplace = "auto" })
        require("jdtls.dap").setup_dap_main_class_configs()
      end)
    end, 1000)

    -- Buffer-local keymaps for Java
    local map = function(keys, func, desc)
      vim.keymap.set("n", keys, func, { buffer = bufnr, desc = "Java: " .. desc })
    end

    -- Java-specific actions (<leader>j)
    map("<leader>jo", jdtls.organize_imports, "Organize Imports")
    map("<leader>jv", jdtls.extract_variable, "Extract Variable")
    map("<leader>jc", jdtls.extract_constant, "Extract Constant")
    map("<leader>jt", jdtls.test_class, "Test Class")
    map("<leader>jn", jdtls.test_nearest_method, "Test Nearest Method")
    map("<leader>jm", function() jdtls.extract_method(true) end, "Extract Method")
    map("<leader>ju", jdtls.update_project_config, "Update Project Config")
    map("<leader>jr", function()
      -- Compile and run
      vim.cmd("w")
      vim.cmd("!javac % && java %:r")
    end, "Compile & Run")

    -- Visual mode mappings
    vim.keymap.set("v", "<leader>jv", function() jdtls.extract_variable(true) end,
      { buffer = bufnr, desc = "Java: Extract Variable" })
    vim.keymap.set("v", "<leader>jc", function() jdtls.extract_constant(true) end,
      { buffer = bufnr, desc = "Java: Extract Constant" })
    vim.keymap.set("v", "<leader>jm", function() jdtls.extract_method(true) end,
      { buffer = bufnr, desc = "Java: Extract Method" })

    -- Standard LSP keymaps (also available via plugins/lsp.lua but good to have here)
    map("gd", vim.lsp.buf.definition, "Go to Definition")
    map("gD", vim.lsp.buf.declaration, "Go to Declaration")
    map("gr", vim.lsp.buf.references, "Go to References")
    map("gi", vim.lsp.buf.implementation, "Go to Implementation")
    map("K", vim.lsp.buf.hover, "Hover Documentation")
    map("<leader>ca", vim.lsp.buf.code_action, "Code Action")
    map("<leader>cr", vim.lsp.buf.rename, "Rename Symbol")
  end,

  capabilities = (function()
    local ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
    if ok then
      return cmp_nvim_lsp.default_capabilities()
    end
    return vim.lsp.protocol.make_client_capabilities()
  end)(),
}

-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║                          START JDTLS SERVER                               ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

-- Log detected runtimes for debugging
local runtimes = find_java_runtimes()
if #runtimes > 0 then
  vim.notify("JDTLS: Found " .. #runtimes .. " Java runtime(s)", vim.log.levels.INFO)
else
  vim.notify("JDTLS: No Java runtimes found. Set JAVA_HOME or install JDK.", vim.log.levels.WARN)
end

-- Start or attach to jdtls
jdtls.start_or_attach(config)
