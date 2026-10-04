local M = {}

-- Completion menu highlights follow the active theme.
local function set_highlights()
    local function hl(name)
        return vim.api.nvim_get_hl(0, { name = name, link = false })
    end

    local normal = hl("Normal")
    local float = hl("NormalFloat")
    local background = vim.o.background == "light" and (float.bg or normal.bg) or nil
    local function set_hl(name, options)
        options.bg = background
        vim.api.nvim_set_hl(0, name, options)
    end

    local foreground = float.fg or normal.fg
    local accent = hl("Title").fg or hl("DiagnosticInfo").fg or hl("FloatBorder").fg or foreground
    local muted = hl("Comment").fg or foreground

    -- Share theme colors while keeping each component's highlight groups independent.
    set_hl("BlinkCmpMenu", { fg = foreground })
    set_hl("BlinkCmpMenuBorder", { fg = accent })
    set_hl("BlinkCmpLabel", { fg = foreground })
    set_hl("BlinkCmpLabelMatch", { fg = accent, bold = true })
    set_hl("BlinkCmpLabelDetail", { fg = muted })
    set_hl("BlinkCmpLabelDescription", { fg = muted })
end

function M.setup()
    vim.pack.add({
        { src = "https://github.com/saghen/blink.cmp", version = "v1" },
        { src = "https://github.com/saghen/blink.compat", version = vim.version.range("2.*") },
        "https://github.com/kdheepak/cmp-latex-symbols",
    })

    --> PlugIn: Blink.CMP
    local cmp = require("blink.cmp")
    cmp.setup({
        keymap = {
            preset = "super-tab",
        },

        completion = {
            menu = {
                auto_show = false,
                border = "rounded",
                scrollbar = false,
            },

            ghost_text = {
                enabled = true,
                show_with_menu = true,
            },
        },
    })

    vim.api.nvim_create_autocmd("ColorScheme", {
        group = vim.api.nvim_create_augroup("PersonalCompletionHighlights", { clear = true }),
        callback = set_highlights,
    })
    set_highlights()

    -- Markdown: LaTeX symbol completion.
    require("blink.compat").setup({})
    cmp.add_source_provider("latex_symbols", {
        name = "latex_symbols",
        module = "blink.compat.source",
        opts = { strategy = 2 },
    })
    cmp.add_filetype_source("markdown", "latex_symbols")


    --> Use Terminal to map <Ctrl-space> to <F18>
    vim.keymap.set("i", "<F18>", function()
        if cmp.is_menu_visible() then
            cmp.hide()
        else
            cmp.show()
        end
    end, { desc = "Toggle completion menu" })
end

return M
