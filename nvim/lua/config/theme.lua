local M = {}

M.themes = {
  { label = "Tokyo Night", name = "tokyonight-night" },
  { label = "Catppuccin", name = "catppuccin-mocha" },
  { label = "Kanagawa", name = "kanagawa-wave" },
  { label = "Rose Pine", name = "rose-pine" },
  { label = "Gruvbox Material", name = "gruvbox-material" },
}

local state_file = vim.fn.stdpath("state") .. "/theme"

function M.get()
  local saved
  if vim.uv.fs_stat(state_file) then
    saved = vim.fn.readfile(state_file)[1]
  end
  for _, theme in ipairs(M.themes) do
    if theme.name == saved then
      return saved
    end
  end
  return M.themes[1].name
end

function M.select()
  vim.ui.select(M.themes, {
    prompt = "Select theme",
    format_item = function(theme)
      return theme.label
    end,
  }, function(theme)
    if not theme then
      return
    end
    local ok, err = pcall(vim.cmd.colorscheme, theme.name)
    if not ok then
      return vim.notify(err, vim.log.levels.ERROR)
    end
    vim.fn.mkdir(vim.fn.fnamemodify(state_file, ":h"), "p")
    vim.fn.writefile({ theme.name }, state_file)
    vim.notify(theme.label .. " selected")
  end)
end

return M
