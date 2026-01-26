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

-- FzfLua picker with live preview and persistence
function M.pick_colorscheme()
  local ok, fzf = pcall(require, "fzf-lua")
  if not ok then
    vim.notify("FzfLua not available", vim.log.levels.ERROR)
    return
  end

  -- Store current colorscheme for potential revert
  local current = vim.g.colors_name or M.default_colorscheme

  fzf.colorschemes({
    winopts = {
      height = 0.5,
      width = 0.35,
      row = 0.4,
    },
    actions = {
      -- On Enter - save and apply the selected colorscheme
      ["default"] = function(selected)
        if selected and selected[1] then
          local theme = selected[1]
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
      end,
      -- On Escape - revert to original and don't save
      ["esc"] = function()
        vim.schedule(function()
          M.apply_colorscheme(current)
        end)
      end,
    },
  })
end

return M
