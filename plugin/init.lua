
vim = vim


if vim.fn.exists("g:amt_core") == 1 then
  if vim.g.amt_core ~= 'lua' then
    return
  end
end

vim.g.amt_core = 'lua'

if vim.fn.exists("g:amt_started") == 1 then
  return
end

vim.g.amt_started = 1

vim.cmd("command AMTLuaConfirm echo 'Greetings from AMT lua'")
require('starters.start').start()
