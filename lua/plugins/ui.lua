return {
  -- Colorscheme
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      require("catppuccin").setup({ transparent_background = true })
      vim.cmd.colorscheme "catppuccin-mocha"
    end
  },
  -- Tabline / Bufferline
  {
    'akinsho/bufferline.nvim',
    dependencies = 'nvim-tree/nvim-web-devicons',
    config = function()
      require("bufferline").setup({ options = { separator_style = "thin" } })
      vim.keymap.set("n", "<S-l>", ":BufferLineCycleNext<CR>", { desc = "Next Tab" })
      vim.keymap.set("n", "<S-h>", ":BufferLineCyclePrev<CR>", { desc = "Prev Tab" })
      vim.keymap.set("n", "<A-w>", ":bdelete<CR>", { desc = "Close Buffer" })
    end
  },
  -- File Explorer
  { 
    "nvim-neo-tree/neo-tree.nvim", 
    branch = "v3.x", 
    dependencies = { "nvim-lua/plenary.nvim", "nvim-tree/nvim-web-devicons", "MunifTanjim/nui.nvim" } 
  },
}
