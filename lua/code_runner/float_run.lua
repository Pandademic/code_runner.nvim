local fwin = {}
local api = vim.api
local cmd = vim.cmd
local fn = vim.fn
local float_term_o = require("code_runner.options").get().fterm

local M = {}

local function processLayout()
    local cl = vim.o.columns
    local ln = vim.o.lines

    -- calculate our floating window size
    local width = math.ceil(cl * float_term_o.width )
    local height = math.ceil(ln * float_term_o.height - 4)

    -- and its starting position
    local col = math.ceil((cl - width) * float_term_o.y  )
    local row = math.ceil((ln - height) * float_term_o.x - 1)

    fwin.layout = {
        width = width,
        height = height,
        col = col,
        row = row
    }
end

processLayout()

local function new_buf()
    fwin.buf = api.nvim_create_buf(false, true)
    api.nvim_buf_set_option(fwin.buf, 'filetype', 'CodeRunner')
end

local function new_win()
    fwin.win = api.nvim_open_win(fwin.buf, true, {
        relative = "editor",
        style = "minimal",
        border = float_term_o.border,
        width = fwin.layout.width,
        height = fwin.layout.height,
        col = fwin.layout.col,
        row = fwin.layout.row
    })
    api.nvim_win_set_option(fwin.win, "winhl", "Normal:".. float_term_o.border.bgcolor)
end

local function new_term(command)
    fwin.term = fn.termopen(command)
    cmd("startinsert")
end

local function show(command)
    new_buf()
    new_win()
    new_term(command)
    print(vim.inspect("entre a flotante"))
    api.nvim_set_current_win(fwin.win)
end

function M.run(command)
    show(command)
end

return M
