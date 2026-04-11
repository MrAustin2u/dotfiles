-- Codeium AI completions, wired through blink.cmp via the native
-- codeium.blink module that ships with windsurf.nvim (renamed codeium.nvim).
-- Suggestions appear in the completion menu like any other source.
-- Inline virtual text is disabled so it doesn't double-up with menu items.
--
-- First-time auth: run `:Codeium Auth` after the plugin loads.
return {
  {
    "Exafunction/codeium.nvim",
    cmd = "Codeium",
    event = "InsertEnter",
    opts = {
      enable_chat = false,
      enable_cmp_source = false,
      virtual_text = {
        enabled = false,
      },
    },
  },
}
