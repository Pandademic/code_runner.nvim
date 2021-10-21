-- Import options
local o = require("code_runner.options").get()

-- Create prefix for run commands
local prefix = string.format("%s %dsplit term://", o.term.position, o.term.size)

local floatCR = require("code_runner.float_run")

-- Replace json variables with vim variables in command.
-- If a command has no arguments, one is added with the current file path
-- @param command command to run the path
-- @param path absolute path
-- @return command with variables replaced by modifiers
local function re_jsonvar_with_vimvar(command, path)
  local no_sub_command = command

  command = command:gsub("$fileNameWithoutExt", vim.fn.fnamemodify(path, ":t:r"))
  command = command:gsub("$fileName", vim.fn.fnamemodify(path, ":t"))
  command = command:gsub("$file", path)
  command = command:gsub("$dir", vim.fn.fnamemodify(path, ":p:h"))

  if command == no_sub_command then
    command = command .. " " .. path
  end
  return command
end

-- Check if current buffer is in project
-- if a project return table of project
local function get_project_rootpath()
  local path = "%:p:~:h"
  local expand = ""
  while expand ~= "~" do
    expand = vim.fn.expand(path)
    local project = vim.g.projectManager[expand]
    if project then
      project["path"] = expand
      return project
    end
    path = path .. ":h"
  end
  return nil
end

-- Return a command for filetype
-- @param filetype filetype of path
-- @param path absolute path to file
-- @return command
local function get_command(filetype, path)
  path = path or vim.fn.expand("%:p")
  local command = vim.g.fileCommands[filetype]
  if command then
    local command_vim = re_jsonvar_with_vimvar(command, path)
    return command_vim
  end
  return
end

-- Run command in project context
local function run_project(context, floatWin)
  local command = ""
  if context.file_name then
    local file = context.path .. "/" .. context.file_name
    if context.command then
      command = re_jsonvar_with_vimvar(context.command, file)
    else
      local filetype = require'plenary.filetype'
      local current_filetype = filetype.detect_from_extension(file)
      command = get_command(current_filetype, file)
    end
  else
    command = "cd " .. context.path .. " &&" .. context.command
  end
  if floatWin then
    floatCR.run(command)
  else
    if command ~= nil then
      vim.cmd(prefix .. command)
    end
  end
end

local function getContext()
  local context = nil
  if vim.g.projectManager then
    context = get_project_rootpath()
  end
  return context
end

local M = {}

-- Execute filetype or project
function M.run(open_float_terminal, ...)
  open_float_terminal = open_float_terminal or false
  local json_key_select = select(1,...)
  if json_key_select ~= "" then
    -- since we have reached here, means we have our command key
    local cmd_to_execute = get_command(json_key_select)
    if cmd_to_execute ~= nil then
      if open_float_terminal then
        floatCR.run(cmd_to_execute)
      else
        vim.cmd(prefix .. cmd_to_execute)
      end
    end
    return
  end

  --  procede here if no input arguments
  local is_a_project = M.run_project(open_float_terminal)
  if not is_a_project then
    M.run_filetype(open_float_terminal)
  end
end

-- Execute filetype
function M.run_filetype(open_float_terminal)
  open_float_terminal = open_float_terminal or false
  local filetype = vim.bo.filetype
  local command = get_command(filetype)
  if command ~= nil then
    if open_float_terminal then
      floatCR.run(command)
    else
      vim.cmd(prefix .. command)
    end
  end
end

-- Execute project
function M.run_project(open_float_terminal)
  open_float_terminal = open_float_terminal or false
  local context = getContext()
  if context then
    run_project(context, open_float_terminal)
    return true
  end
  return false
end

return M
