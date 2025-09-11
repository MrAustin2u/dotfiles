local M = {}

-- Load project specific vimrc
function M.load_local_vimrc()
  local cwd = vim.fn.getcwd()
  local home_dir = vim.fn.expand "~"
  local local_vimrc = vim.fn.glob(cwd .. "/.vimrc")

  if cwd ~= home_dir and vim.fn.empty(local_vimrc) == 0 then
    vim.notify "------> loading local vimrc for project"
    vim.opt.exrc = true
    vim.cmd("source " .. local_vimrc)
  end
end

M.icons = {
  dap = {
    Stopped = { "󰁕 ", "DiagnosticWarn", "DapStoppedLine" },
    Breakpoint = " ",
    BreakpointCondition = " ",
    BreakpointRejected = { " ", "DiagnosticError" },
    LogPoint = ".>",
  },
  diagnostics = {
    BoldError = "",
    BoldHint = "",
    BoldInformation = "",
    BoldQuestion = "",
    BoldWarning = "",
    Debug = "",
    Error = "",
    Hint = " ",
    Info = " ",
    Information = "",
    Question = "",
    Trace = "✎",
    Warn = " ",
    Warning = "",
  },
  git = {
    added = " ",
    modified = " ",
    removed = " ",
    LineAdded = " ",
    LineModified = " ",
    LineRemoved = " ",
    FileDeleted = " ",
    FileIgnored = "◌",
    FileRenamed = " ",
    FileStaged = "S",
    FileUnmerged = "",
    FileUnstaged = "",
    FileUntracked = "U",
    Diff = " ",
    Repo = " ",
    Octoface = " ",
    Copilot = " ",
    Branch = "",
  },
  ui = {
    ArrowCircleDown = "",
    ArrowCircleLeft = "",
    ArrowCircleRight = "",
    ArrowCircleUp = "",
    BoldArrowDown = "",
    BoldArrowLeft = "",
    BoldArrowRight = "",
    BoldArrowUp = "",
    BoldClose = "",
    BoldDividerLeft = "",
    BoldDividerRight = "",
    BoldLineLeft = "▎",
    BoldLineMiddle = "┃",
    BoldLineDashedMiddle = "┋",
    BookMark = "",
    BoxChecked = " ",
    Bug = " ",
    Stacks = "",
    Scopes = "",
    Watches = "󰂥",
    DebugConsole = " ",
    Calendar = " ",
    Check = "",
    ChevronRight = "",
    ChevronShortDown = "",
    ChevronShortLeft = "",
    ChevronShortRight = "",
    ChevronShortUp = "",
    Circle = " ",
    Close = "󰅖",
    CloudDownload = " ",
    Code = "",
    Comment = "",
    Dashboard = "",
    DividerLeft = "",
    DividerRight = "",
    DoubleChevronRight = "»",
    Ellipsis = "",
    EmptyFolder = " ",
    EmptyFolderOpen = " ",
    File = " ",
    FileSymlink = "",
    Files = " ",
    FindFile = "󰈞",
    FindText = "󰊄",
    Fire = "",
    Folder = "󰉋 ",
    FolderOpen = " ",
    FolderSymlink = " ",
    Forward = " ",
    Gear = " ",
    History = " ",
    Lightbulb = " ",
    LineLeft = "▏",
    LineMiddle = "│",
    List = " ",
    Lock = " ",
    NewFile = " ",
    Note = " ",
    Package = " ",
    Pencil = "󰏫 ",
    Plus = " ",
    Project = " ",
    Search = " ",
    SignIn = " ",
    SignOut = " ",
    Tab = "󰌒 ",
    Table = " ",
    Target = "󰀘 ",
    Telescope = " ",
    Text = " ",
    Tree = "",
    Triangle = "󰐊",
    TriangleMediumArrowRight = "",
    TriangleShortArrowDown = "",
    TriangleShortArrowLeft = "",
    TriangleShortArrowRight = "",
    TriangleShortArrowUp = "",
  },
  kinds = {
    Array = " ",
    Boolean = "󰨙 ",
    Class = " ",
    Codeium = "󰘦 ",
    Color = " ",
    Control = " ",
    Collapsed = " ",
    Constant = "󰏿 ",
    Constructor = " ",
    Copilot = " ",
    Enum = " ",
    EnumMember = " ",
    Event = " ",
    Field = " ",
    File = " ",
    Folder = " ",
    Function = "󰊕 ",
    Interface = " ",
    Key = " ",
    Keyword = " ",
    Method = "󰊕 ",
    Module = " ",
    Namespace = "󰦮 ",
    Null = " ",
    Number = "󰎠 ",
    Object = " ",
    Operator = " ",
    Package = " ",
    Property = " ",
    Reference = " ",
    Snippet = "󱄽 ",
    String = " ",
    Struct = "󰆼 ",
    Supermaven = " ",
    TabNine = "󰏚 ",
    Text = " ",
    TypeParameter = " ",
    Unit = " ",
    Value = " ",
    Variable = "󰀫 ",
  },
  misc = {
    Robot = "󰚩 ",
    Squirrel = " ",
    Tag = " ",
    Watch = "",
    Smiley = " ",
    Package = " ",
    CircuitBoard = " ",
  },
  ft = {
    octo = "",
  },
}

