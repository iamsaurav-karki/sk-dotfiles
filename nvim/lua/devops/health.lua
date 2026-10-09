local M = {}

local groups = {
  core = { "nvim", "git", "curl", "rg", "fd", "fzf", "wl-copy" },
  git = { "lazygit", "gh" },
  languages = { "node", "python3", "go", "cargo", "terraform", "ansible" },
  cloud = { "docker", "podman", "kubectl", "helm", "aws", "az", "gcloud" },
  agents = { "opencode", "claude", "codex", "gemini", "aider" },
}

function M.lines()
  local lines = { "Neovim IDE health", string.rep("=", 17) }
  for group, executables in pairs(groups) do
    lines[#lines + 1] = ""
    lines[#lines + 1] = group:upper()
    for _, executable in ipairs(executables) do
      local path = vim.fn.exepath(executable)
      lines[#lines + 1] = string.format("  %s %-12s %s", path ~= "" and "OK" or "--", executable, path ~= "" and path or "missing")
    end
  end
  lines[#lines + 1] = ""
  lines[#lines + 1] = "Run :checkhealth, :LazyHealth, :Mason, and :ConformInfo for plugin-specific details."
  return lines
end

function M.show()
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].filetype = "checkhealth"
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, M.lines())
  vim.bo[buf].modifiable = false
  vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    border = "rounded",
    title = " DevOps Health ",
    title_pos = "center",
    width = math.min(86, vim.o.columns - 4),
    height = math.min(#M.lines() + 1, vim.o.lines - 4),
    row = 1,
    col = math.max(1, math.floor((vim.o.columns - math.min(86, vim.o.columns - 4)) / 2)),
    style = "minimal",
  })
end

function M.check()
  vim.health.start("Neovim IDE external tools")
  for group, executables in pairs(groups) do
    vim.health.info(group)
    for _, executable in ipairs(executables) do
      local path = vim.fn.exepath(executable)
      if path ~= "" then
        vim.health.ok(executable .. ": " .. path)
      elseif group == "core" then
        vim.health.error(executable .. " is missing")
      else
        vim.health.warn(executable .. " is missing (optional)")
      end
    end
  end
end

return M
