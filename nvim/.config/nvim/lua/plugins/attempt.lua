local elixir_template = [[
defmodule Example do
  def run do
    IO.puts("Do stuff")
  end
end
Example.run()
]]

local javascript_template = [[
const hello_world = "hello world!";
const log = () => {
  console.log(hello_world)
}
]]

local typescript_template = [[
const hello_world: string = "hello world!";
const log = ():void => {
  console.log(hello_world)
}
]]

return {
  "m-demare/attempt.nvim",
  keys = function()
    local attempt = require("attempt")

    return {
      { "<leader>an", attempt.new_select, desc = "Attempt" },
      { "<leader>ar", attempt.run, desc = "Run Current Attempt Buffer" },
      { "<leader>ad", attempt.delete_buf, desc = "Delete Attempt" },
      { "<leader>ac", attempt.rename_buf, desc = "Rename Attempt From Current Buffer" },
      { "<leader>al", "<cmd>Telescope attempt", desc = "Open Attempt" },
    }
  end,
  opts = {
    autosave = true,
    initial_content = {
      ex = elixir_template,
      js = javascript_template,
      ts = typescript_template,
    },
    ext_options = { "lua", "js", "ts", "ex", "" },
    format_opts = { [""] = "[None]", js = "JavaScript", lua = "Lua", ex = "Elixir", ts = "Typescript" },
    run = {
      ex = { "w", "!elixir %" },
    },
  },
}
