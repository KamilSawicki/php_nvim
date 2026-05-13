return {
  { "neovim/nvim-lspconfig",
    config = function()
      local bin_dir = vim.fn.stdpath('config') .. "/bin"
      local p_bin   = bin_dir .. "/phpantom"

      local function install_phpantom()
        local arch_map = { x64 = "x86_64", arm64 = "aarch64" }
        local os_map   = { Linux = "unknown-linux-gnu", OSX = "apple-darwin" }
        local arch = arch_map[jit.arch]
        local os   = os_map[jit.os]

        if not arch or not os then
          vim.notify(
            string.format("phpantom: unsupported platform %s/%s", jit.os, jit.arch),
            vim.log.levels.ERROR
          )
          return
        end

        vim.notify("phpantom: binary not found, downloading…", vim.log.levels.INFO)
        vim.fn.mkdir(bin_dir, "p")

        local asset = string.format("phpantom_lsp-%s-%s.tar.gz", arch, os)
        local cmd = string.format(
          'set -e; '
          .. 'VER=$(curl -sf https://api.github.com/repos/AJenbo/phpantom_lsp/releases/latest'
          .. ' | grep \'"tag_name"\' | sed \'s/.*"\\([^"]*\\)".*/\\1/\'); '
          .. 'curl -sL "https://github.com/AJenbo/phpantom_lsp/releases/download/$VER/%s"'
          .. ' | tar -xz -C "%s" phpantom_lsp; '
          .. 'mv "%s/phpantom_lsp" "%s"; '
          .. 'chmod +x "%s"',
          asset, bin_dir, bin_dir, p_bin, p_bin
        )

        vim.fn.jobstart({ "sh", "-c", cmd }, {
          on_exit = function(_, code)
            if code == 0 then
              vim.notify(
                "phpantom: installed successfully — restart Neovim to activate LSP",
                vim.log.levels.INFO
              )
            else
              vim.notify(
                "phpantom: installation failed (check internet connection)",
                vim.log.levels.ERROR
              )
            end
          end,
        })
      end

      if vim.fn.filereadable(p_bin) == 0 then
        install_phpantom()
      end

      vim.lsp.config('phpantom', {
        cmd          = { p_bin, "--stdio" },
        filetypes    = { "php" },
        root_markers = { ".phpantom.toml", "composer.json", ".git" },
      })
      vim.lsp.enable('phpantom')
    end,
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
          ['<CR>']  = cmp.mapping.confirm({ select = true }),
          ['<Tab>'] = cmp.mapping.select_next_item(),
        }),
        sources = cmp.config.sources({{ name = 'nvim_lsp' }}),
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "php", "lua", "javascript", "typescript", "html", "css",
          "json", "yaml", "bash", "markdown", "sql",
        },
        auto_install = true,
        highlight = { enable = true },
      })
    end,
  },
}
