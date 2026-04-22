local M = {}

M.trim = function(s)
    return (string.gsub(s, "^%s*(.-)%s*$", "%1"))
end
-- Solo izquierda (leading)
M.ltrim = function(s)
    return (string.gsub(s, "^%s*", ""))
end

-- Solo derecha (trailing)
M.rtrim = function(s)
    return (string.gsub(s, "%s*$", ""))
end

local function tokens_line(text)
  local tokens = {}
  local i = 1
  while i <= #text do
    i = i + 1
  end
  return tokens
end

M.slice = function(t, idx_start, idx_end)
  local result = {}
  idx_start = idx_start or 1
  idx_end = idx_end or #t
  for i = idx_start, idx_end do
    table.insert(result, t[i])
  end
  return result
end


M.tokenize_line = function(text)
  local tokens = {}
  local i = 1
  local idx_end = #text
  while i <= idx_end do
    i = i + 1
  end
  return tokens
end

M.tokenize_document = function(text)
  local tokens = {}
  local i = 1
  local len_buffer = #text
  while i <= len_buffer do
    token_add = tokens_line(text[i])
  end
end

return M
