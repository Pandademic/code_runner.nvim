local fwin = {}
local api = vim.api
local cmd = vim.cmd
local fn = vim.fn

local M = {}

function M.new_buf()
    fwin.buf = api.nvim_create_buf(false, true)
    api.nvim_buf_set_option(fwin.buf, 'filetype', 'CodeRunner')
end

function M.new_win()
    fwin.win = api.nvim_open_win(fwin.buf, true, {
        relative = "editor",
        style = "minimal",
        border = "rounded",
        width = 15,
        height = 15,
        col = .8,
        row = .8
    })
    api.nvim_win_set_option(fwin.win, "winhl", "Normal:".. "NONE")
end

function M.new_term()
    fwin.term = fn.termopen(os.getenv("SHELL"))
    cmd("startinsert")
end

function M.show()
    if fwin.buf == nil then
        M.new_buf()
        M.new_win()
        M.new_term()
        api.nvim_chan_send(fwin.term, "clear\n")
    else
        M.new_win()
    end
    api.nvim_set_current_win(fwin.win)
    cmd("startinsert")
end

return M
