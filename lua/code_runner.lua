local options = require("code_runner.options")
local og = options.get()
local commands = require("code_runner.commands")
local M = {}

-- Load json config and convert to table
local loadTable = require("code_runner.load_json")

M.setup = function(user_options)
  options.set(user_options)
  vim.cmd([[lua require('code_runner').load_json_files()]])
  vim.api.nvim_exec(
  [[
    function! CRunnerGetKeysForCmds(Arg,Cmd,Curs)
      let cmd_keys = ""
      for x in keys(g:fileCommands)
        let cmd_keys = cmd_keys.x."\n"
      endfor
      return cmd_keys
    endfunction

    command! CRFiletype lua require('code_runner').open_filetype_suported()
    command! CRProjects lua require('code_runner').open_project_manager()

    command! -nargs=? -complete=custom,CRunnerGetKeysForCmds RunCode lua require('code_runner').run_code("<args>")
    command! RunFile lua require('code_runner').run_filetype()
    command! RunProject lua require('code_runner').run_project()

    command! -nargs=? -complete=custom,CRunnerGetKeysForCmds RunFcode lua require('code_runner').run_code(true, "<args>")
    command! RunFfile lua require('code_runner').run_filetype(true)
    command! RunFproject lua require('code_runner').run_project(true)
  ]],
    false
  )
end

M.load_json_files = function()
  vim.g.fileCommands = loadTable(og.filetype.json_path)
  vim.g.projectManager = loadTable(og.project_context.json_path)

  -- Message if json file not exist
  if not vim.g.fileCommands then
    local orunners = og.runners
    if orunners and #orunners > 0 then
     vim.g.fileCommands = vim.tbl_extend("force", vim.g.fileCommands, orunners)
    else
      print("File not exist or format invalid, please execute :CRFiletype")
    end
  end

  local oprojects = og.projects
  if not vim.g.projectManager and oprojects and #oprojects > 0 then
    vim.g.projectManager = vim.deepcopy(oprojects)
  end
end

M.run_code = commands.run
M.run_filetype = commands.run_filetype
M.run_project = commands.run_project

local function open_json(json_path)
  local command = "tabnew " .. json_path
  vim.cmd(command)
end

M.open_filetype_suported = function()
  open_json(og.filetype.json_path)
end

M.open_project_manager = function()
  open_json(og.project_context.json_path)
end

return M
