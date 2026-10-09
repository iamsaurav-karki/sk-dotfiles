local map = vim.keymap.set

map({ "n", "i", "v", "t" }, "<C-s>", "<cmd>write<cr>", { desc = "Save file" })
map("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search" })
map("v", "<", "<gv", { desc = "Indent left" })
map("v", ">", ">gv", { desc = "Indent right" })
map("v", "J", ":m '>+1<cr>gv=gv", { desc = "Move selection down" })
map("v", "K", ":m '<-2<cr>gv=gv", { desc = "Move selection up" })
map("n", "<leader>fp", function()
  Snacks.picker.projects()
end, { desc = "Projects" })
map("n", "<leader>gg", function()
  if vim.fn.executable("lazygit") == 0 then
    return vim.notify("lazygit is not installed; install it with your system package manager", vim.log.levels.WARN)
  end
  Snacks.lazygit()
end, { desc = "LazyGit" })
map({ "n", "t" }, "<C-`>", function()
  Snacks.terminal(nil, { win = { position = "bottom", height = 0.35 } })
end, { desc = "Terminal" })
