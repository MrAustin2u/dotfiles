-- mermaid diagrams preview
---@type LazySpec
return {
  "kevalin/mermaid.nvim",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  ft = "mermaid",
  config = function()
    require("mermaid").setup {
      preview = {
        renderer = "beautiful-mermaid",
        theme = "default", -- Theme name (renderer-specific)
      },
    }

    vim.api.nvim_create_autocmd("FileType", {
      pattern = "mermaid",
      callback = function()
        local buf = vim.api.nvim_get_current_buf()
        -- <leader>mp is the global conform format map; a buffer-local one here
        -- made formatting unreachable inside mermaid files.
        vim.keymap.set("n", "<leader>mv", "<cmd>MermaidPreview<CR>", { buffer = buf, desc = "Mermaid Preview" })
        vim.keymap.set("n", "<leader>mf", "<cmd>MermaidFormat<CR>", { buffer = buf, desc = "Mermaid Format" })
      end,
    })
  end,
}
