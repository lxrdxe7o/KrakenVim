-- Image Manager for Snacks Dashboard
-- Manages cycling through images in the img/ folder

local M = {}

-- Configuration
M.config = {
	images_path = vim.fn.stdpath("config") .. "/img",
	state_file = vim.fn.stdpath("config") .. "/.nvim_state/last_image.txt",
	supported_formats = { "jpg", "jpeg", "png", "gif", "webp", "bmp" },
	remember_last = true,
	random_on_start = false,
}

-- State
M.images = {}
M.current_index = 1
M.initialized = false

-- Scan images directory
function M.scan_images()
	local images = {}
	local handle = vim.loop.fs_scandir(M.config.images_path)

	if not handle then
		return images
	end

	while true do
		local name, type = vim.loop.fs_scandir_next(handle)
		if not name then
			break
		end

		if type == "file" then
			local ext = name:match("%.([^%.]+)$")
			if ext then
				ext = ext:lower()
				for _, fmt in ipairs(M.config.supported_formats) do
					if ext == fmt then
						table.insert(images, {
							name = name,
							path = M.config.images_path .. "/" .. name,
						})
						break
					end
				end
			end
		end
	end

	-- Sort alphabetically
	table.sort(images, function(a, b)
		return a.name < b.name
	end)

	return images
end

-- Initialize the image manager
function M.init()
	if M.initialized then
		return
	end

	M.images = M.scan_images()

	if #M.images == 0 then
		M.current_index = 1
		M.initialized = true
		return
	end

	-- Determine starting image
	if M.config.random_on_start then
		M.current_index = math.random(1, #M.images)
	elseif M.config.remember_last then
		M.load_state()
	else
		M.current_index = 1
	end

	-- Ensure index is valid
	if M.current_index < 1 or M.current_index > #M.images then
		M.current_index = 1
	end

	M.initialized = true
end

-- Get current image path
function M.get_current()
	if #M.images == 0 then
		return nil
	end

	local img = M.images[M.current_index]
	return img and img.path or nil
end

-- Get current image name
function M.get_current_name()
	if #M.images == 0 then
		return "No images found"
	end

	local img = M.images[M.current_index]
	return img and img.name or "Unknown"
end

-- Cycle to next image
function M.next()
	if #M.images == 0 then
		return
	end

	M.current_index = M.current_index + 1
	if M.current_index > #M.images then
		M.current_index = 1
	end
end

-- Cycle to previous image
function M.prev()
	if #M.images == 0 then
		return
	end

	M.current_index = M.current_index - 1
	if M.current_index < 1 then
		M.current_index = #M.images
	end
end

-- Jump to random image
function M.random()
	if #M.images == 0 then
		return
	end

	if #M.images > 1 then
		local new_index
		repeat
			new_index = math.random(1, #M.images)
		until new_index ~= M.current_index
		M.current_index = new_index
	else
		M.current_index = 1
	end
end

-- Get image count
function M.get_count()
	return #M.images
end

-- Save state
function M.save_state()
	if not M.config.remember_last or #M.images == 0 then
		return
	end

	local img = M.images[M.current_index]
	if not img then
		return
	end

	local state_dir = vim.fn.fnamemodify(M.config.state_file, ":h")
	vim.fn.mkdir(state_dir, "p")

	local file = io.open(M.config.state_file, "w")
	if file then
		file:write(img.name)
		file:close()
	end
end

-- Load state
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

	for i, img in ipairs(M.images) do
		if img.name == saved_name then
			M.current_index = i
			return true
		end
	end

	return false
end

-- Rescan images (user command)
function M.rescan()
	M.images = M.scan_images()
	if M.current_index > #M.images then
		M.current_index = 1
	end
	vim.notify("Found " .. #M.images .. " images", vim.log.levels.INFO)
end

return M
