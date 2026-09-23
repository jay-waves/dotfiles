--> use \s as <leader>
vim.g.mapleader = " "
vim.g.maplocalleader = " "

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

vim.keymap.set("n", "<leader>h", vim.lsp.buf.hover, {
    desc = "Show documentation",
})

--> Click + Ctrl to jump to file
vim.keymap.set("n", "<C-LeftMouse>", "<LeftMouse>gf")

-->  instead of using im-select to switch to US.English, 
--> i want to use PinYin.English. 
--> so we need to call the windows imm32.dl directly using the LuaJIT FFI 
require("ime").setup()

-- Theme preset: change this string and restart Neovim. See lua/theme.lua for presets.
-- github_dark/light, nord, gruvbox, catppuccin_macchiato/mocha/frappe
require("theme").setup("github_dark")

require("title").setup()

--> PlugIn: vim-matchup, use %, [%, ]% and g%, <leader>%
vim.g.matchup_matchparen_offscreen = {
    method = "popup",
}

vim.pack.add({
    "https://github.com/nvim-treesitter/nvim-treesitter", --> :TSUpdate
    "https://github.com/andymass/vim-matchup",

    "https://github.com/lewis6991/gitsigns.nvim",
    "https://github.com/ibhagwan/fzf-lua",
    { src = "https://github.com/saghen/blink.cmp", version = "v1", },
    "https://github.com/nvim-mini/mini.files",
    "https://github.com/jay-waves/markdown-preview.nvim",
})


--> PlugIn: Mini.Files, vim-like keymap, and = to save changes
require("mini.files").setup({
    mappings = {
        go_in = "L",
        go_in_plus =  "l",
    },
    windows = {
        max_number = 3,
        preview = true,
        width_focus = 30,
        width_nofocus = 30,
        width_preview = 60,
    },
})

vim.keymap.set("n", "<leader>e", function() 
    require("mini.files").open(vim.api.nvim_buf_get_name(0)) 
end)

--> PlugIn: FzfLua
vim.keymap.set("n", "<leader>p", "<cmd>FzfLua<cr>")
vim.keymap.set("n", "<leader>b", "<cmd>FzfLua buffers<cr>")
vim.keymap.set("n", "<leader>O", "<cmd>FzfLua lsp_document_symbols<cr>")
vim.keymap.set("n", "<leader>o", "<cmd>FzfLua treesitter<cr>")

--> PlugIn: GitSign
-- preview_hunk, next_hunk, prev_hunk, blame_line
require("gitsigns").setup({})

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
        ["<C-@>"] = { "show" },
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
            auto_show = false,
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

vim.lsp.config("*", {
    capabilities = require("blink.cmp").get_lsp_capabilities(),
})

--> PlugIn: markdown-preview
require("typst_preview").setup()

require("markdown_preview").setup({
    default_theme = "auto",
    follow_current_buffer = true,
    scroll_sync = true,
})

--> LSP: 
require("lsp").setup()

-- bind blink.cmp
vim.lsp.config("*", {
    capabilities = require("blink.cmp").get_lsp_capabilities(),
})

vim.keymap.set("v", "<leader>f", function()
    vim.lsp.buf.format({
        async = false,
    })
    vim.cmd("normal! \27")
end, { desc = "Format selected range" })

vim.keymap.set("n", "<leader>l", function()
    vim.diagnostic.open_float({
        scope = "line",
        source = true,
    })
end, { desc = "Show line diagnostics", })

vim.keymap.set("n", "<leader>L", function()
    local win = vim.fn.getloclist(0, { winid = 0 }).winid

    if win ~= 0 then
        vim.cmd("lclose")
    else
        vim.diagnostic.setloclist({ open = true })
    end
end, { desc = "Toggle diagnostics loclist", })

-->LSPConfig
