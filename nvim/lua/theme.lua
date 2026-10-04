local M = {}

local themes = {
    nordbones = {
        name = "nordbones",
        background = "dark",
    },
    zenwritten_light = {
        name = "zenwritten",
        background = "light",
    },
    patana_light = {
        name = "patana",
        background = "light",
    },
    github_light = {
        name = "github_light",
        background = "light",
        module = "github-theme",
        options = { options = { transparent = false } },
    },
    github = {
        name = "github_dark_tritanopia",
        module = "github-theme",
        options = { options = { transparent = true } },
    },
    gruvbox = {
        name = "gruvbox",
        module = "gruvbox",
        options = { transparent_mode = true, contrast = "soft" },
    },
    zenbones = {
        name = "zenbones",
        background = "dark",
    },
}

function M.setup(theme_name)
    vim.g.zenbones_darkness = "warm"

    vim.pack.add({
        "https://github.com/rktjmp/lush.nvim",
        "https://github.com/zenbones-theme/zenbones.nvim",
        "https://github.com/projekt0n/github-nvim-theme",
        "https://github.com/ellisonleao/gruvbox.nvim",
        "https://github.com/cvigilv/patana.nvim",
    })

    local theme = assert(themes[theme_name], "Unknown theme preset: " .. theme_name)
    vim.opt.background = theme.background or "dark"
    if theme.module then
        require(theme.module).setup(theme.options)
    end
    vim.cmd.colorscheme(theme.name)
end

return M
