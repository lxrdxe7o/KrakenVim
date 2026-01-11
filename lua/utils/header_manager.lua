-- Header Manager for Alpha Dashboard
-- Manages loading, cycling, and persistence of ASCII art headers
-- Optimized with caching for fast startup

local M = {}

-- Configuration
M.config = {
	headers_path = vim.fn.stdpath("config") .. "/ascii/headers",
	cache_file = vim.fn.stdpath("config") .. "/ascii/cache/header_index.json",
	state_file = vim.fn.stdpath("config") .. "/.nvim_state/last_header.txt",
	max_width = 48, -- Characters
	max_height = 24, -- Lines
	remember_last = true, -- Remember last header across sessions
	random_on_start = false, -- Use random header on startup (overrides remember_last)
}

-- State
M.headers = {} -- List of {name, path, category, index}
M.current_index = 1
M.initialized = false
M._cache_loaded = false

-- Get modification time of a directory (recursively checks all files)
local function get_headers_mtime()
	local newest_mtime = 0
	local function check_dir(dir)
		local handle = vim.loop.fs_scandir(dir)
		if not handle then return end
		while true do
			local name, type = vim.loop.fs_scandir_next(handle)
			if not name then break end
			local path = dir .. "/" .. name
			if type == "directory" then
				check_dir(path)
			elseif type == "file" then
				local stat = vim.loop.fs_stat(path)
				if stat and stat.mtime.sec > newest_mtime then
					newest_mtime = stat.mtime.sec
				end
			end
		end
	end
	check_dir(M.config.headers_path)
	return newest_mtime
end

-- Load headers from cache file
local function load_cache()
	local file = io.open(M.config.cache_file, "r")
	if not file then return nil end
	
	local content = file:read("*all")
	file:close()
	
	local ok, cache = pcall(vim.json.decode, content)
	if not ok or not cache then return nil end
	
	-- Validate cache version and check if headers directory was modified
	if cache.version ~= 1 then return nil end
	
	local current_mtime = get_headers_mtime()
	if cache.headers_mtime ~= current_mtime then
		return nil -- Cache is stale
	end
	
	return cache.headers
end

-- Save headers to cache file
local function save_cache(headers)
	-- Ensure cache directory exists
	local cache_dir = vim.fn.fnamemodify(M.config.cache_file, ":h")
	vim.fn.mkdir(cache_dir, "p")
	
	local cache = {
		version = 1,
		headers_mtime = get_headers_mtime(),
		headers = headers,
	}
	
	local file = io.open(M.config.cache_file, "w")
	if file then
		file:write(vim.json.encode(cache))
		file:close()
	end
end

-- Scan headers directory recursively
function M.scan_headers()
	-- Try to load from cache first
	local cached = load_cache()
	if cached then
		M._cache_loaded = true
		return cached
	end
	
	local headers = {}
	local index = 1

	local function scan_dir(dir, category)
		category = category or ""

		local handle = vim.loop.fs_scandir(dir)
		if not handle then
			return
		end

		while true do
			local name, type = vim.loop.fs_scandir_next(handle)
			if not name then
				break
			end

			local full_path = dir .. "/" .. name

			if type == "directory" then
				-- Recursively scan subdirectories (categories)
				local subcat = category == "" and name or (category .. "/" .. name)
				scan_dir(full_path, subcat)
			elseif type == "file" and name:match("%.lua$") then
				-- Found a header file
				local header_name = name:gsub("%.lua$", "")
				local display_name = category == "" and header_name or (category .. "/" .. header_name)

				table.insert(headers, {
					name = header_name,
					display_name = display_name,
					path = full_path,
					category = category,
					index = index,
				})
				index = index + 1
			end
		end
	end

	scan_dir(M.config.headers_path)

	-- Sort by category then name
	table.sort(headers, function(a, b)
		if a.category ~= b.category then
			return a.category < b.category
		end
		return a.name < b.name
	end)

	-- Reassign indices after sorting
	for i, header in ipairs(headers) do
		header.index = i
	end

	-- Save to cache for next startup
	save_cache(headers)

	return headers
end

-- Clear only the highlight groups that exist (optimized)
local function clear_header_highlights()
	-- Only clear highlights that actually exist - break early
	for i = 0, 5000 do
		local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = "I2A" .. i })
		if not ok or vim.tbl_isempty(hl) then
			break -- No more highlights to clear
		end
		vim.api.nvim_set_hl(0, "I2A" .. i, {})
	end
end

