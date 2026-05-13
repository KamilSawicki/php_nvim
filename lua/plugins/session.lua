return {
  {
    "folke/persistence.nvim",
    lazy = false,
    config = function()
      local persistence = require("persistence")

      persistence.setup({
        dir     = vim.fn.stdpath("state") .. "/sessions/",
        options = { "buffers", "curdir", "tabpages", "winsize" },
      })

      local function project_path()
        local p = vim.fn.getcwd() .. "/.nvim/session.vim"
        return vim.fn.isdirectory(vim.fn.getcwd() .. "/.nvim") == 1 and p or nil
      end

      local function save_session()
        pcall(vim.cmd, "Neotree close")
        local p = project_path()
        if p then
          vim.cmd("mksession! " .. vim.fn.fnameescape(p))
        else
          persistence.save()
        end
      end

      -- Auto-save on exit
      vim.api.nvim_create_autocmd("VimLeavePre", { callback = save_session })

      -- Auto-load on start (only when Neovim opened without file args)
      vim.api.nvim_create_autocmd("VimEnter", {
        nested = true,
        callback = function()
          if vim.fn.argc() > 0 then return end
          local p = project_path()
          if p and vim.fn.filereadable(p) == 1 then
            vim.cmd("source " .. vim.fn.fnameescape(p))
          else
            persistence.load()
          end
        end,
      })

      local map = function(k, v, desc)
        vim.keymap.set("n", k, v, { desc = desc })
      end

      map("<leader>ss", function()
        save_session()
        vim.notify(project_path() and "Sesja zapisana: .nvim/session.vim" or "Sesja zapisana (globalnie)", vim.log.levels.INFO)
      end, "Session: Zapisz")

      map("<leader>sl", function()
        local p = project_path()
        if p and vim.fn.filereadable(p) == 1 then
          vim.cmd("source " .. vim.fn.fnameescape(p))
        else
          persistence.load()
        end
      end, "Session: Wczytaj")

      map("<leader>sx", persistence.stop, "Session: Wyłącz autozapis")
    end,
  },
}
