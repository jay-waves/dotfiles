--> use \s as <leader>
vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.number = true
vim.opt.cursorline = true
vim.opt.wrap = false

vim.opt.scrolloff = 10
vim.opt.mousemodel = "extend"

vim.opt.shiftwidth = 4
vim.opt.expandtab = true

-- instead of using im-select to switch to US.English,
-- i want to use PinYin.English.
-- so we need to call the windows imm32.dl directly using the LuaJIT FFI
require("ime").setup()

-- search
vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.keymap.set("n", "j", "gj")
vim.keymap.set("n", "k", "gk")

vim.keymap.set("n", "<leader>h", vim.lsp.buf.hover, {
    desc = "Show documentation",
})

--> Click + Ctrl to jump to file
vim.keymap.set("n", "<C-LeftMouse>", "<LeftMouse>gf")

--> Use Ctrl+S to save file
vim.keymap.set({ "n", "i", "x" }, "<C-s>", "<Cmd>write<CR>", { desc = "Save file" })

--> Use <leader>y, <leader>p to paste/yank system clipboards
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])

vim.keymap.set({ "n", "v" }, "<leader>p", [["+p]])

vim.keymap.set("n", "<leader>ya", function()
    local path = vim.fs.normalize(vim.fn.expand("%:p"))
    vim.fn.setreg("+", path)
    print("Copied: " .. path)
end, { desc = "Copy absolute path" })

vim.keymap.set("n", "<leader>yr", function()
    local path = vim.fs.normalize(vim.fn.expand("%:."))
    vim.fn.setreg("+", path)
    print("Copied: " .. path)
end, { desc = "Copy relative path" })

-- dark themes: nordbones, github, gruvbox, zenbones
-- light themes: github_light, zenwritten_light, patana_light
require("theme").setup("nordbones")

vim.pack.add({
    "https://github.com/nvim-lualine/lualine.nvim",
    "https://github.com/ibhagwan/fzf-lua",
    "https://github.com/nvim-mini/mini.files",
    "https://github.com/nvim-mini/mini.surround",
})

require("cmdline").setup()
require("title").setup()
require("git").setup()

--> PlugIn: Lualine
require("lualine").setup({
    options = {
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

--> PlugIn: Mini.Files, vim-like keymap, and = to save changes
require("mini.files").setup({
    mappings = {
        go_in = "L",
        go_in_plus = "l",
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
end, { desc = "Open Mini.Files", })

vim.keymap.set("n", "<leader>E", function()
    vim.ui.open(vim.fn.getcwd())
end, { desc = "Open Explorer", })

--> PlugIn: FzfLua
vim.keymap.set("n", "<leader>f", "<cmd>FzfLua global<cr>")
vim.keymap.set("n", "<leader>F", "<cmd>FzfLua<cr>")
vim.keymap.set("n", "<leader>/", "<cmd>FzfLua live_grep<cr>")

-- Toggle between splits inside windows
vim.keymap.set("n", "<leader>w", "<C-w>w")
-- Toggle between alternative buffer
vim.keymap.set("n", "<leader><leader>", "<cmd>b#<CR>")

--> `gc` comment selections
--> `gf` jump to file
--> `gv` select last visual selection
--> `[n]gg / [n]G` jump to #n line

--> `==` tab this line
--> `gg=G` tab all fiels

--> `gqq` format this line
--> `gq`  format selections

--> Completion must load before LSP capabilities are configured.
require("completion").setup()

--> Language support: Treesitter and LSP
require("lsp").setup()

--> PlugIn: Mini.Surround
--> `sa` add , with selections
--> `sd` delete, without selection
--> `sr` replace
-->
require("mini.surround").setup({
    custom_surroundings = {
        b = {
            input = { "%*%*().-()%*%*" },
            output = { left = "**", right = "**" },
        },
    },
})

vim.keymap.set("n", "<leader>l", function()
    vim.diagnostic.open_float({
        scope = "line",
        source = true,
    })
end, { desc = "Show line diagnostics" })

vim.keymap.set("n", "<leader>L", function()
    local win = vim.fn.getloclist(0, { winid = 0 }).winid

    if win ~= 0 then
        vim.cmd("lclose")
    else
        vim.diagnostic.setloclist({ open = true })
    end
end, { desc = "Toggle diagnostics loclist" })


