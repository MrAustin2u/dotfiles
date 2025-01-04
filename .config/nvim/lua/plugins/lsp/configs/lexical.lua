local M = {}

M.setup = function(opts)
  return {
    default_config = {
      filetypes = { "elixir", "eelixir", "heex" },
      cmd = { "$HOME/.local/share/nvim/mason/packages/lexical/libexec/lexical/bin/start_lexical.sh" },
      settings = {},
    },
  }
end

return M
