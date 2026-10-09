local M = {}

local defaults = {
  opencode = { label = "OpenCode", command = { "opencode" } },
  claude = { label = "Claude Code", command = { "claude" } },
  codex = { label = "Codex CLI", command = { "codex" } },
  gemini = { label = "Gemini CLI", command = { "gemini" } },
  aider = { label = "Aider", command = { "aider" } },
}

local state = { current_agent = "opencode", current_session = nil, sessions = {} }

local function agents()
  return vim.tbl_deep_extend("force", defaults, vim.g.devops_ai_agents or {})
end

local function root()
  return (LazyVim and LazyVim.root()) or vim.uv.cwd()
end

local function show(session, layout)
  if layout == "float" then
    local width = math.floor(vim.o.columns * 0.88)
    local height = math.floor(vim.o.lines * 0.82)
    local win = vim.api.nvim_open_win(session.buf, true, {
      relative = "editor",
      border = "rounded",
      title = " AI: " .. session.label .. " ",
      title_pos = "center",
      row = math.floor((vim.o.lines - height) / 2 - 1),
      col = math.floor((vim.o.columns - width) / 2),
      width = width,
      height = height,
      style = "minimal",
    })
    vim.wo[win].winblend = 0
  elseif layout == "vertical" then
    vim.cmd("botright vsplit")
    vim.api.nvim_win_set_buf(0, session.buf)
    vim.cmd("vertical resize " .. math.max(48, math.floor(vim.o.columns * 0.4)))
  else
    vim.cmd("botright split")
    vim.api.nvim_win_set_buf(0, session.buf)
    vim.cmd("resize " .. math.max(12, math.floor(vim.o.lines * 0.35)))
  end
  vim.cmd("startinsert")
end

function M.open(name, layout, fresh)
  name = name or state.current_agent
  local agent = agents()[name]
  if not agent then
    return vim.notify("Unknown AI agent: " .. name, vim.log.levels.ERROR)
  end
  if vim.fn.executable(agent.command[1]) == 0 then
    return vim.notify(agent.command[1] .. " is not installed", vim.log.levels.WARN)
  end

  local session
  if not fresh then
    for _, candidate in pairs(state.sessions) do
      if
        candidate.agent == name
        and vim.api.nvim_buf_is_valid(candidate.buf)
        and vim.fn.jobwait({ candidate.job }, 0)[1] == -1
        and (not session or candidate.created_at > session.created_at)
      then
        session = candidate
      end
    end
    if session then
      show(session, layout or "vertical")
      state.current_agent = name
      state.current_session = session.id
      return session
    end
  end

  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = "hide"
  local id = string.format("%s:%d", name, vim.uv.hrtime())
  local job
  vim.api.nvim_buf_call(buf, function()
    job = vim.fn.jobstart(agent.command, {
      cwd = root(),
      env = { TERM = vim.env.TERM or "xterm-256color", COLORTERM = "truecolor" },
      term = true,
      on_exit = function()
        vim.schedule(function()
          if state.sessions[id] and state.sessions[id].buf == buf then
            state.sessions[id] = nil
            if state.current_session == id then
              state.current_session = nil
            end
          end
        end)
      end,
    })
  end)
  if job <= 0 then
    vim.api.nvim_buf_delete(buf, { force = true })
    return vim.notify("Unable to start " .. agent.label, vim.log.levels.ERROR)
  end
  session = { id = id, agent = name, buf = buf, job = job, label = agent.label, created_at = vim.uv.hrtime() }
  state.sessions[id] = session
  state.current_agent = name
  state.current_session = id
  vim.b[buf].ai_agent = name
  show(session, layout or "vertical")
  return session
end

function M.select(layout, fresh)
  local available = {}
  for name, agent in pairs(agents()) do
    available[#available + 1] = {
      name = name,
      label = agent.label,
      installed = vim.fn.executable(agent.command[1]) == 1,
    }
  end
  table.sort(available, function(a, b)
    if a.name == "opencode" then
      return true
    end
    if b.name == "opencode" then
      return false
    end
    return a.label < b.label
  end)
  vim.ui.select(available, {
    prompt = "AI agent",
    format_item = function(item)
      return string.format("%-14s %s", item.label, item.installed and "available" or "missing")
    end,
  }, function(item)
    if item then
      M.open(item.name, layout, fresh)
    end
  end)
end

