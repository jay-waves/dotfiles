local M = {}

local api = vim.api
local ui2
local active_type
local saved_window
local original_menu_position
local initialized = false

local function set_highlights()
    local links = {
        -- Match fzf-lua's default normal, border, and title links.
        CmdlineFloat = "Normal",
        CmdlineFloatBorder = "Normal",
        CmdlineFloatTitle = "CmdlineFloat",
    }
    for name, target in pairs(links) do
        api.nvim_set_hl(0, name, { link = target, default = true })
    end
end

local function cmd_window()
    local win = ui2.wins.cmd
    return win and api.nvim_win_is_valid(win) and win or nil
end

local function reset_cmdheight()
    vim._with({ noautocmd = true, o = { splitkeep = "screen" } }, function()
        vim.o.cmdheight = 0
    end)
end

local function update_completion_menu()
    local ok, menu = pcall(require, "blink.cmp.completion.windows.menu")
    if ok and menu.win and menu.win:is_open() then
        pcall(menu.update_position)
    end
end

local function position()
    if not active_type then
        return
    end

    local win = cmd_window()
    if not win then
        return
    end
    if not saved_window then
        local cfg = api.nvim_win_get_config(win)
        saved_window = {
            config = {
                relative = cfg.relative,
                anchor = cfg.anchor,
                row = cfg.row,
                col = cfg.col,
                width = cfg.width,
                border = cfg.border,
            },
            winhighlight = vim.wo[win].winhighlight,
        }
        vim.wo[win].winhighlight = table.concat({
            "Normal:CmdlineFloat",
            "FloatBorder:CmdlineFloatBorder",
            "FloatTitle:CmdlineFloatTitle",
            "Search:",
            "CurSearch:",
            "IncSearch:",
        }, ",")
    end

    local columns = vim.o.columns
    local lines = vim.o.lines
    local height = math.max(1, api.nvim_win_get_height(win))
    local width = math.min(columns - 2, math.max(40, math.min(80, math.floor(columns * 0.6))))
    width = math.max(1, width)
    local row = math.max(0, math.floor((lines - height - 2) * 0.25))
    local col = math.max(0, math.floor((columns - width - 2) * 0.5))

    local cfg = api.nvim_win_get_config(win)
    if cfg.relative ~= "editor" or cfg.row ~= row or cfg.col ~= col or cfg.width ~= width then
        pcall(api.nvim_win_set_config, win, {
            relative = "editor",
            row = row,
            col = col,
            width = width,
            border = "rounded",
        })
    end

    -- blink.cmp reads this position when opening its command-line menu.
    vim.g.ui_cmdline_pos = { row + height + 2, col + 4 }
    update_completion_menu()
end

function M.setup()
    if initialized then
        return
    end
    initialized = true

    reset_cmdheight()
    vim.opt.fillchars:append({ msgsep = "─" })
    ui2 = require("vim._core.ui2")
    ui2.enable({})
    original_menu_position = vim.g.ui_cmdline_pos

    local cmdline = require("vim._core.ui2.cmdline")
    local original_show = cmdline.cmdline_show
    cmdline.cmdline_show = function(...)
        local result = original_show(...)
        if active_type then
            -- ui2 briefly raises cmdheight while drawing. Search keeps one row
            -- so Neovim can maintain its incremental-search preview.
            if active_type ~= "/" and active_type ~= "?" then
                reset_cmdheight()
            end
            position()
        end
        return result
    end

    local group = api.nvim_create_augroup("PersonalCmdline", { clear = true })
    api.nvim_create_autocmd("ColorScheme", {
        group = group,
        callback = set_highlights,
    })
    set_highlights()

    api.nvim_create_autocmd("CmdlineEnter", {
        group = group,
        callback = function()
            active_type = vim.fn.getcmdtype()
            vim.schedule(position)
        end,
    })
    api.nvim_create_autocmd("CmdlineLeave", {
        group = group,
        callback = function()
            active_type = nil
            vim.g.ui_cmdline_pos = original_menu_position
            local win = cmd_window()
            if win and saved_window then
                pcall(api.nvim_win_set_config, win, saved_window.config)
                vim.wo[win].winhighlight = saved_window.winhighlight
            end
            saved_window = nil
            vim.schedule(function()
                if not active_type then
                    reset_cmdheight()
                end
            end)
        end,
    })
    api.nvim_create_autocmd({ "VimResized", "TabEnter" }, {
        group = group,
        callback = function()
            vim.schedule(position)
        end,
    })
end

return M
