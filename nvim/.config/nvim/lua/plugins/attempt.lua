return {
  "m-demare/attempt.nvim",
  config = function()
    local attempt = require("attempt")

    local elixir_template = [[
defmodule Example do
  def run do
    IO.puts("Do stuff")
  end
end
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

    attempt.setup({
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
    })

    require("keymaps").attempt_mappings(attempt)
  end,
}
