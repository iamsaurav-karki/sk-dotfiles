return {
  {
    "folke/snacks.nvim",
    init = function()
      require("devops.ai").setup()
    end,
    keys = {
      { "<leader>aa", function() require("devops.ai").select("vertical", false) end, desc = "Select/open agent" },
      { "<leader>aA", function() require("devops.ai").select("float", false) end, desc = "Agent in float" },
      { "<leader>an", function() require("devops.ai").select("vertical", true) end, desc = "New agent session" },
      { "<leader>as", function() require("devops.ai").sessions() end, desc = "Agent sessions" },
      { "<leader>af", function() require("devops.ai").send_file() end, desc = "Send file context" },
      { "<leader>av", function() require("devops.ai").send_selection() end, mode = "v", desc = "Send selection" },
      { "<leader>ad", function() require("devops.ai").send_diagnostics() end, desc = "Send diagnostics" },
      { "<leader>ag", function() require("devops.ai").send_diff(false) end, desc = "Send Git diff" },
      { "<leader>ar", function() require("devops.ai").send_diff(true) end, desc = "Review Git diff" },
    },
  },
}
