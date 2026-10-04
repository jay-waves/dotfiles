local M = {}

local servers = {
    "lua_ls",
    "gopls",
    "ty",
    "tinymist",
    "rumdl",
}

function M.setup()
    -- Completion is initialized by init.lua before LSP setup.
    vim.pack.add({
        "https://github.com/nvim-treesitter/nvim-treesitter",
        "https://github.com/neovim/nvim-lspconfig",
        "https://github.com/stevearc/conform.nvim",
    })

    --> PlugIn: TreeSitter
    require("nvim-treesitter").install({
        "lua",
        "vim",
        "vimdoc",
        "bash",
        "query",
        "markdown",
        "markdown_inline",
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
        group = vim.api.nvim_create_augroup("PersonalTreesitter", { clear = true }),
        callback = function()
            pcall(vim.treesitter.start)
        end,
    })

    ---------------------------------------------------------------------------
    -- Diagnostics
    ---------------------------------------------------------------------------

    vim.diagnostic.config({
        severity_sort = true,
        underline = true,
        signs = true,
        update_in_insert = false,

        virtual_text = {
            spacing = 2,
            source = "if_many",
        },

        float = {
            border = "rounded",
            source = "if_many",
        },
    })

    ---------------------------------------------------------------------------
    -- LSP defaults
    ---------------------------------------------------------------------------

    -- Applied to every LSP server.
    vim.lsp.config("*", {
        capabilities = require("blink.cmp").get_lsp_capabilities(),
    })

    ---------------------------------------------------------------------------
    -- Lua
    ---------------------------------------------------------------------------

    vim.lsp.config("lua_ls", {
        settings = {
            Lua = {
                diagnostics = {
                    globals = { "vim" },
                },
            },
        },
    })

    ---------------------------------------------------------------------------
    -- Typst
    --
    -- cmd/filetypes/root_markers come from nvim-lspconfig.
    ---------------------------------------------------------------------------

    vim.lsp.config("tinymist", {
        settings = {
            syntaxOnly = "enable",
            projectResolution = "singleFile",
            formatterMode = "typstyle",
            exportPdf = "never",
            semanticTokens = "disable",

            preview = {
                background = {
                    enabled = false,
                },
            },
        },
    })

    ---------------------------------------------------------------------------
    -- Markdown
    ---------------------------------------------------------------------------

    vim.lsp.config("rumdl", {
        root_markers = {
            ".rumdl.toml",
            "rumdl.toml",
            ".git",
        },

        init_options = {
            disableRules = {
                "MD033",
                "MD041",
                "MD045",
            },

            settings = {
                lineLength = 100,
            },
        },
    })

    ---------------------------------------------------------------------------
    -- Enable LSP servers
    --
    -- gopls and ty need no local configuration; nvim-lspconfig provides
    -- cmd, filetypes, root detection, etc.
    ---------------------------------------------------------------------------

    vim.lsp.enable(servers)

    ---------------------------------------------------------------------------
    -- Formatting
    ---------------------------------------------------------------------------

    local conform = require("conform")

    conform.setup({
        formatters_by_ft = {
            lua = {
                "stylua",
            },

            -- Prefer goimports; fall back to gofmt if it isn't installed.
            go = {
                "goimports",
                "gofmt",
                stop_after_first = true,
            },

            python = {
                "ruff_format",
            },

            markdown = {
                "rumdl",
            },

            -- Typst deliberately has no external formatter here.
            -- Conform falls back to Tinymist, whose formatterMode is typstyle.
        },

        default_format_opts = {
            timeout_ms = 3000,
            lsp_format = "fallback",
        },

        notify_on_error = true,
        notify_no_formatters = false,
    })

    ---------------------------------------------------------------------------
    -- Format
    --
    -- Normal mode: whole buffer
    -- Visual mode: selected range when supported
    ---------------------------------------------------------------------------

    vim.keymap.set({ "n", "x" }, "<leader>q", function()
        conform.format()
    end, {
        desc = "Format",
    })

end

return M
