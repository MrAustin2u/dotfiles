local M = {}

M.config = function(lspconfig)
  return {
    filetypes = { "elixir", "eelixir", "heex" },
    cmd = { "/Users/aaustin/.local/share/nvim/mason/bin/lexical", "server" },
    root_dir = function(fname)
      local path = lspconfig.util.path
      local child_or_root_path = lspconfig.util.root_pattern { "mix.exs", ".git" }(fname)
      local maybe_umbrella_path =
        lspconfig.util.root_pattern { "mix.exs" }(vim.loop.fs_realpath(path.join { child_or_root_path, ".." }))

      local has_ancestral_mix_exs_path = vim.startswith(child_or_root_path, path.join { maybe_umbrella_path, "apps" })
      if maybe_umbrella_path and not has_ancestral_mix_exs_path then
        maybe_umbrella_path = nil
      end

      return maybe_umbrella_path or child_or_root_path or vim.loop.os_homedir()
    end,
    settings = {},
  }
end

return M
