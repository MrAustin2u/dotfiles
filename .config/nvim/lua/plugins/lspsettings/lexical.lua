local M = {}


M.setup = function(opts)
  return {
          default_config = {
            filetypes = { "elixir", "eelixir", "heex" },
            cmd = { "$HOME/.local/share/nvim/mason/packages/lexical/libexec/lexical/bin/start_lexical.sh" },
            root_dir = function(fname)
              local path = opts.lspconfig.util.path
              local child_or_root_path = opts.root_pattern({ "mix.exs", ".git" })(fname)
              local maybe_umbrella_path = opts.root_pattern({ "mix.exs" })(
                vim.loop.fs_realpath(path.join({ child_or_root_path, ".." }))
              )

              local has_ancestral_mix_exs_path = vim.startswith(child_or_root_path,
                path.join({ maybe_umbrella_path, "apps" }))
              if maybe_umbrella_path and not has_ancestral_mix_exs_path then
                maybe_umbrella_path = nil
              end

              return maybe_umbrella_path or child_or_root_path or vim.loop.os_homedir()
            end,
            settings = {}
          },
  }
end

return M
