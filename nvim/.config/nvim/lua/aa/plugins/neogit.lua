local neogit = require "neogit"

neogit.setup{
 integrations = { diffview = true },
 commit_popup = {
      kind = "popup",
  },
}
