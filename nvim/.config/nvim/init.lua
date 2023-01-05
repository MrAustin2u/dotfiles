-- Speed up loading Lua modules in Neovim to improve startup time.
local present, impatient = pcall(require, "impatient")

if present then
	impatient.enable_profile()
end

-- require new configuration
local modules = {
	"core.globals",
	"core.options",
	"core.autocmds",
	"core.mappings",
	"plugins",
}

for _, module in ipairs(modules) do
	local ok, err = pcall(require, module)
	if not ok then
		error("Error loading " .. module .. "\n\n" .. err)
	end
end

-- Load project specific vimrc
require("core.utils").load_local_vimrc()
