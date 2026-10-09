vim.filetype.add({
  filename = {
    ["Jenkinsfile"] = "groovy",
    ["Containerfile"] = "dockerfile",
    ["Tiltfile"] = "starlark",
    ["Vagrantfile"] = "ruby",
    [".gitlab-ci.yml"] = "yaml.gitlab",
  },
  extension = {
    service = "systemd",
    socket = "systemd",
    target = "systemd",
    timer = "systemd",
  },
  pattern = {
    [".*/%.github/workflows/.*%.ya?ml"] = "yaml.github",
    [".*/templates/.*%.ya?ml"] = "helm",
    [".*/%.ssh/config.*"] = "sshconfig",
    [".*/nginx/.*%.conf"] = "nginx",
    ["Dockerfile%..*"] = "dockerfile",
  },
})

vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight copied text",
  group = vim.api.nvim_create_augroup("devops-highlight-yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank({ timeout = 180 })
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "markdown.mdx" },
  desc = "Use readable wrapping for Markdown prose",
  group = vim.api.nvim_create_augroup("devops-markdown", { clear = true }),
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.breakindent = true
    vim.opt_local.spell = false
  end,
})
