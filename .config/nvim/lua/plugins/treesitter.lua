return {
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
    dependencies = {
      "JoosepAlviste/nvim-ts-context-commentstring",
      "nvim-treesitter/nvim-treesitter-context",
    },
    config = function()
      require("treesitter-context").setup {
        enable = true,
        max_lines = 3,
        trim_scope = "outer",
        mode = "cursor",
      }

      -- Ensure parsers are installed. On the main branch rewrite the old
      -- `ensure_installed` setup field is gone -- users must call install()
      -- explicitly. This is async and skips already-installed parsers.
      require("nvim-treesitter").install {
        "angular",
        "bash",
        "c",
        "diff",
        "eex",
        "elixir",
        "erlang",
        "git_config",
        "git_rebase",
        "gitattributes",
        "gitcommit",
        "gitignore",
        "gleam",
        "go",
        "gomod",
        "gosum",
        "gowork",
        "graphql",
        "hcl",
        "heex",
        "html",
        "http",
        "javascript",
        "jsdoc",
        "json",
        "json5",
        "jsonc",
        "lua",
        "luadoc",
        "luap",
        "markdown",
        "markdown_inline",
        "mermaid",
        "printf",
        "python",
        "query",
        "regex",
        "ruby",
        "rust",
        "sql",
        "terraform",
        "tmux",
        "toml",
        "tsx",
        "typescript",
        "vim",
        "vimdoc",
        "xml",
        "yaml",
      }

      local function is_supported_by_treesitter(buf)
        local ft = vim.bo[buf].filetype
        local lang = vim.treesitter.language.get_lang(ft)
        if not lang or lang == "" then
          return false
        end
        local ok, parser = pcall(vim.treesitter.get_parser, buf, lang, { error = false })
        return ok and parser ~= nil
      end

      -- Enable treesitter highlighting and indent on FileType
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("user_treesitter_start", { clear = true }),
        callback = function(ev)
          if not is_supported_by_treesitter(ev.buf) then
            vim.bo[ev.buf].autoindent = true
            vim.bo[ev.buf].indentexpr = ""
            return
          end
          pcall(vim.treesitter.start, ev.buf)
          vim.bo[ev.buf].autoindent = false
          vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("nvim-treesitter-textobjects").setup {
        select = {
          lookahead = true,
        },
        move = {
          set_jumps = true,
        },
      }

      local select = require "nvim-treesitter-textobjects.select"
      local swap = require "nvim-treesitter-textobjects.swap"
      local move = require "nvim-treesitter-textobjects.move"

      local select_maps = {
        af = "@function.outer",
        ["if"] = "@function.inner",
        am = "@class.outer",
        im = "@class.inner",
        ac = "@comment.outer",
        ic = "@comment.inner",
        aa = "@parameter.outer",
        ia = "@parameter.inner",
        ab = "@block.outer",
        ib = "@block.inner",
        ["as"] = "@statement.outer",
      }

      for lhs, query in pairs(select_maps) do
        vim.keymap.set({ "x", "o" }, lhs, function()
          select.select_textobject(query, "textobjects")
        end, { desc = "Treesitter textobject: " .. lhs })
      end

      vim.keymap.set("n", "<leader>>", function()
        swap.swap_next "@parameter.inner"
      end, { desc = "Swap next parameter" })

      vim.keymap.set("n", "<leader><", function()
        swap.swap_previous "@parameter.inner"
      end, { desc = "Swap previous parameter" })

      local modes = { "n", "x", "o" }

      vim.keymap.set(modes, "]m", function()
        move.goto_next_start("@function.outer", "textobjects")
      end, { desc = "Next function start" })
      vim.keymap.set(modes, "]]", function()
        move.goto_next_start("@class.outer", "textobjects")
      end, { desc = "Next class start" })
      vim.keymap.set(modes, "]M", function()
        move.goto_next_end("@function.outer", "textobjects")
      end, { desc = "Next function end" })
      vim.keymap.set(modes, "][", function()
        move.goto_next_end("@class.outer", "textobjects")
      end, { desc = "Next class end" })

      vim.keymap.set(modes, "[m", function()
        move.goto_previous_start("@function.outer", "textobjects")
      end, { desc = "Prev function start" })
      vim.keymap.set(modes, "[[", function()
        move.goto_previous_start("@class.outer", "textobjects")
      end, { desc = "Prev class start" })
      vim.keymap.set(modes, "[M", function()
        move.goto_previous_end("@function.outer", "textobjects")
      end, { desc = "Prev function end" })
      vim.keymap.set(modes, "[]", function()
        move.goto_previous_end("@class.outer", "textobjects")
      end, { desc = "Prev class end" })
    end,
  },
  {
    "RRethy/nvim-treesitter-endwise",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
  },
}
