return {
  "m-demare/attempt.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  config = function()
    local elixir_template = function()
      return [[
        defmodule Example do
          def run do
            IO.puts("Do stuff")
          end
        end
        ]]
    end

    local javascript_template = function()
      return [[
        const hello_world = "hello world!";
        const log = () => {
         console.log(hello_world)
        }
        ]]
    end

    local typescript_template = function()
      return [[
        const hello_world: string = "hello world!";
        const log = ():void => {
         console.log(hello_world)
        }
      ]]
    end

    local opts = {
      autosave = true,
      initial_content = {
        ex = elixir_template,
        js = javascript_template,
        ts = typescript_template,
      },
      ext_options = { "lua", "js", "ts", "ex", "yml", "" },
      format_opts = { [""] = "[None]", js = "JavaScript", lua = "Lua", ex = "Elixir", ts = "Typescript" },
      run = {
        ex = { "w", "!elixir %" },
      },
    }
    local attempt = require "attempt"
    attempt.setup(opts)

    require("config.keymaps").attempt_mappings(attempt)
  end,
}
