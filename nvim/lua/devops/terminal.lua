local M = {}

local commands = {
  { name = "AWS CLI", executable = "aws", args = { "help" } },
  { name = "Azure CLI", executable = "az", args = { "--help" } },
  { name = "Docker", executable = "docker", args = { "--help" } },
  { name = "GCP CLI", executable = "gcloud", args = { "help" } },
  { name = "GitHub CLI", executable = "gh", args = { "help" } },
  { name = "Helm", executable = "helm", args = { "help" } },
  { name = "Kubernetes", executable = "kubectl", args = { "help" } },
  { name = "OpenTofu", executable = "tofu", args = { "--help" } },
  { name = "Podman", executable = "podman", args = { "--help" } },
  { name = "Terraform", executable = "terraform", args = { "--help" } },
}

function M.pick()
  vim.ui.select(commands, {
    prompt = "DevOps CLI",
    format_item = function(item)
      local state = vim.fn.executable(item.executable) == 1 and "available" or "missing"
      return string.format("%-16s %s", item.name, state)
    end,
  }, function(item)
    if not item then
      return
    end
    if vim.fn.executable(item.executable) == 0 then
      return vim.notify(item.executable .. " is not installed", vim.log.levels.WARN)
    end
    Snacks.terminal(vim.list_extend({ item.executable }, item.args), {
      cwd = LazyVim.root(),
      win = { position = "bottom", height = 0.4 },
    })
  end)
end

return M
