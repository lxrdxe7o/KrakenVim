# Filetype Plugins

## Context
Filetype-specific Neovim configurations. Currently only Java is configured. Parent context: [../AGENTS.md](../AGENTS.md).

## Files

| Path | Purpose |
|---|---|
| `ftplugin/java.lua` | Java LSP configuration via nvim-jdtls |

## Java Configuration (`ftplugin/java.lua`)

This file is auto-loaded by Neovim when opening `.java` files. It configures:
- **nvim-jdtls** LSP server with Mason-installed launcher
- **Dynamic Java runtime detection**: scans JAVA_HOME, `/usr/lib/jvm`, SDKMAN, asdf, and macOS paths
- **Google Java Format**: uses google-java-format via Mason, with Google Style XML config
- **DAP bundles**: java-debug-adapter and java-test integration for debugging and test running
- **Lombok support**: auto-detects Lombok jar from Mason
- **Project root detection**: looks for gradlew, mvnw, .git, pom.xml, build.gradle
- **Buffer-local keymaps**: `<leader>j` group for organize imports, extract variable/constant/method, test class, test nearest, update project config
- **Eclipse workspace**: unique workspace directory per project (`jdtls-workspace/<project-name>`)

### Key Features
- `:checkhealth krakenvim` verifies jdtls launcher existence
- Debug profiles: Launch file, Launch file with arguments, Django, Flask
- Custom completion favorites: JUnit, Mockito, AssertJ, Objects.requireNonNull
- Filtered types: `com.sun.*`, `java.awt.*`, `sun.*`
- Inlay hints: parameter names enabled for all
- Code lens: implementations and references

### Constraints
- jdtls must be installed via Mason (`:MasonInstall jdtls`)
- Requires JDK 17+ (LSP), with optional runtimes for different project versions
- Java DAP configuration is defined in jdtls itself, not in `lua/plugins/dap.lua`
- iOS/macOS specific: handles both Linux (`config_linux`) and macOS (`config_mac`) OS config directories

## Ownership
- Java specialist: `ftplugin/java.lua`
