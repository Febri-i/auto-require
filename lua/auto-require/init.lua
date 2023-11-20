local path = require("auto-require/path")
--
--
---Scan the path to get array of "<name1>.<name2>...."
---@param dir_list string[]
---@param luapath string should be ~/.config/nvim/lua or anything just makesure that its in the lua dir
---@param excludes? string[]
---@return string[]
local function scanForRequire(luapath, dir_list, excludes)
	if excludes == nil then
		excludes = {}
	end

	---Recursively scan and generate array of "<name1>.<name2>..."
	---@param _path string path to scan
	---@param parent string require parent eg: configs.keymaps
	---@return string[]
	local function scanlua(_path, parent)
		local paths = {}
		local _scandir = vim.loop.fs_scandir(_path)
		if _scandir == nil then
			vim.notify(_path .. " is NOT a directory", vim.log.levels.ERROR)
			return paths
		end
		local dir = vim.loop.fs_scandir_next(_scandir)
		while dir ~= nil do
			local fullpath = path.path_join(_path, dir)
			local stat = vim.loop.fs_lstat(fullpath)
			if stat ~= nil then
				if stat.type == "directory" then
					local dir_parent = parent .. "." .. dir
					if not vim.tbl_contains(excludes, dir_parent) then
						paths = vim.fn.extend(paths, scanlua(fullpath, dir_parent))
					end
				elseif stat.type == "file" and string.sub(dir, #dir - 2) == "lua" then
					local requirepath = parent .. "." .. string.sub(dir, 1, #dir - 4)
					if not vim.tbl_contains(excludes, requirepath) then
						table.insert(paths, requirepath)
					end
				end
			end

			dir = vim.loop.fs_scandir_next(_scandir)
		end
		return paths
	end

	local luas = {}
	for _, dir in pairs(dir_list) do
		luas = vim.fn.extend(luas, scanlua(path.path_join(luapath, dir), table.concat(path.split(dir, "/"), ".")))
	end
	return luas
end

local M = {}

---@class AutoRequireOpts
---@field dir_list string[] directory to scan
---@field lua_root? string
---@field excludes? string[] file/dir require to exclude
local defaults = {
	dir_list = {},
	excludes = {},
	lua_root = "~/.config/nvim/lua",
}

---Setup auto require
---@param opts AutoRequireOpts
M.setup = function(opts)
	---@type AutoRequireOpts
	opts = vim.tbl_extend("force", defaults, opts)
	opts.lua_root = vim.fn.expand(opts.lua_root)
	local confpathlstat = vim.loop.fs_lstat(opts.lua_root)
	if confpathlstat == nil then
		vim.notify("Error " .. opts.lua_root .. " not found")
		return
	end

	if confpathlstat.type ~= "directory" then
		vim.notify("Error " .. opts.lua_root .. " is not a directory")
		return
	end

	local require_list = scanForRequire(opts.lua_root, opts.dir_list or {}, opts.excludes or {})

	for _, requirestr in pairs(require_list or {}) do
		require(requirestr)
	end
end

return M
