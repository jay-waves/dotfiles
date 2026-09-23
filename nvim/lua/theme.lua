local M = {}

local function github(variant)
    return {
        name = "github_" .. variant .. "_tritanopia",
        background = variant,
        module = "github-theme",
        options = { options = { transparent = true } },
    }
end

local function catppuccin(flavour)
    return {
        name = "catppuccin-" .. flavour,
        lualine = "catppuccin-nvim",
        module = "catppuccin",
        options = { transparent_background = true },
    }
end

local themes = {
    github_light = github("light"),
    github_dark = github("dark"),
    nord = {
        name = "nord",
        lualine = "nord",
        setup = function()
            vim.g.nord_disable_background = true
        end,
    },
    catppuccin_mocha = catppuccin("mocha"),
    catppuccin_macchiato = catppuccin("macchiato"),
    catppuccin_frappe = catppuccin("frappe"),
    gruvbox = {
        name = "gruvbox",
        lualine = "gruvbox",
        module = "gruvbox",
        options = { transparent_mode = true, contrast = "soft" },
    },
}

function M.setup(theme_name)
    vim.pack.add({
        "https://github.com/projekt0n/github-nvim-theme",
        "https://github.com/shaunsingh/nord.nvim",
        { src = "https://github.com/catppuccin/nvim", name = "catppuccin" },
        "https://github.com/ellisonleao/gruvbox.nvim",
        "https://github.com/nvim-lualine/lualine.nvim",
    })

    local theme = assert(themes[theme_name], "Unknown theme preset: " .. theme_name)
    vim.opt.background = theme.background or "dark"
    if theme.module then
        require(theme.module).setup(theme.options)
    elseif theme.setup then
        theme.setup()
    end
    vim.cmd.colorscheme(theme.name)

    require("lualine").setup({
        options = {
            theme = theme.lualine or "auto",
            globalstatus = true,
        },
        sections = {
            lualine_a = { "mode" },
            lualine_c = { { "filename", path = 1 } },
            lualine_x = { "filetype" },
            lualine_y = { "progress" },
        },
        tabline = {
            lualine_a = {
                {
                    "buffers",
                    max_length = function()
                        return math.floor(vim.o.columns * 0.95)
                    end,
                    symbols = { modified = "*" },
                },
            },
        },
    })
end

return M
