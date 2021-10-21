local fwin = {}
local api = vim.api
local cmd = vim.cmd
local fn = vim.fn

local M = {}

local function processLayout()
    local cl = vim.o.columns
    local ln = vim.o.lines

    -- calculate our floating window size
    local width = math.ceil(cl * .8 )
    local height = math.ceil(ln * .8 - 4)

    -- and its starting position
    local col = math.ceil((cl - width) * .5 )
    local row = math.ceil((ln - height) * .5 - 1)

    fwin.layout = {
        width = width,
        height = height,
        col = col,
        row = row
    }
end

processLayout()

function M.new_buf()
    fwin.buf = api.nvim_create_buf(false, true)
    api.nvim_buf_set_option(fwin.buf, 'filetype', 'CodeRunner')
end

function M.new_win()
    fwin.win = api.nvim_open_win(fwin.buf, true, {
        relative = "editor",
        style = "minimal",
        border = "rounded",
        width = fwin.layout.width,
        height = fwin.layout.height,
        col = fwin.layout.col,
        row = fwin.layout.row
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
