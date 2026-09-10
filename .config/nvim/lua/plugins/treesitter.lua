-- Better syntax highlighting (and more)
---@type string[]
local parsers = {
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

---@type LazySpec[]
---@diagnostic disable: missing-fields
return {
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = function()
      require("nvim-treesitter").update(parsers):wait(300000)
    end,
    init = function()
      -- `tmux` is not in the main branch parser registry, so register it by hand.
      -- Must happen on `User TSUpdate`: install() re-requires nvim-treesitter.parsers
      -- before validating the language list, so a plain assignment gets wiped.
      -- The repo ships only grammar.js, so the parser is generated from it (needs
      -- the tree-sitter CLI) and the queries come from the grammar's own repo.
      vim.api.nvim_create_autocmd("User", {
        pattern = "TSUpdate",
        group = vim.api.nvim_create_augroup("user_treesitter_custom_parsers", { clear = true }),
        callback = function()
          require("nvim-treesitter.parsers").tmux = {
            install_info = {
              url = "https://github.com/Freed-Wu/tree-sitter-tmux",
              revision = "71c78208a42bbe85309a9276317c1f7cde2dc070",
              generate = true,
              generate_from_json = false,
              queries = "queries",
            },
            tier = 3,
          }
        end,
      })
    end,
    config = function()
      -- Ensure parsers are installed. On the main branch rewrite the old
      -- `ensure_installed` setup field is gone -- users must call install()
      -- explicitly. This is async and skips already-installed parsers.
      require("nvim-treesitter").install(parsers)

      local function should_use_treesitter(buf)
        -- snacks.nvim marks oversized buffers, where parsing is too slow
        if vim.b[buf].bigfile then
          return false
        end

        local ft = vim.bo[buf].filetype
        local lang = vim.treesitter.language.get_lang(ft)
        if not lang or lang == "" then
          return false
        end

        local ok, parser = pcall(vim.treesitter.get_parser, buf, lang, { error = false })
        return ok and parser ~= nil
      end

      -- Enable treesitter highlighting and indent on FileType. Folding is set
      -- up separately, in config/autocmds.lua.
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("user_treesitter_start", { clear = true }),
        callback = function(ev)
          if not should_use_treesitter(ev.buf) then
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
    "nvim-treesitter/nvim-treesitter-context",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    main = "treesitter-context",
    opts = {
      enable = true,
      max_lines = 3,
      trim_scope = "outer",
      mode = "cursor",
    },
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
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
        ac = "@class.outer",
        ic = "@class.inner",
        am = "@class.outer",
        im = "@class.inner",
        ia = "@parameter.inner",
        aa = "@parameter.outer",
        ib = "@block.inner",
        ab = "@block.outer",
        ik = "@comment.inner",
        ak = "@comment.outer",
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
      end, { desc = "Next method/fun" })
      vim.keymap.set(modes, "]k", function()
        move.goto_next_start("@class.outer", "textobjects")
      end, { desc = "Next class start" })
      vim.keymap.set(modes, "]o", function()
        move.goto_next_start({ "@loop.inner", "@loop.outer" }, "textobjects")
      end, { desc = "Next loop" })
      vim.keymap.set(modes, "]S", function()
        move.goto_next_start("@local.scope", "locals")
      end, { desc = "Next scope" })
      vim.keymap.set(modes, "]z", function()
        move.goto_next_start("@fold", "folds")
      end, { desc = "Next fold" })

      vim.keymap.set(modes, "[m", function()
        move.goto_previous_start("@function.outer", "textobjects")
      end, { desc = "Prev method/fun" })
      vim.keymap.set(modes, "[k", function()
        move.goto_previous_start("@class.outer", "textobjects")
      end, { desc = "Prev class start" })
      vim.keymap.set(modes, "[o", function()
        move.goto_previous_start({ "@loop.inner", "@loop.outer" }, "textobjects")
      end, { desc = "Prev loop" })
      vim.keymap.set(modes, "[S", function()
        move.goto_previous_start("@local.scope", "locals")
      end, { desc = "Prev scope" })
      vim.keymap.set(modes, "[z", function()
        move.goto_previous_start("@fold", "folds")
      end, { desc = "Prev fold" })

      vim.keymap.set(modes, "]M", function()
        move.goto_next_end("@function.outer", "textobjects")
      end, { desc = "Next method/fun end" })
      vim.keymap.set(modes, "]K", function()
        move.goto_next_end("@class.outer", "textobjects")
      end, { desc = "Next class/module end" })

      vim.keymap.set(modes, "[M", function()
        move.goto_previous_end("@function.outer", "textobjects")
      end, { desc = "Prev method/fun end" })
      vim.keymap.set(modes, "[K", function()
        move.goto_previous_end("@class.outer", "textobjects")
      end, { desc = "Prev class/module end" })
    end,
  },
  {
    "RRethy/nvim-treesitter-endwise",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
  },
}
