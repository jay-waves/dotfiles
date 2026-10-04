local M = {}

    --> Quickfick: `cn`, `cp` 
    --> Vimdiff: `]c`, `[c` 
    --> <leader>g: Git difftool + Gitsigns linehl
function M.setup()
    vim.pack.add({
        "https://github.com/tpope/vim-fugitive",
        "https://github.com/lewis6991/gitsigns.nvim",
    })

    require("gitsigns").setup({
      signcolumn = true,
      linehl = false,
      numhl = false,
      word_diff = false,
    })

    local git_diff_active = false

    vim.keymap.set("n", "<leader>g", function()
      local gs = require("gitsigns")

      git_diff_active = not git_diff_active
      gs.toggle_linehl(git_diff_active)

      if git_diff_active then
        vim.cmd("Git difftool")
      else
        vim.cmd("cclose")
      end
    end, {
      desc = "Toggle Git difftool",
    })

end

return M
