local commands = require("code_runner.commands")
local M = {}
local o = require("code_runner.options")


M.setup = function(user_options)
	o.set(user_options)
	M.load_json_files()
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
			command! CRFiletype lua require('code_runner').open_filetype_suported()
			command! CRProjects lua require('code_runner').open_project_manager()
			command! -nargs=? -complete=custom,CRunnerGetKeysForCmds RunCode lua require('code_runner').run_code("<args>")
			command! RunFile lua require('code_runner').run_filetype()
			command! RunProject lua require('code_runner').run_project()
			command! RunClose lua require('code_runner').run_close()
			" command! RunReload lua require('code_runner').run_reload()
		]],
		false
	)
end

local function open_json(json_path)
	local command = "tabnew " .. json_path
	vim.cmd(command)
end

M.load_json_files = function()
	-- Load json config and convert to table
	local opt = o.get()
	local load_json_as_table = require("code_runner.load_json")
	local next = next

	-- convert json filetype as table lua
	if next(opt.filetype or {}) == nil then
		opt.filetype = load_json_as_table(opt.filetype_path)
	end

	-- convert json project as table lua
	if next(opt.project or {}) == nil then
		opt.project = load_json_as_table(opt.project_path)
	end

	-- Message if json file not exist
	if next(opt.filetype or {}) == nil then
		print("Not exist command for filetypes or format invalid, if use json please execute :CRFiletype or if use lua edit setup")
	end
end

M.run_code = commands.run
M.run_filetype = commands.run_filetype
M.run_project = commands.run_project
M.run_close = commands.run_close
-- M.run_reload = commands.run_reload
M.get_filetype_command = commands.get_filetype_command
M.get_project_command = commands.get_project_command

M.open_filetype_suported = function()
	open_json(o.get().filetype_path)
end

M.open_project_manager = function()
	open_json(o.get().project_path)
end

return M
