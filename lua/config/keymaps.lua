local key = vim.keymap

-- Auto-show Diagnostics on Hover
vim.api.nvim_create_autocmd("CursorHold", {
  callback = function() 
    vim.diagnostic.open_float(nil, { focusable = false, scope = "cursor", border = "rounded" }) 
  end
})
