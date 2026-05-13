return {
  -- Colorschemes
  { "folke/tokyonight.nvim",         lazy = true },
  { "rose-pine/neovim",              lazy = true, name = "rose-pine" },
  { "rebelot/kanagawa.nvim",         lazy = true },
  { "catppuccin/nvim",               lazy = true, name = "catppuccin" },
  { "ellisonleao/gruvbox.nvim",      lazy = true },
  { "sainnhe/everforest",            lazy = true },
  -- Theme selector
  {
    "zaldih/themery.nvim",
    config = function()
      require("themery").setup({
        themes = {
          { name = "Tokyo Night",        colorscheme = "tokyonight" },
          { name = "Tokyo Night Storm",  colorscheme = "tokyonight-storm" },
          { name = "Tokyo Night Day",    colorscheme = "tokyonight-day" },
          {
            name = "Rose Pine",
            colorscheme = "rose-pine",
            before = [[ require("rose-pine").setup({ styles = { transparency = false } }) ]],
          },
          {
            name = "Rose Pine Moon",
            colorscheme = "rose-pine-moon",
            before = [[ require("rose-pine").setup({ styles = { transparency = false } }) ]],
          },
          {
            name = "Rose Pine Dawn",
            colorscheme = "rose-pine-dawn",
            before = [[ require("rose-pine").setup({ styles = { transparency = false } }) ]],
          },
          {
            name = "Transparent Dark (Rose Pine Moon)",
            colorscheme = "rose-pine-moon",
            before = [[
              require("rose-pine").setup({ styles = { transparency = true } })
            ]],
          },
          {
            name = "Transparent Light (Rose Pine Dawn)",
            colorscheme = "rose-pine-dawn",
            before = [[
              require("rose-pine").setup({ styles = { transparency = true } })
            ]],
          },
          { name = "Kanagawa",           colorscheme = "kanagawa" },
          { name = "Kanagawa Wave",      colorscheme = "kanagawa-wave" },
          { name = "Kanagawa Dragon",    colorscheme = "kanagawa-dragon" },
          { name = "Catppuccin Mocha",   colorscheme = "catppuccin-mocha" },
          { name = "Catppuccin Macchiato", colorscheme = "catppuccin-macchiato" },
          { name = "Catppuccin Frappe",  colorscheme = "catppuccin-frappe" },
          { name = "Catppuccin Latte",   colorscheme = "catppuccin-latte" },
          { name = "Gruvbox Dark",       colorscheme = "gruvbox" },
          { name = "Everforest",         colorscheme = "everforest" },
        },
        livePreview = true,
      })
      vim.keymap.set("n", "<leader>th", "<cmd>Themery<CR>", { desc = "Theme Selector" })
    end,
  },
  -- Keybind helper
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
      local wk = require("which-key")
      wk.setup()
      wk.add({
        -- Explorer
        { "<leader>e",      desc = "Toggle Explorer" },
        { "<leader>o",      desc = "Focus Explorer" },
        -- Telescope
        { "<leader><leader>", desc = "Find Files" },
        { "<leader>g",      desc = "Live Grep" },
        { "<leader>s",      desc = "Search Symbols" },
        -- Buffers
        { "<S-l>",          desc = "Next Buffer" },
        { "<S-h>",          desc = "Prev Buffer" },
        { "<leader>bc",     desc = "Close Buffer" },
        -- Terminal
        { "<A-t>",          desc = "Toggle Terminal" },
        -- Theme
        { "<leader>th",     desc = "Theme Selector" },
        -- LSP (buffer-local, shown when LSP is active)
        { "gd",             desc = "Go to Definition" },
        { "K",              desc = "Hover Docs" },
      })
    end,
  },
  -- Safe buffer remove
  { "echasnovski/mini.bufremove", version = "*", config = true },
  -- Tabline / Bufferline
  {
    'akinsho/bufferline.nvim',
    dependencies = 'nvim-tree/nvim-web-devicons',
    config = function()
      require("bufferline").setup({ options = { separator_style = "thin" } })
      vim.keymap.set("n", "<S-l>", ":BufferLineCycleNext<CR>", { desc = "Next Buffer" })
      vim.keymap.set("n", "<S-h>", ":BufferLineCyclePrev<CR>", { desc = "Prev Buffer" })
      vim.keymap.set("n", "<leader>bc", function()
        require("mini.bufremove").delete()
      end, { desc = "Close Buffer" })
    end
  },
  -- File Explorer
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
      { "s1n7ax/nvim-window-picker", version = "2.*", config = function()
          require("window-picker").setup({ filter_rules = { bo = { filetype = { "neo-tree" } } } })
        end
      },
    },
    config = function()
      require("neo-tree").setup({
        close_if_last_window = true,
        filesystem = {
          follow_current_file = { enabled = true },
          hijack_netrw_behavior = "open_current",
        },
        window = {
          width = 30,
          mappings = {
            ["<cr>"] = "open_with_window_picker",
          },
        },
        open_files_do_not_replace_types = { "terminal", "trouble", "qf" },
      })
      vim.keymap.set("n", "<leader>e", "<cmd>Neotree toggle<CR>",        { desc = "Toggle Explorer" })
      vim.keymap.set("n", "<leader>o", "<cmd>Neotree focus<CR>",         { desc = "Focus Explorer" })
    end,
  },
}