M.kind_filter = {
  default = {
    "Class",
    "Constructor",
    "Enum",
    "Field",
    "Function",
    "Interface",
    "Method",
    "Module",
    "Namespace",
    "Package",
    "Property",
    "Struct",
    "Trait",
  },
  markdown = false,
  help = false,
  -- you can specify a different filter for each filetype
  lua = {
    "Class",
    "Constructor",
    "Enum",
    "Field",
    "Function",
    "Interface",
    "Method",
    "Module",
    "Namespace",
    -- "Package", -- remove package since luals uses it for control flow structures
    "Property",
    "Struct",
    "Trait",
  },
}

M.get_kind_filter = function(buf)
  buf = (buf == nil or buf == 0) and vim.api.nvim_get_current_buf() or buf
  local ft = vim.bo[buf].filetype
  if M.kind_filter == false then
    return
  end
  if M.kind_filter[ft] == false then
    return
  end
  if type(M.kind_filter[ft]) == "table" then
    return M.kind_filter[ft]
  end
  ---@diagnostic disable-next-line: return-type-mismatch
  return type(M.kind_filter) == "table" and type(M.kind_filter.default) == "table" and M.kind_filter.default or nil
end

-- Returns a list of border characters
---@param name 'double' | 'none' | 'rounded' | 'shadow' | 'single'
---@return table<string>
function M.get_border_chars(name)
  local border_chars = {
    double = { "═", "║", "═", "║", "╔", "╗", "╝", "╚" },
    none = { " ", " ", " ", " ", " ", " ", " ", " " },
    rounded = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
    shadow = { "▀", "█", "▄", "█", "█", "█", "█", "█" },
    single = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
  }

  return border_chars[name]
end

-- Reload all lua configuration modules
function M.reload_modules()
  local config_path = vim.fn.stdpath "config" .. "/lua/"
  local lua_files = vim.fn.glob(config_path .. "**/*.lua", false, true)

  for _, file in ipairs(lua_files) do
    local module_name = string.gsub(file, ".*/(.*)/(.*).lua", "%1.%2")
    vim.pretty_print(module_name)
    package.loaded[module_name] = nil
  end
  vim.cmd [[source $MYVIMRC]]
  vim.notify "Reloaded all config modules"
end

-- Reloads the current Lua file
function M.reload_current_luafile()
  local current_file = vim.fn.expand "%"
  print(current_file)
  vim.cmd(string.format("luafile %s", current_file))
  vim.notify(string.format("Reloaded %s!", current_file))
end

