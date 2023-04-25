local present, attempt = pcall(require, 'attempt')

if not present then
  return
end

local M = {}

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

M.setup = function()
  attempt.setup {
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
  }
end

return M
