local npairs = require("nvim-autopairs")
local endwise = require("nvim-autopairs.ts-rule").endwise

npairs.setup({
  check_ts = true,
  close_triple_quotes = true,
})

npairs.add_rules({
  endwise("then$", "end", "lua", nil),
  endwise("do$", "end", "lua", nil),
  endwise(" do$", "end", "elixir", nil),
})
