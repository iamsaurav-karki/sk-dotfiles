local M = {}

local function relative_time(timestamp)
  local seconds = math.max(0, os.time() - timestamp)
  local units = {
    { name = "year", seconds = 31557600 },
    { name = "month", seconds = 2629800 },
    { name = "week", seconds = 604800 },
    { name = "day", seconds = 86400 },
    { name = "hour", seconds = 3600 },
    { name = "minute", seconds = 60 },
  }

  for _, unit in ipairs(units) do
    if seconds >= unit.seconds then
      local count = math.floor(seconds / unit.seconds)
      return string.format("%d %s%s ago", count, unit.name, count == 1 and "" or "s")
    end
  end
  return "just now"
end

function M.blame_formatter(_, info)
  local author = info.author or "Unknown"
  if author == "Not Committed Yet" then
    return { { "Not committed yet", "GitSignsCurrentLineBlame" } }
  end
  return {
    {
      string.format("  󰊢 %s, %s", author, relative_time(info.author_time or os.time())),
      "GitSignsCurrentLineBlame",
    },
  }
end

return M
