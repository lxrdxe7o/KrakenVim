--- ASCII Header Loader Module
-- Loads ASCII headers from ascii/headers/ directory

local M = {}

local headers = {}
local current_index = 1

--- Scan and load all ASCII headers from the headers directory
local function scan_headers()
  local config_dir = vim.fn.stdpath("config")
  local headers_dir = config_dir .. "/ascii/headers"

  local handle = vim.loop.fs_scandir(headers_dir)
  if not handle then
    vim.notify("ASCII: Could not scan headers directory", vim.log.levels.WARN)
    return
  end

  local function scan_recursive(dir)
    while true do
      local name, typ = vim.loop.fs_scandir_next(handle)
      if not name then break end

      local full_path = dir .. "/" .. name
      if typ == "file" and name:match("%.lua$") then
        local ok, result = pcall(dofile, full_path)
        if ok and result and result.header and type(result.header) == "table" then
          table.insert(headers, result.header)
        end
      end
    end
  end

  scan_recursive(headers_dir)

  if #headers == 0 then
    vim.notify("ASCII: No headers found in " .. headers_dir, vim.log.levels.WARN)
  end
end

--- Initialize the loader
function M.setup()
  scan_headers()
  if #headers > 0 then
    vim.notify(string.format("ASCII: Loaded %d headers", #headers), vim.log.levels.INFO)
  end
end

--- Get all loaded headers
function M.get_all()
  return headers
end

--- Get header count
function M.get_count()
  return #headers
end

--- Get current header
function M.get_current()
  if #headers == 0 then
    return nil
  end
  return headers[current_index]
end

--- Get current header index
function M.get_current_index()
  return current_index
end

--- Get header by index (1-based)
function M.get_by_index(idx)
  if #headers == 0 or idx < 1 or idx > #headers then
    return nil
  end
  return headers[idx]
end

--- Set current header index
function M.set_index(idx)
  if idx >= 1 and idx <= #headers then
    current_index = idx
  end
end

--- Move to next header
function M.next()
  if #headers == 0 then
    return nil
  end
  current_index = current_index % #headers + 1
  return headers[current_index]
end

--- Move to previous header
function M.prev()
  if #headers == 0 then
    return nil
  end
  current_index = current_index - 1
  if current_index < 1 then
    current_index = #headers
  end
  return headers[current_index]
end

--- Get random header
function M.random()
  if #headers == 0 then
    return nil
  end
  math.randomseed(os.time())
  current_index = math.random(1, #headers)
  return headers[current_index]
end

--- Get header as terminal command that outputs colored text
-- This uses a simple approach: just echo the lines without color codes
function M.get_ascii_cmd()
  local header = M.get_current()
  if not header then
    return "echo 'No ASCII headers loaded'"
  end

  local lines = {}
  for _, line in ipairs(header) do
    table.insert(lines, string.format("echo %q", line))
  end

  return table.concat(lines, " && ")
end

--- Format header for direct display in dashboard
function M.get_header_text()
  local header = M.get_current()
  if not header then
    return {}
  end
  return header
end

return M