vim.g.mapleader = " "
vim.g.maplocalleader = " "

local opt = vim.opt
opt.number = true
opt.termguicolors = true
opt.shiftwidth = 4
opt.tabstop = 4
opt.expandtab = true
opt.shell = "/usr/bin/fish"
opt.updatetime = 1000

-- Global Transparency Fix
vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })

vim.api.nvim_create_autocmd({ "FocusLost", "BufLeave" }, {
  pattern = "*",
  command = "silent! wall",
})
