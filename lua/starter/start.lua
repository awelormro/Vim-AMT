local M = {}
function M.starter()
  vim.g.amt_core_lua_started = 1
  print('lua core started')
end
return M