-- Pads a string's right hand side
---@param str string String to pad
---@param len number How many characters to pad by
---@param char string Character to use when padding
function M.right_pad(str, len, char)
  local res = str .. string.rep(char or " ", len - #str)
  return res, res ~= str
end

-- Pads a string's left hand side
---@param str string String to pad
---@param len number How many characters to pad by
---@param char string Character to use when padding
function M.left_pad(str, len, char)
  local res = string.rep(char or " ", len - #str) .. str
  return res, res ~= str
end

-- Checks if a table contains a value
---@param tbl table
---@param item any
---@return boolean
function M.contains(tbl, item)
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
    assert(accum ~= nil, "The accumulator must be returned on each iteration")
  end
  return accum
end

-- this needs to be called something other than Autocmd to avoid conflict with
-- the built-in type
---@class MyAutocmd
---@field desc?    string
---@field event    string[] list of autocommand events
---@field pattern? string[] list of autocommand patterns
---@field command  string | function
---@field nested?  boolean
---@field once?    boolean
---@field buffer?  number

--- Validate the keys passed to as.augroup are valid
---@param name string
---@param cmd MyAutocmd
local function validate_autocmd(name, cmd)
  local keys = { "event", "buffer", "pattern", "desc", "command", "group", "once", "nested" }
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
    vim.notify("Incorrect keys: " .. table.concat(incorrect, ", "), vim.log.levels.ERROR, {
      title = fmt("Autocmd: %s", name),
    })
  end)
end

--- Create an autocommand
--- returns the group ID so that it can be cleared or manipulated.
---@param name string
---@param commands MyAutocmd[]
---@return number
function M.augroup(name, commands)
  assert(name ~= "User", "The name of an augroup CANNOT be User")

  local id = vim.api.nvim_create_augroup(name, { clear = true })

  for _, autocmd in ipairs(commands) do
    validate_autocmd(name, autocmd)
    local is_callback = type(autocmd.command) == "function"
    local callback = is_callback and autocmd.command or nil
    local command = not is_callback and autocmd.command or nil

    vim.api.nvim_create_autocmd(autocmd.event, {
      group = id,
      pattern = autocmd.pattern,
      desc = autocmd.desc,
      callback = callback,
      command = command --[[@as string]],
      once = autocmd.once,
      nested = autocmd.nested,
      buffer = autocmd.buffer,
    })
  end

  return id
end

--- Uses TreeSitter to delete all comments in the buffer
function M.delete_comments_in_buffer()
  local parser = vim.treesitter.get_parser(0)
  if not parser then
    vim.notify("No treesitter parser found for this buffer", vim.log.levels.WARN)
    return
  end

  local tree = parser:parse()[1]

  local function delete_comments(node)
    if
      node:type() == "comment"
      or node:type() == "line_comment"
      or node:type() == "block_comment"
      or node:type() == "html_comment"
    then
      local start_row, start_col, end_row, end_col = node:range()
      vim.api.nvim_buf_set_text(0, start_row, start_col, end_row, end_col, {})
    end

    for child in node:iter_children() do
      delete_comments(child)
    end
  end

  delete_comments(tree:root())
end

function M.has_words_before()
  local line, col = (unpack or table.unpack)(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match "%s" == nil
end

--- Appends `new_names` to `root_files` if `field` is found in any such file in any ancestor of `fname`.
---
--- NOTE: this does a "breadth-first" search, so is broken for multi-project workspaces:
--- https://github.com/neovim/nvim-lspconfig/issues/3818#issuecomment-2848836794
---
--- @param root_files string[] List of root-marker files to append to.
--- @param new_names string[] Potential root-marker filenames (e.g. `{ 'package.json', 'package.json5' }`) to inspect for the given `field`.
--- @param field string Field to search for in the given `new_names` files.
--- @param fname string Full path of the current buffer name to start searching upwards from.
function M.root_markers_with_field(root_files, new_names, field, fname)
  local path = vim.fn.fnamemodify(fname, ":h")
  local found = vim.fs.find(new_names, { path = path, upward = true })

  for _, f in ipairs(found or {}) do
    -- Match the given `field`.
    for line in io.lines(f) do
      if line:find(field) then
        root_files[#root_files + 1] = vim.fs.basename(f)
        break
      end
    end
  end

  return root_files
end

function M.insert_package_json(root_files, field, fname)
  return M.root_markers_with_field(root_files, { "package.json", "package.json5" }, field, fname)
end

--- Returns a function which matches a filepath against the given glob/wildcard patterns.
--- @param ... string Glob patterns to match against (e.g., "*.lua", "package.json", "Cargo.toml")
--- @return fun(path: string): string|nil Function that returns the root directory if pattern matches, nil otherwise
function M.root_pattern(...)
  local patterns = { ... }

  return function(path)
    local search_path = vim.fn.fnamemodify(path, ":p:h")
    local found = vim.fs.find(patterns, { path = search_path, upward = true })

    if found and #found > 0 then
      return vim.fn.fnamemodify(found[1], ":p:h")
    end

    return nil
  end
end

---@return table
function M.tbl_flatten(t)
  return vim.iter(t):flatten(math.huge):totable()
end

return M
