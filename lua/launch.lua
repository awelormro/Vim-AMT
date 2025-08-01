local M = {}

vim = vim
local utils = require('utils')

M.start_buffer = function(list, head)
  local tw = vim.api.nvim_eval('&tw')
  if tw == 0 then
    vim.gen_cmd('set splitbelow')
  end
  utils.cmd(':11split')
  utils.cmd(':e search.amtsearch')
  utils.cmd([[set filetype=amtsearch
  ]])

  M.fill_buffer(list)
end

M.fill_buffer = function(list)
  local func = vim.cmd('echo 1')
end

return M
