-- Colorscheme configuration with persistent theme switching

local M = {}

-- Path to store the selected colorscheme
M.colorscheme_file = vim.fn.stdpath("data") .. "/colorscheme.txt"

-- Default colorscheme if none is saved
M.default_colorscheme = "bamboo"

-- Get the saved colorscheme or return default
function M.get_saved_colorscheme()
  if vim.fn.filereadable(M.colorscheme_file) == 1 then
    local file = io.open(M.colorscheme_file, "r")
    if file then
      local theme = file:read("*l")
      file:close()
      if theme and theme ~= "" then
        return theme
      end
    end
  end
  return M.default_colorscheme
end

-- Save colorscheme to file
function M.save_colorscheme(name)
  -- Ensure directory exists
  local data_dir = vim.fn.stdpath("data")
  vim.fn.mkdir(data_dir, "p")
  
  local file = io.open(M.colorscheme_file, "w")
  if file then
    file:write(name)
    file:close()
    return true
  end
  return false
end

-- Apply colorscheme with error handling
function M.apply_colorscheme(name)
  local ok, _ = pcall(vim.cmd.colorscheme, name)
  if not ok then
    vim.notify("Colorscheme '" .. name .. "' not found, using " .. M.default_colorscheme, vim.log.levels.WARN)
    pcall(vim.cmd.colorscheme, M.default_colorscheme)
    return false
  end
  return true
end

-- Load the saved colorscheme (called from init.lua after plugins load)
function M.load_saved()
  local saved = M.get_saved_colorscheme()
  M.apply_colorscheme(saved)
end

-- Telescope picker with live preview and persistence
function M.pick_colorscheme()
  local ok, telescope = pcall(require, "telescope.builtin")
  if not ok then
    vim.notify("Telescope not available", vim.log.levels.ERROR)
    return
  end

  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  -- Store current colorscheme for potential revert
  local current = vim.g.colors_name or M.default_colorscheme

  telescope.colorscheme({
    enable_preview = true,
    attach_mappings = function(prompt_bufnr, map)
      -- On Enter - save and apply the selected colorscheme
      actions.select_default:replace(function()
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        
        -- Use vim.schedule to ensure everything is done after picker closes
        vim.schedule(function()
          if selection then
            local theme = selection.value or selection[1]
            -- Apply the colorscheme
            if M.apply_colorscheme(theme) then
              -- Save to file
              if M.save_colorscheme(theme) then
                vim.notify("✓ Saved: " .. theme, vim.log.levels.INFO)
              else
                vim.notify("✗ Failed to save", vim.log.levels.ERROR)
              end
            end
          end
        end)
      end)

      -- On Escape - revert to original and don't save
      local revert = function()
        actions.close(prompt_bufnr)
        vim.schedule(function()
          M.apply_colorscheme(current)
        end)
      end
      
      map("i", "<Esc>", revert)
      map("n", "<Esc>", revert)
      map("n", "q", revert)

      return true
    end,
  })
end

return M