local function active()
  local session = state.sessions[state.current_session]
  if not session or not vim.api.nvim_buf_is_valid(session.buf) or vim.fn.jobwait({ session.job }, 0)[1] ~= -1 then
    session = M.open(state.current_agent, "vertical", false)
  end
  return session
end

local function send(text)
  local session = active()
  if not session then
    return
  end
  local max = 100000
  if #text > max then
    text = text:sub(1, max) .. "\n[context truncated at 100 KB]"
  end
  vim.api.nvim_chan_send(session.job, text .. "\r")
end

local function relative_file()
  local file = vim.api.nvim_buf_get_name(0)
  if file == "" then
    return "[unnamed]"
  end
  return vim.fn.fnamemodify(file, ":.")
end

function M.send_file()
  send(string.format("Use this file as context: @%s", relative_file()))
end

function M.send_selection()
  local first = vim.fn.line("'<")
  local last = vim.fn.line("'>")
  if first == 0 or last == 0 then
    return vim.notify("No visual selection is available", vim.log.levels.WARN)
  end
  local lines = vim.api.nvim_buf_get_lines(0, first - 1, last, false)
  send(string.format("Context from %s lines %d-%d:\n```%s\n%s\n```", relative_file(), first, last, vim.bo.filetype, table.concat(lines, "\n")))
end

function M.send_diagnostics()
  local diagnostics = vim.diagnostic.get(0)
  if #diagnostics == 0 then
    return vim.notify("No diagnostics in this buffer", vim.log.levels.INFO)
  end
  local lines = { "Diagnostics for " .. relative_file() .. ":" }
  for _, diagnostic in ipairs(diagnostics) do
    lines[#lines + 1] = string.format("L%d:C%d [%s] %s", diagnostic.lnum + 1, diagnostic.col + 1, diagnostic.source or "diagnostic", diagnostic.message)
  end
  send(table.concat(lines, "\n"))
end

local function git_diff()
  if vim.fn.executable("git") == 0 then
    return nil, "git is not installed"
  end
  local result = vim.system({ "git", "diff", "--no-ext-diff" }, { cwd = root(), text = true }):wait()
  if result.code ~= 0 then
    return nil, result.stderr
  end
  if result.stdout == "" then
    local staged = vim.system({ "git", "diff", "--cached", "--no-ext-diff" }, { cwd = root(), text = true }):wait()
    return staged.stdout, staged.stderr
  end
  return result.stdout, nil
end

function M.send_diff(review)
  local diff, err = git_diff()
  if not diff then
    return vim.notify(err or "Unable to read Git diff", vim.log.levels.ERROR)
  end
  if diff == "" then
    return vim.notify("Git diff is empty", vim.log.levels.INFO)
  end
  local prompt = review and "Review this change. Prioritize correctness, regressions, security, and missing tests.\n" or "Use this Git diff as context.\n"
  send(prompt .. "```diff\n" .. diff .. "\n```")
end

function M.sessions()
  local items = {}
  for id, session in pairs(state.sessions) do
    if vim.api.nvim_buf_is_valid(session.buf) then
      items[#items + 1] = { id = id, session = session }
    end
  end
  vim.ui.select(items, {
    prompt = "AI sessions",
    format_item = function(item)
      return string.format("%s  #%s", item.session.label, item.id:match(":(%d+)$"):sub(-6))
    end,
  }, function(item)
    if item then
      state.current_agent = item.session.agent
      state.current_session = item.id
      show(item.session, "vertical")
    end
  end)
end

function M.setup()
  vim.api.nvim_create_user_command("AIAgent", function(opts)
    if opts.args ~= "" then
      M.open(opts.args, "vertical", opts.bang)
    else
      M.select("vertical", opts.bang)
    end
  end, { nargs = "?", bang = true, desc = "Open or select an AI agent" })
  vim.api.nvim_create_user_command("AISessions", M.sessions, { desc = "Select an active AI session" })
  vim.api.nvim_create_user_command("AIHealth", function()
    local report = {}
    for name, agent in pairs(agents()) do
      report[#report + 1] = string.format("%-10s %s", name, vim.fn.executable(agent.command[1]) == 1 and vim.fn.exepath(agent.command[1]) or "missing")
    end
    table.sort(report)
    vim.notify(table.concat(report, "\n"), vim.log.levels.INFO, { title = "AI Agents" })
  end, { desc = "Show AI agent availability" })
end

return M
