return {
  {
    "folke/snacks.nvim",
    keys = {
      {
        "<leader>do",
        function()
          require("devops.terminal").pick()
        end,
        desc = "DevOps CLI",
      },
      {
        "<leader>dk",
        function()
          Snacks.terminal({ "kubectl", "help" }, { cwd = LazyVim.root() })
        end,
        desc = "Kubernetes CLI",
      },
      {
        "<leader>dt",
        function()
          local cli = vim.fn.executable("tofu") == 1 and "tofu" or "terraform"
          Snacks.terminal({ cli, "--help" }, { cwd = LazyVim.root() })
        end,
        desc = "Terraform/OpenTofu CLI",
      },
    },
  },
}
