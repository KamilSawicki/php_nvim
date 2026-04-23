return {
  {
    "kristijanhusak/vim-dadbod-ui",
    dependencies = {
      "tpope/vim-dadbod",
      "kristijanhusak/vim-dadbod-completion",
    },
    cmd = { "DBUI", "DBUIToggle", "DBUIAddConnection", "DBUIFindBuffer" },
    init = function()
      vim.g.db_ui_use_nerd_fonts = 1

      local bin_dir = vim.fn.stdpath("config") .. "/bin"
      local psql_bin = bin_dir .. "/psql"

      local function install_psql()
        local arch_map = { x64 = "x86_64", arm64 = "aarch64" }
        local os_map   = { Linux = "linux-static", OSX = "macos" }
        local arch = arch_map[jit.arch]
        local os   = os_map[jit.os]

        if not arch or not os then
          vim.notify(
            string.format("psql: unsupported platform %s/%s", jit.os, jit.arch),
            vim.log.levels.ERROR
          )
          return
        end

        vim.notify("psql: binary not found, downloading…", vim.log.levels.INFO)
        vim.fn.mkdir(bin_dir, "p")

        -- Downloads the standalone psql binary from https://github.com/IxDay/psql
        local asset = string.format("psql-%s-%s.tar.gz", arch, os)
        local tmp_archive = bin_dir .. "/" .. asset
        local cmd = string.format(
          'VER=$(curl -sf https://api.github.com/repos/IxDay/psql/releases/latest'
          .. ' | grep -oP \'"tag_name": "\\K[^"]+\''
          .. ') && curl -sL "https://github.com/IxDay/psql/releases/download/$VER/%s"'
          .. ' -o "%s" && tar -xzf "%s" -C "%s" psql && rm "%s" && chmod +x "%s"',
          asset, tmp_archive, tmp_archive, bin_dir, tmp_archive, psql_bin
        )

        vim.fn.jobstart({ "sh", "-c", cmd }, {
          on_exit = function(_, code)
            if code == 0 then
              vim.notify("psql: installed successfully", vim.log.levels.INFO)
            else
              vim.notify("psql: installation failed (check internet connection)", vim.log.levels.ERROR)
            end
          end,
        })
      end

      -- Prepend bin_dir to PATH so dadbod finds our psql
      if not vim.env.PATH:find(bin_dir, 1, true) then
        vim.env.PATH = bin_dir .. ":" .. vim.env.PATH
      end

      if vim.fn.filereadable(psql_bin) == 0 then
        install_psql()
      end
    end,
    keys = {
      { "<leader>db", "<cmd>DBUIToggle<CR>", desc = "Toggle DB UI" },
    },
  },
}
