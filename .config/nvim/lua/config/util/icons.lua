---@class config.util.icons
local M = {}

M.dap = {
  Stopped = { "󰁕 ", "DiagnosticWarn", "DapStoppedLine" },
  Breakpoint = " ",
  BreakpointCondition = " ",
  BreakpointRejected = { " ", "DiagnosticError" },
  LogPoint = ".>",
}

M.kinds = {
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
}

M.git = {
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
}

M.ui = {
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
}

M.diagnostics = {
  BoldError = "",
  Error = "",
  BoldWarning = "",
  Warning = "",
  BoldInformation = "",
  Information = "",
  BoldQuestion = "",
  Question = "",
  BoldHint = "",
  Hint = "󰌶",
  Debug = "",
  Trace = "✎",
}

M.misc = {
  Robot = "󰚩 ",
  Squirrel = " ",
  Tag = " ",
  Watch = "",
  Smiley = " ",
  Package = " ",
  CircuitBoard = " ",
}

M.ft = {
  octo = "",
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

return M
