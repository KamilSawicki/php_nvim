return {
  'nvim-telescope/telescope.nvim',
  branch = '0.1.x',
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = function()
    require('telescope').setup({
      defaults = {
        preview = { treesitter = false }, -- Fix for ft_to_lang nil error
      }
    })
    local builtin = require('telescope.builtin')
    
    -- Search Everywhere (Double Space)
    vim.keymap.set('n', '<leader><leader>', builtin.find_files, { desc = "Search Everywhere (Files)" })
    
vim.keymap.set('n', '<leader>g', builtin.live_grep, { desc = "Live Grep (Text)" })
    vim.keymap.set('n', '<leader>s', builtin.lsp_document_symbols, { desc = "Search Symbols (Classes/Methods)" })
  end
}
