local utils = require "config.filetypes.utils"

vim.filetype.add {
  filename = {
    [".envrc"] = "bash",
    [".eslintrc"] = "json",
    [".prettierrc"] = "json",
    [".babelrc"] = "json",
    [".codespellrc"] = "ini",
    [".zinitrc"] = "zsh",
  },
  extension = {
    yrl = "erlang",
    yaml = utils.yaml_detect,
    yml = utils.yaml_detect,
    plist = "xml",
  },
}
