local M = {}

local utils = require("utils")

M.search_start = function()
  Cosas = 1
  vim.g.search_plugin = 1
  local search_start = utils.gen_cmd['search']('parts')
  print(search_start)
end

return M
