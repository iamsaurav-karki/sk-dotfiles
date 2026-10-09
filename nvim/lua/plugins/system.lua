return {
  {
    "LazyVim/LazyVim",
    init = function()
      vim.api.nvim_create_user_command("DevOpsHealth", function()
        require("devops.health").show()
      end, { desc = "Check IDE and external tool availability" })
    end,
    keys = {
      { "<leader>ch", function() require("devops.health").show() end, desc = "DevOps health" },
    },
  },
}
