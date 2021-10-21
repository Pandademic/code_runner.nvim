local options = {
  term = {
    position = "belowright",
    size = 8,
  },
  fterm = {
    border = "rounded",
    bgcolor = "NONE",
    width = .8,
    height = .8,
    x = .5,
    y = .5
  },
  filetype_path = vim.fn.stdpath("data") .. "/site/pack/packer/start/code_runner.nvim/lua/code_runner/code_runner.json",
  project_context_path = vim.fn.stdpath("data") .. "/site/pack/packer/start/code_runner.nvim/lua/code_runner/project_manager.json",

}

local M = {}
-- set user config
M.set = function(user_options)
  for key, value in pairs(options) do
    local u_o = user_options[key] or {}
    options[key] = vim.tbl_extend("force", value, u_o)
  end
end

-- get user options
M.get = function()
  return options
end

return M
