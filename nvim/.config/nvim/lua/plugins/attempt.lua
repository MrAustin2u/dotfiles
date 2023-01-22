---@diagnostic disable: redundant-parameter
local present, attempt = pcall(require, 'attempt')

if not present then
  return
end

local M = {}

M.elixir_template = [[
defmodule Example do
  def run do
    IO.puts("Do stuff")
  end
end
Example.run()
]]

M.javascript_template = [[
const hello_world = "hello world!";

const log = () => {
  console.log(hello_world)
}
]]

M.typescript_template = [[
const hello_world: string = "hello world!";

const log = ():void => {
  console.log(hello_world)
}
]]

M.setup = function()
  attempt.setup {
    autosave = true,
    initial_content = {
      ex = M.elixir_template,
      js = M.javascript_template,
      ts = M.typescript_template,
    },
    ext_options = { 'lua', 'js', 'ts', 'ex', '' },
    format_opts = { [''] = '[None]', js = 'JavaScript', lua = 'Lua', ex = 'Elixir', ts = 'Typescript' },
    run = {
      ex = { 'w', '!elixir %' },
    },
  }

  require('core.mappings').attempt_mappings(attempt)
end

return M
