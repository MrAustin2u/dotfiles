-- Setup nvim-cmp.
local cmp_present, cmp = pcall(require, "cmp")
local luasnip_present, luasnip = pcall(require, "luasnip")
local lspkind_present, lspkind = pcall(require, "lspkind")

if not cmp_present or not lspkind_present or not luasnip_present then
  return false
end

if not cmp then
  return false
end

local has_words_before = function()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

local tmux_source = {
  name = "tmux",
  option = { all_panes = true },
}

local all_buffers_completion_source = {
  name = "buffer",
  option = {
    get_bufnrs = function()
      return vim.api.nvim_list_bufs()
    end,
  },
}

local M = {}

M.setup = function()
  require("cmp_git").setup({
    trigger_actions = {
      {
        debug_name = "git_commits",
        trigger_character = "$",
        action = function(sources, trigger_char, callback, params, _)
          return sources.git:get_commits(callback, params, trigger_char)
        end,
      },
      {
        debug_name = "github_issues_and_pr",
        trigger_character = "#",
        action = function(sources, trigger_char, callback, _, git_info)
          return sources.github:get_issues_and_prs(callback, git_info, trigger_char)
        end,
      },
      {
        debug_name = "github_mentions",
        trigger_character = "@",
        action = function(sources, trigger_char, callback, _, git_info)
          return sources.github:get_mentions(callback, git_info, trigger_char)
        end,
      },
    },
  })

  cmp.setup({
    window = {
      completion = cmp.config.window.bordered(),
      documentation = cmp.config.window.bordered(),
    },
    formatting = {
      fields = { "kind", "abbr", "menu" },
      format = lspkind.cmp_format({
        mode = "symbol_text",
        maxwidth = 50,
        ellipsis_char = "...",
        preset = "codicons",
        symbol_map = { Copilot = "" },
        before = function(entry, vim_item)
          local source = ({
            buffer = "[BUF]",
            cmdline = "[CMD]",
            emoji = "[EMJ]",
            git = "[GIT]",
            luasnip = "[SNP]",
            nvim_lsp = "[LSP]",
            nvim_lua = "[LUA]",
            path = "[PTH]",
            tmux = "[TMX]",
          })[entry.source.name]

          vim_item.menu = string.format("%s", source)

          return vim_item
        end,
      }),
    },
    snippet = {
      expand = function(args)
        luasnip.lsp_expand(args.body)
      end,
    },
    mapping = cmp.mapping.preset.insert({
      ["<C-p>"] = cmp.mapping.select_prev_item(),
      ["<C-n>"] = cmp.mapping.select_next_item(),
      ["<C-b>"] = cmp.mapping.scroll_docs(-4),
      ["<C-f>"] = cmp.mapping.scroll_docs(4),
      ---@diagnostic disable-next-line:missing-parameter
      ["<C-Space>"] = cmp.mapping.complete(),
      ["<C-e>"] = cmp.mapping.abort(),

      -- Accept currently selected item. Set `select` to `false` to only
      -- confirm explicitly selected items.
      ["<CR>"] = cmp.mapping.confirm({
        behavior = cmp.ConfirmBehavior.Replace,
        select = false,
      }),

      ["<Tab>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_next_item()
        elseif luasnip.expand_or_jumpable() then
          luasnip.expand_or_jump()
        elseif has_words_before() then
          cmp.complete()
        else
          fallback()
        end
      end, { "i", "s" }),

      ["<S-Tab>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_prev_item()
        elseif luasnip.jumpable(-1) then
          luasnip.jump(-1)
        else
          fallback()
        end
      end, { "i", "s" }),
      ["<C-k>"] = cmp.mapping(function(fallback)
        if luasnip.jumpable(1) then
          luasnip.jump(1)
        else
          fallback()
        end
      end, { "i" }),
      ["<C-j>"] = cmp.mapping(function(fallback)
        if luasnip.jumpable(-1) then
          luasnip.jump(-1)
        else
          fallback()
        end
      end, { "i" }),
    }),
    sources = cmp.config.sources({
      { name = "copilot" },
      { name = "luasnip" },
      { name = "nvim_lsp" },
      { name = "path" },
    }, {
      all_buffers_completion_source,
      { name = "emoji" },
      tmux_source,
    }),
    preselect = cmp.PreselectMode.None,
  })

  ---@diagnostic disable-next-line:undefined-field
  cmp.setup.filetype("lua", {
    sources = cmp.config.sources({
      { name = "nvim_lua" },
      { name = "nvim_lsp" },
      { name = "luasnip" },
      { name = "path" },
    }, {
      all_buffers_completion_source,
      tmux_source,
    }),
  })

  ---@diagnostic disable-next-line:undefined-field
  cmp.setup.filetype("gitcommit", {
    sources = cmp.config.sources({
      { name = "git" }, -- `cmp_git`
    }, {
      all_buffers_completion_source,
      tmux_source,
      { name = "emoji" },
    }),
  })

  cmp.setup.cmdline("/", {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
      { name = "buffer" },
    },
  })

  local function delay(fn, time)
    local timer = vim.loop.new_timer()
    timer:start(
      time,
      0,
      vim.schedule_wrap(function()
        fn()
        timer:stop()
      end)
    )
  end

  local cmd_mapping = cmp.mapping.preset.cmdline()
  local cmd_mapping_override = {
    ["<Tab>"] = {
      c = function()
        if vim.api.nvim_get_mode().mode == "c" then
          local text = vim.fn.getcmdline()
          local expanded = vim.fn.expandcmd(text)
          if expanded ~= text then
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-U>", true, true, true) .. expanded, "n", false)
            -- triggering right away won't work, need to wait a cycle
            delay(cmp.complete, 0)
          elseif cmp.visible() then
            cmp.select_next_item()
          else
            cmp.complete()
          end
        else
          if cmp.visible() then
            cmp.select_next_item()
          else
            cmp.complete()
          end
        end
      end,
    },
    ["<S-Tab>"] = {
      c = function()
        if vim.api.nvim_get_mode().mode == "c" then
          local text = vim.fn.getcmdline()
          local expanded = vim.fn.expandcmd(text)
          if expanded ~= text then
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-U>", true, true, true) .. expanded, "n", false)
            delay(cmp.complete, 0)
          elseif cmp.visible() then
            cmp.select_prev_item()
          else
            cmp.complete()
          end
        else
          if cmp.visible() then
            cmp.select_prev_item()
          else
            cmp.complete()
          end
        end
      end,
    },
  }

  for k, v in pairs(cmd_mapping_override) do
    cmd_mapping[k] = v
  end

  cmp.setup.cmdline(":", {
    mapping = cmd_mapping,
    sources = cmp.config.sources({
      { name = "cmdline" },
      { name = "path" },
    }),
  })

  luasnip.filetype_extend("typescriptreact", { "react-ts", "typescript", "html" })
  luasnip.filetype_extend("javascriptreact", { "react", "javascript", "html" })
  luasnip.filetype_extend("javascript", { "react" })

  require("luasnip.loaders.from_vscode").lazy_load()
end

return M
