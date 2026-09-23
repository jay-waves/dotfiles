local M = {}

function M.setup()
    vim.lsp.config("tinymist", {
        cmd = { "tinymist", "lsp" },
        filetypes = { "typst" },
        root_markers = { ".git" },
        settings = {
            projectResolution = "singleFile",
            formatterMode = "typstyle",
        },
    })
    vim.lsp.config("lua_ls", {
        cmd = { "lua-language-server" },
        filetypes = { "lua" },
        settings = {
            Lua = {
                diagnostics = {
                    globals = { "vim" },
                },
            },
        },
    })
    vim.lsp.config("gopls", {
        cmd = { "gopls" },
        filetypes = { "go", "gomod", "gowork", "gotmpl" },
    })
    vim.lsp.config("marksman", {
        cmd = { "marksman", "server" },
        filetypes = { "markdown" },
    })
    vim.lsp.config("ty", {
        cmd = { "ty", "server" },
        filetypes = { "python" },
    })
    vim.lsp.enable({
        "lua_ls",
        "gopls",
        "marksman",
        "ty",
        "tinymist",
    })
    vim.lsp.enable({
        "tinymist", --> for Typst
        "ty",   --> for Python
        "gopls", --> for Go
        "marksman", --> for markdown
        "lua-ls", --> for Lua
    })
end

return M
