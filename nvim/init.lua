vim.opt.number = true
vim.opt.cursorline = true
vim.opt.wrap = false

vim.opt.scrolloff = 10

vim.opt.shiftwidth = 4
vim.opt.expandtab = true

-- search 
vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.keymap.set("n", "j", "gj", { noremap = true })
vim.keymap.set("n", "k", "gk", { noremap = true })

vim.keymap.set("n", "gh", vim.lsp.buf.hover, {
    desc = "Show documentation",
})

vim.keymap.set("n", "gl", function()
    vim.diagnostic.open_float({
        scope = "line",
        source = true,
    })
end, {
desc = "Show line diagnostics",
})

vim.keymap.set("n", "gL", function()
    vim.diagnostic.setloclist({ open = true })
end, {
desc = "Show buffer diagnostics",
})

--> Click + Ctrl to jump to file
vim.keymap.set("n", "<C-LeftMouse>", "<LeftMouse>gf")

-->  instead of using im-select to switch to US.English, 
--> i want to use PinYin.English. 
--> so we need to call the windows imm32.dl directly using the LuaJIT FFI 
require("ime").setup()

vim.pack.add({
    "https://github.com/nvim-treesitter/nvim-treesitter", --> :TSUpdate
    "https://github.com/lewis6991/gitsigns.nvim",
    "https://github.com/selimacerbas/live-server.nvim",
    "https://github.com/jay-waves/markdown-preview.nvim",
    "https://github.com/ibhagwan/fzf-lua",
    "https://github.com/nvim-tree/nvim-tree.lua",
    { src = "https://github.com/saghen/blink.cmp", version = "v1", },
})

--> PlugIn: FzfLua
vim.keymap.set("n", "gp", "<cmd>FzfLua<cr>", {
    desc = "Command Palette",
})

-- Theme preset: change this string and restart Neovim. See lua/theme.lua for presets.
-- github_dark, nord, gruvbox, catppuccin_macchiato/mocha/frappe
require("theme").setup("nord")

--> PlugIn: NvimTree
require("nvim-tree").setup({
    filters = {
        dotfiles = false,
        git_ignored = false,
    },
    renderer = {
        icons = {
            show = {
                file = false,
                folder = false,
                git = false,
                diagnostics = false,
            },
        },
    },
    view = {
        float = {
            enable = true,
            open_win_config = function()
                local width = math.floor(vim.o.columns * 0.7)
                local height = math.floor(vim.o.lines * 0.7)

                return {
                    relative = "editor",
                    border = "rounded",
                    width = width,
                    height = height,
                    row = math.floor((vim.o.lines - height) / 2),
                    col = math.floor((vim.o.columns - width) / 2),
                }
            end,
        },
    },
})

vim.keymap.set("n", "ge", "<cmd>NvimTreeToggle<cr>")

--> PlugIn: GitSign
require("gitsigns").setup({})
vim.api.nvim_create_user_command("GitPreview",
function()
    require("gitsigns").preview_hunk()
end,
{})
vim.api.nvim_create_user_command("GitNext",
function()
    require("gitsigns").next_hunk()
end,
{})
vim.api.nvim_create_user_command("GitPrev",
function()
    require("gitsigns").prev_hunk()
end,
{})
vim.api.nvim_create_user_command("GitBlame",
function()
    require("gitsigns").blame_line()
end,
{})

--> PlugIn: TreeSitter
require("nvim-treesitter").install({
    "lua",
    "vim",
    "vimdoc",
    "query",
    "markdown",
    "markdown_inline",
    "bash",
    "python",
    "javascript",
    "typescript",
    "tsx",
    "html",
    "xml",
    "css",
    "json",
    "yaml",
    "go",
    "rust",
    "c",
    "cpp",
    "typst",
    "powershell",
})

vim.api.nvim_create_autocmd("FileType", {
    callback = function()
        pcall(vim.treesitter.start)
    end,
})

--> PlugIn: Blink.CMP
require("blink.cmp").setup({
    keymap = {
        preset = "super-tab",
    },

    sources = {
        default = {
            "lsp",
            "path",
            "snippets",
            "buffer",
        },
    },

    completion = {
        menu = {
            auto_show = true,
        },

        documentation = {
            auto_show = true,
            auto_show_delay_ms = 300,
        },

        ghost_text = {
            enabled = true,
            show_with_menu = true,
        },
    },
})


-->> Preivewer: Typst + Tinymist
vim.api.nvim_create_autocmd("FileType", {
    pattern = "typst",
    callback = function()
        vim.opt_local.backupcopy = "yes"
    end,
})

vim.api.nvim_create_user_command("TypstPreview", function()
    local bufnr = vim.api.nvim_get_current_buf()
    local client = vim.lsp.get_clients({
        bufnr = bufnr,
        name = "tinymist",
    })[1]

    if not client then
        vim.notify(
            "Tinymist is not attached to the current buffer",
            vim.log.levels.ERROR
        )
        return
    end

    client:exec_cmd({
        title = "Start Tinymist Preview",
        command = "tinymist.startDefaultPreview",
        arguments = {},
    }, {
        bufnr = bufnr,
    }, function(err)
        if err then
            vim.notify(
                vim.inspect(err),
                vim.log.levels.ERROR,
                { title = "Tinymist Preview" }
            )
        end
    end)

end, {
desc = "start Tinymist preview for the focused Typst buffer",
})

vim.api.nvim_create_autocmd("BufEnter", {
    pattern = "*.typ",
    callback = function(args)
        vim.schedule(function()
            if vim.api.nvim_get_current_buf() ~= args.buf then
                return
            end

            local client = vim.lsp.get_clients({
                bufnr = args.buf,
                name = "tinymist",
            })[1]

            if not client then
                return
            end

            client:exec_cmd({
                title = "Focus Tinymist Preview",
                command = "tinymist.focusMain",
                arguments = { vim.api.nvim_buf_get_name(args.buf) },
            }, {
                bufnr = args.buf,
            })
        end)
    end,
    desc = "focus Tinymist preview when entering a Typst buffer",
})

vim.lsp.config("tinymist", {
    cmd = { "tinymist", "lsp" },
    filetypes = { "typst" },

    capabilities = require("blink.cmp").get_lsp_capabilities(),

    root_markers = { ".git", },

    settings = {
        projectResolution = "singleFile",
        formatterMode = "typstyle",
    },
})

vim.lsp.enable("tinymist")

--> PlugIn & Preiviewer: Markdown Preview
require("markdown_preview").setup({
    default_theme = "auto",
    follow_current_buffer = true,
})