-- Load a single header file
function M.load_header(path)
	-- Clear existing header-related highlights (optimized)
	clear_header_highlights()

	local ok, result = pcall(dofile, path)
	if not ok then
		vim.notify("Failed to load header: " .. path .. "\n" .. result, vim.log.levels.ERROR)
		return nil
	end

	if type(result) ~= "table" then
		vim.notify("Invalid header format: " .. path, vim.log.levels.ERROR)
		return nil
	end

	-- Support both formats:
	-- 1. { header = {...} } - simple format
	-- 2. { header = {type='text', opts={...}, val={...}} } - advanced format
	local header_data = result.header

	if not header_data then
		vim.notify("Header file missing 'header' field: " .. path, vim.log.levels.ERROR)
		return nil
	end

	-- Validate size (check the actual ASCII content)
	local lines = header_data.val or header_data
	if type(lines) ~= "table" then
		vim.notify("Invalid header data format: " .. path, vim.log.levels.ERROR)
		return nil
	end

	return header_data
end

-- Initialize the header manager
function M.init()
	if M.initialized then
		return
	end

	-- Scan for headers (uses cache if available)
	M.headers = M.scan_headers()

	if #M.headers == 0 then
		vim.notify("No headers found in " .. M.config.headers_path, vim.log.levels.WARN)
		M.current_index = 1
		M.initialized = true
		return
	end

	-- Determine starting header
	if M.config.random_on_start then
		M.current_index = math.random(1, #M.headers)
	elseif M.config.remember_last then
		M.load_state()
	else
		M.current_index = 1
	end

	-- Ensure index is valid
	if M.current_index < 1 or M.current_index > #M.headers then
		M.current_index = 1
	end

	M.initialized = true
end

-- Get current header data
function M.get_current()
	if #M.headers == 0 then
		return nil
	end

	local header_info = M.headers[M.current_index]
	if not header_info then
		return nil
	end

	return M.load_header(header_info.path)
end

-- Cycle to next header
function M.next()
	if #M.headers == 0 then
		return
	end

	M.current_index = M.current_index + 1
	if M.current_index > #M.headers then
		M.current_index = 1 -- Wrap around
	end
end

-- Cycle to previous header
function M.prev()
	if #M.headers == 0 then
		return
	end

	M.current_index = M.current_index - 1
	if M.current_index < 1 then
		M.current_index = #M.headers -- Wrap around
	end
end

-- Jump to random header
function M.random()
	if #M.headers == 0 then
		return
	end

	-- Avoid selecting the same header if possible
	if #M.headers > 1 then
		local new_index
		repeat
			new_index = math.random(1, #M.headers)
		until new_index ~= M.current_index
		M.current_index = new_index
	else
		M.current_index = 1
	end
end

-- Get current header name
function M.get_current_name()
	if #M.headers == 0 then
		return "No headers available"
	end

	local header_info = M.headers[M.current_index]
	if not header_info then
		return "Unknown"
	end

	return header_info.display_name
end

-- Get header count
function M.get_count()
	return #M.headers
end

-- Save current header to state file
function M.save_state()
	if not M.config.remember_last or #M.headers == 0 then
		return
	end

	local header_info = M.headers[M.current_index]
	if not header_info then
		return
	end

	-- Ensure state directory exists
	local state_dir = vim.fn.fnamemodify(M.config.state_file, ":h")
	vim.fn.mkdir(state_dir, "p")

	-- Write header name to state file
	local file = io.open(M.config.state_file, "w")
	if file then
		file:write(header_info.display_name)
		file:close()
	end
end

-- Load last header from state file
function M.load_state()
	if not M.config.remember_last then
		return false
	end

	local file = io.open(M.config.state_file, "r")
	if not file then
		return false
	end

	local saved_name = file:read("*all")
	file:close()

	if not saved_name or saved_name == "" then
		return false
	end

	-- Find header by name
	for i, header in ipairs(M.headers) do
		if header.display_name == saved_name then
			M.current_index = i
			return true
		end
	end

	return false
end

-- Apply current header to alpha dashboard
function M.apply_to_dashboard(dashboard)
	local header_data = M.get_current()

	if not header_data then
		-- Fallback to a simple message
		dashboard.section.header.val = {
			"",
			"  No headers found",
			"  Add headers to: " .. M.config.headers_path,
			"",
		}
		return
	end

	-- Check if it's advanced format (with type, opts, val)
	if type(header_data) == "table" and header_data.type then
		-- Advanced format (alpha-ascii style) - completely replace the header section
		-- We need to preserve the section structure but replace the header entirely
		for k in pairs(dashboard.section.header) do
			dashboard.section.header[k] = nil
		end
		for k, v in pairs(header_data) do
			dashboard.section.header[k] = v
		end
	else
		-- Simple format (just array of strings)
		-- Ensure header has the basic structure
		if not dashboard.section.header.val then
			dashboard.section.header = {
				type = "text",
				val = header_data,
				opts = {
					position = "center",
					hl = "AlphaHeader",
				}
			}
		else
			dashboard.section.header.val = header_data
		end
	end
end

-- Rebuild the header cache (user command)
function M.rebuild_cache()
	-- Delete old cache
	os.remove(M.config.cache_file)
	M._cache_loaded = false
	
	-- Rescan
	M.headers = M.scan_headers()
	
	vim.notify("Header cache rebuilt: " .. #M.headers .. " headers found", vim.log.levels.INFO)
end

return M
