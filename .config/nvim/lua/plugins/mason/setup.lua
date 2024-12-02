local UTILS = require "config.utils"

local lspconfig_present, lspconfig = pcall(require, "lspconfig")
local mason_lspconfig_present, mason_lspconfig = pcall(require, "mason-lspconfig")
local mason_present, mason = pcall(require, "mason")

local deps = {
  mason_present,
  mason_lspconfig_present,
  lspconfig_present,
}

if UTILS.contains(deps, false) then
  vim.notify "Failed to load dependencies in plugins/mason.lua"
  return
end

local M = {}

-- Sets up Mason and Mason LSP Config
M.setup = function(opts)
  local root_pattern = lspconfig.util.root_pattern

  ---@type MasonSettings
  mason.setup {}

  local mr = require "mason-registry"
  local function ensure_installed()
    for _, tool in ipairs(opts.ensure_installed) do
      local p = mr.get_package(tool)
      if not p:is_installed() then
        p:install()
      end
    end
  end

  if mr.refresh then
    mr.refresh(ensure_installed)
  else
    ensure_installed()
  end

  mason_lspconfig.setup {}
  mason_lspconfig.setup_handlers {
    function(server_name)
      lspconfig[server_name].setup {}
    end,

    -- elixir
    ["elixirls"] = function()
      opts.settings = {
        elixirLS = {
          fetchDeps = false,
          dialyzerEnabled = true,
          dialyzerFormat = "dialyxir_short",
          suggestSpecs = true,
        },
      }
      opts.root_dir = function(fname)
        local path = lspconfig.util.path
        local child_or_root_path = lspconfig.util.root_pattern { "mix.exs", ".git" }(fname)
        local maybe_umbrella_path =
          lspconfig.util.root_pattern { "mix.exs" }(vim.loop.fs_realpath(path.join { child_or_root_path, ".." }))

        local has_ancestral_mix_exs_path = vim.startswith(child_or_root_path, path.join { maybe_umbrella_path, "apps" })
        if maybe_umbrella_path and not has_ancestral_mix_exs_path then
          maybe_umbrella_path = nil
        end

        return maybe_umbrella_path or child_or_root_path or vim.loop.os_homedir()
      end

      lspconfig.elixirls.setup(opts)
    end,

    ["lexical"] = function()
      local overrides = require("plugins.lsp.configs.lexical").setup {
        lspconfig = lspconfig,
        root_pattern = root_pattern,
      }
      lspconfig.lexical.setup(overrides)
    end,

    -- go
    ["gopls"] = function()
      local overrides = require "plugins.lsp.configs.gopls"
      lspconfig.gopls.setup(overrides)
    end,

    -- json
    ["jsonls"] = function()
      local overrides = require "plugins.lsp.configs.jsonls"
      lspconfig.jsonls.setup(overrides)
    end,

    -- lua
    ["lua_ls"] = function()
      local overrides = require "plugins.lsp.configs.lua_ls"
      lspconfig.lua_ls.setup(overrides)
    end,

    -- tailwindcss
    ["tailwindcss"] = function()
      local overrides = require("plugins.lsp.configs.tailwindcss").setup { root_pattern = root_pattern }
      lspconfig.tailwindcss.setup(overrides)
    end,

    -- typescript
    ["vtsls"] = function()
      local overrides = require "plugins.lsp.configs.vtsls"
      lspconfig.vtsls.setup(overrides)
    end,

    -- yaml
    ["yamlls"] = function()
      local overrides = require "plugins.lsp.configs.yamlls"
      lspconfig.yamlls.setup(overrides)
    end,
  }
end

return M
