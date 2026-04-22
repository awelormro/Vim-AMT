local M = {}

local vim = vim

M.start_buffer = function(list, head)
  local tw = vim.api.nvim_eval('&tw')
  if tw == 0 then
    vim.gen_cmd('set splitbelow')
  end


  M.fill_buffer(list)
end

M.fill_buffer = function(list)
  local func = vim.cmd('echo 1')
end

return M
