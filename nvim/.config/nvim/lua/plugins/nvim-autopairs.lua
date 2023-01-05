local present, npairs = pcall(require, "nvim-autopairs")

if not present then
  return
end

local endwise = require("nvim-autopairs.ts-rule").endwise

local config = {
  check_ts = true,
  close_triple_quotes = true,
}


local M = {}

M.setup = function()
  npairs.setup(config)

  npairs.add_rules({
    endwise("then$", "end", "lua", nil),
    endwise("do$", "end", "lua", nil),
    endwise(" do$", "end", "elixir", nil),
  })
end

return M
