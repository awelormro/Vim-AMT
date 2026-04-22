local M = {}
function M.starter()
  vim.g.amt_core_lua_started = 1
end

function M.first_function()
  print("Very first lua module")
  vim.g.amt_variable_generated = true
end

function M.start()
  print('start AMT in Lua')
end
return M
