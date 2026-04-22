return {
  { "neovim/nvim-lspconfig",
    config = function()
      local lspconfig = require('lspconfig')
      local configs = require('lspconfig.configs')
      local p_bin = "/home/jsonyoda/.config/nvim/bin/phpantom"

      -- Custom Server Registration (PHPantom)
      if not configs.phpantom then
        configs.phpantom = {
          default_config = {
            cmd = { p_bin, "--stdio" },
            filetypes = { "php" },
            root_dir = lspconfig.util.root_pattern(".phpantom.toml", "composer.json", ".git"),
          },
        }
      end

      lspconfig.phpantom.setup({
        capabilities = require('cmp_nvim_lsp').default_capabilities(),
        on_attach = function(_, bufnr)
          local opts = { buffer = bufnr }
          vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
          vim.keymap.set('n', 'K',  vim.lsp.buf.hover, opts)
        end
      })
    end
  },
  -- Completion Engine
  {
    "hrsh7th/nvim-cmp",
    dependencies = { "hrsh7th/cmp-nvim-lsp", "L3MON4D3/LuaSnip" },
    config = function()
      local cmp = require('cmp')
      cmp.setup({
        snippet = { expand = function(args) require('luasnip').lsp_expand(args.body) end },
        mapping = cmp.mapping.preset.insert({
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
          ['<Tab>'] = cmp.mapping.select_next_item(),
        }),
        sources = cmp.config.sources({{ name = 'nvim_lsp' }})
      })
    end
  },
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
}
