vim.pack.add { "https://github.com/lukas-reineke/virt-column.nvim" }
require("virt-column").setup()
vim.api.nvim_set_hl(0, "VirtColumn", { fg = "#1e2030", nocombine = true })
