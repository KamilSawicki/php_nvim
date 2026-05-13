return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
      "jay-babu/mason-nvim-dap.nvim",
      "williamboman/mason.nvim",
    },
    config = function()
      local dap    = require("dap")
      local dapui  = require("dapui")

      -- Breakpoint line highlight
      local function set_dap_highlights()
        if vim.o.background == "dark" then
          vim.api.nvim_set_hl(0, "DapBreakpointLine", { bg = "#4a1010" })
          vim.api.nvim_set_hl(0, "DapStoppedLine",    { bg = "#1a3a1a" })
        else
          vim.api.nvim_set_hl(0, "DapBreakpointLine", { bg = "#ffd7d7" })
          vim.api.nvim_set_hl(0, "DapStoppedLine",    { bg = "#d7f5d7" })
        end
      end

      set_dap_highlights()
      vim.api.nvim_create_autocmd("ColorScheme", { callback = set_dap_highlights })
      vim.fn.sign_define("DapBreakpoint", {
        text   = "●",
        texthl = "DiagnosticError",
        linehl = "DapBreakpointLine",
        numhl  = "DiagnosticError",
      })
      vim.fn.sign_define("DapStopped", {
        text   = "▶",
        texthl = "DiagnosticOk",
        linehl = "DapStoppedLine",
        numhl  = "DiagnosticOk",
      })

      -- PHP adapter (php-debug-adapter installed via Mason)
      dap.adapters.php = {
        type = "executable",
        command = "php-debug-adapter",
      }

      dap.configurations.php = {
        {
          type    = "php",
          request = "launch",
          name    = "Xdebug: Listen (port 9001)",
          port    = 9001,
          pathMappings = (function()
            local project = require("config.project")
            local remote  = project.get("dap", "remote")
            local local_  = project.get("dap", "local")
            if remote and remote ~= "" then
              return { [remote] = (local_ ~= "" and local_ or vim.fn.getcwd()) }
            end
            return {}
          end)(),
        },
      }

      -- DAP UI – otwiera/zamyka automatycznie przy starcie/końcu sesji
      dapui.setup()
      dap.listeners.after.event_initialized["dapui"] = function() dapui.open() end
      dap.listeners.before.event_terminated["dapui"] = function() dapui.close() end
      dap.listeners.before.event_exited["dapui"]     = function() dapui.close() end

      -- Skróty klawiszowe
      local map = function(k, v, desc)
        vim.keymap.set("n", k, v, { desc = desc })
      end

      map("<F5>",       dap.continue,          "DAP: Continue / Start")
      map("<F10>",      dap.step_over,          "DAP: Step over")
      map("<F11>",      dap.step_into,          "DAP: Step into")
      map("<F12>",      dap.step_out,           "DAP: Step out")
      map("<leader>db", dap.toggle_breakpoint,  "DAP: Toggle breakpoint")
      map("<leader>dB", function()
        dap.set_breakpoint(vim.fn.input("Condition: "))
      end, "DAP: Conditional breakpoint")
      map("<leader>dr", dap.repl.open,          "DAP: Open REPL")
      map("<leader>du", dapui.toggle,           "DAP: Toggle UI")
      map("<leader>dx", dap.terminate,          "DAP: Terminate")
    end,
  },
  {
    "jay-babu/mason-nvim-dap.nvim",
    dependencies = { "williamboman/mason.nvim", "mfussenegger/nvim-dap" },
    config = function()
      require("mason-nvim-dap").setup({
        ensure_installed        = { "php" },
        automatic_installation  = true,
      })
    end,
  },
}
