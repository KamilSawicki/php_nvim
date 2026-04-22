local key = vim.keymap

-- File Explorer (Neo-tree)
key.set('n', '<C-n>', ':Neotree toggle<CR>', { silent = true, desc = "Toggle File Explorer" })

-- Auto-show Diagnostics on Hover
vim.api.nvim_create_autocmd("CursorHold", {
  callback = function() 
    vim.diagnostic.open_float(nil, { focusable = false, scope = "cursor", border = "rounded" }) 
  end
})
