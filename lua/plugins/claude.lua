return {
  {
    "folke/snacks.nvim",
    lazy = true,
  },
  {
    "coder/claudecode.nvim",
    dependencies = { "folke/snacks.nvim" },
    opts = {
      split_side             = "right",
      split_width_percentage = 0.35,
      terminal_cmd           = "claude",
    },
    keys = {
      { "<leader>cc", "<cmd>ClaudeCode<cr>",     desc = "Claude: toggle" },
      { "<leader>cs", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Claude: send selection" },
      { "<leader>ca", "<cmd>ClaudeCodeAdd %<cr>", desc = "Claude: add current file" },
    },
  },
}
