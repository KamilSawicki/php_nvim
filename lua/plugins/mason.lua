return {
  {
    "williamboman/mason.nvim",
    build = ":MasonUpdate",
    config = function()
      require("mason").setup()
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim", "neovim/nvim-lspconfig" },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "html", "cssls", "ts_ls", "vue_ls", "lua_ls", "jsonls",
        },
        automatic_installation = true,
      })

      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      local on_attach    = function(_, bufnr)
        local opts = { buffer = bufnr }
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
        vim.keymap.set("n", "K",  vim.lsp.buf.hover,      opts)
      end

      -- Global defaults applied to all servers (including phpantom)
      vim.lsp.config('*', { capabilities = capabilities, on_attach = on_attach })

      -- Vue: ograniczamy do .vue żeby nie kolidował z ts_ls
      vim.lsp.config('vue_ls', { filetypes = { "vue" } })

      vim.lsp.enable({ "html", "cssls", "ts_ls", "lua_ls", "jsonls", "vue_ls" })
    end,
  },
}
