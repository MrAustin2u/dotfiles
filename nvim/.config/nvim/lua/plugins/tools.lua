return {
  {
    "narutoxy/silicon.lua",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("silicon").setup({
        font = "MonoLisa",
        theme = "tokyonight_moon",
        bgColor = "#636da6",
      })
      require("config.keymaps").silicon_mappings()
    end,
  },
  {
    "pwntester/octo.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
      "nvim-tree/nvim-web-devicons",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      local octo = require("octo")

      octo.setup({
        default_remote = { "origin" },
      })

      local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
      parser_config.markdown.filetype_to_parsername = "octo"
    end,
  },
  {
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
      local attempt = require("attempt")
      attempt.setup(opts)

      require("config.keymaps").attempt_mappings(attempt)
    end,
  },
}
