local M = {}

--[[ KEYMAPS ]]

M.map = function(tbl)
  vim.keymap.set(tbl[1], tbl[2], tbl[3], tbl[4])
end

M.buf_nmap = function(bufnr, mapping, cmd, opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', mapping, cmd, opts)
end

M.buf_vmap = function(bufnr, mapping, cmd, opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'v', mapping, cmd, opts)
end

M.cmap = function(tbl)
  vim.keymap.set('c', tbl[1], tbl[2], tbl[3])
end

M.imap = function(tbl)
  vim.keymap.set('i', tbl[1], tbl[2], tbl[3])
end

M.nmap = function(tbl)
  vim.keymap.set('n', tbl[1], tbl[2], tbl[3])
end

M.tmap = function(tbl)
  vim.keymap.set('t', tbl[1], tbl[2], tbl[3])
end

M.vmap = function(tbl)
  vim.keymap.set('v', tbl[1], tbl[2], tbl[3])
end

M.xmap = function(tbl)
  vim.keymap.set('x', tbl[1], tbl[2], tbl[3])
end

--[[ AUTOCOMMANDS ]]

M.autocmd = function(args)
  local event = args[1]
  local group = args[2]
  local callback = args[3]

  vim.api.nvim_create_autocmd(event, {
    group = group,
    buffer = args[4],
    callback = function()
      callback()
    end,
    once = args.once,
  })
end

-- Load project specific vimrc
M.load_local_vimrc = function()
  local cwd = vim.fn.getcwd()
  local home_dir = vim.fn.expand '~'
  local local_vimrc = vim.fn.glob(cwd .. '/.vimrc')

  if cwd ~= home_dir and vim.fn.empty(local_vimrc) == 0 then
    vim.notify '------> loading local vimrc for project'
    vim.opt.exrc = true
    vim.cmd('source ' .. local_vimrc)
  end
end

-- Reload all lua configuration modules
M.reload_modules = function()
  local config_path = vim.fn.stdpath 'config' .. '/lua/'
  local lua_files = vim.fn.glob(config_path .. '**/*.lua', 0, 1)

  for _, file in ipairs(lua_files) do
    local module_name = string.gsub(file, '.*/(.*)/(.*).lua', '%1.%2')
    vim.pretty_print(module_name)
    package.loaded[module_name] = nil
  end
  vim.cmd [[source $MYVIMRC]]
  vim.notify 'Reloaded all config modules'
end

-- Pads a string's right hand side
---@param str string String to pad
---@param len number How many characters to pad by
---@param char string Character to use when padding
M.right_pad = function(str, len, char)
  local res = str .. string.rep(char or ' ', len - #str)
  return res, res ~= str
end

-- Pads a string's left hand side
---@param str string String to pad
---@param len number How many characters to pad by
---@param char string Character to use when padding
M.left_pad = function(str, len, char)
  local res = string.rep(char or ' ', len - #str) .. str
  return res, res ~= str
end

-- Returns a list of border characters
---@param name 'double' | 'none' | 'rounded' | 'shadow' | 'single'
---@return table<string>
M.get_border_chars = function(name)
  local border_chars = {
    double = { '═', '║', '═', '║', '╔', '╗', '╝', '╚' },
    none = { ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ' },
    rounded = { '─', '│', '─', '│', '╭', '╮', '╯', '╰' },
    shadow = { '▀', '█', '▄', '█', '█', '█', '█', '█' },
    single = { '─', '│', '─', '│', '┌', '┐', '┘', '└' },
  }

  return border_chars[name]
end

-- Builds the path for the json schema catalog cache
---@return Path path
local json_schemas_catalog_path = function()
  local Path = require 'plenary.path'
  local base_path = Path:new(vim.fn.stdpath 'data')
  return base_path:joinpath 'json_schema_catalog.json'
end

-- Fetches the JSON Schemas catalog from the SchemaStore API and stores it in a
-- local file
M.download_json_schemas = function()
  local catalog_path = json_schemas_catalog_path()

  -- download the latest json schema catalog
  local json = vim.fn.system {
    'curl',
    'https://json.schemastore.org/api/json/catalog.json',
    '--silent',
  }

  -- write file
  catalog_path:write(json, 'w')

  -- notify user
  vim.notify(string.format('Wrote JSON Schemas catalog to %s', catalog_path))
end

-- Reads JSON Schemas from cache location
M.read_json_schemas = function()
  local catalog_path = json_schemas_catalog_path()

  if catalog_path:exists() then
    local contents = catalog_path:read()
    return vim.json.decode(contents)
  else
    return nil
  end
end

-- Reloads the current Lua file
M.reload_current_luafile = function()
  local current_file = vim.fn.expand '%'
  print(current_file)
  vim.cmd(string.format('luafile %s', current_file))
  vim.notify(string.format('Reloaded %s!', current_file))
end

-- Checks if a table contains a value
---@param tbl table
---@param item any
---@return boolean
M.contains = function(tbl, item)
  for x in pairs(tbl) do
    if x == item then
      return true
    end
  end

  return false
end

--- Convert a list or map of items into a value by iterating all it's fields and transforming
--- them with a callback
---@generic T : table
---@param callback fun(T, T, key: string | number): T
---@param list T[]
---@param accum T
---@return T
function M.fold(callback, list, accum)
  for k, v in pairs(list) do
    accum = callback(accum, v, k)
    assert(accum ~= nil, 'The accumulator must be returned on each iteration')
  end
  return accum
end

--- Validate the keys passed to as.augroup are valid
---@param name string
---@param cmd Autocommand
local function validate_autocmd(name, cmd)
  local keys = { 'event', 'buffer', 'pattern', 'desc', 'command', 'group', 'once', 'nested' }
  local incorrect = M.fold(function(accum, _, key)
    if not vim.tbl_contains(keys, key) then
      table.insert(accum, key)
    end
    return accum
  end, cmd, {})
  if #incorrect == 0 then
    return
  end
  vim.schedule(function()
    ---@diagnostic disable-next-line: redundant-parameter
    vim.notify('Incorrect keys: ' .. table.concat(incorrect, ', '), 'error', {
      title = fmt('Autocmd: %s', name),
    })
  end)
end

---@class Autocommand
---@field desc string
---@field event  string[] list of autocommand events
---@field pattern string[] list of autocommand patterns
---@field command string | function
---@field nested  boolean
---@field once    boolean
---@field buffer  number

---Create an autocommand
---returns the group ID so that it can be cleared or manipulated.
---@param name string
---@param commands Autocommand[]
---@return number
M.augroup = function(name, commands)
  assert(name ~= 'User', 'The name of an augroup CANNOT be User')

  local id = vim.api.nvim_create_augroup(name, { clear = true })

  for _, autocmd in ipairs(commands) do
    validate_autocmd(name, autocmd)
    local is_callback = type(autocmd.command) == 'function'
    vim.api.nvim_create_autocmd(autocmd.event, {
      group = id,
      pattern = autocmd.pattern,
      desc = autocmd.desc,
      callback = is_callback and autocmd.command or nil,
      command = not is_callback and autocmd.command or nil,
      once = autocmd.once,
      nested = autocmd.nested,
      buffer = autocmd.buffer,
    })
  end

  return id
end

return M
