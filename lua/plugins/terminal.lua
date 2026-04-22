return {
  'akinsho/toggleterm.nvim',
  version = "*",
  config = function()
    require("toggleterm").setup({
      size = 15,
      open_mapping = [[<A-t>]],
      direction = 'horizontal',
      shell = "/usr/bin/fish",
    })
    
    function _G.set_terminal_keymaps()
      local opts = {buffer = 0}
      vim.keymap.set('t', '<A-t>', [[<Cmd>ToggleTerm<CR>]], opts)
    end
    
    vim.cmd('autocmd! TermOpen term://* lua set_terminal_keymaps()')
  end
}
