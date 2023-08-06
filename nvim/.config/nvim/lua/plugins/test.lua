local neotest_present, neotest = pcall(require, "neotest")
local trouble_present, _trouble = pcall(require, "trouble")
local neotest_jest_present, neotest_jest = pcall(require, "neotest-jest")

if not neotest_present and not neotest_jest_present then
  return
end

local M = {}

local opts = {
  adapters = {
    ["neotest-elixir"] = true,
    neotest_jest({
      jestCommand = "npm test --",
      jestConfigFile = "custom.jest.config.ts",
      env = { CI = true },
      cwd = function(path)
        return vim.fn.getcwd()
      end,
    }),
  },
  status = { virtual_text = true },
  output = { open_on_run = true },
  quickfix = {
    open = function()
      if trouble_present then
        vim.cmd("Trouble quickfix")
      else
        vim.cmd("copen")
      end
    end,
  },
}

M.setup = function()
  local neotest_ns = vim.api.nvim_create_namespace("neotest")
  vim.diagnostic.config({
    virtual_text = {
      format = function(diagnostic)
        -- Replace newline and tab characters with space for more compact diagnostics
        local message = diagnostic.message:gsub("\n", " "):gsub("\t", " "):gsub("%s+", " "):gsub("^%s+", "")
        return message
      end,
    },
  }, neotest_ns)

  if opts.adapters then
    local adapters = {}
    for name, config in pairs(opts.adapters or {}) do
      if type(name) == "number" then
        if type(config) == "string" then
          config = require(config)
        end
        adapters[#adapters + 1] = config
      elseif config ~= false then
        local adapter = require(name)
        if type(config) == "table" and not vim.tbl_isempty(config) then
          local meta = getmetatable(adapter)
          if adapter.setup then
            adapter.setup(config)
          elseif meta and meta.__call then
            adapter(config)
          else
            error("Adapter " .. name .. " does not support setup")
          end
        end
        adapters[#adapters + 1] = adapter
      end
    end
    opts.adapters = adapters
  end

  neotest.setup(opts)

  require("keymaps").neotest_mappings(neotest)
end

return M
