local M = {}

-- Use each theme's native transparency settings for mixed backgrounds.
local themes = {
  github_dark = {
    name = "github_dark_tritanopia",
    lualine = "auto",
    module = "github-theme",
    options = { options = { transparent = true } },
  },
  nord = {
    name = "nord",
    lualine = "nord",
    setup = function()
      vim.g.nord_disable_background = true
    end,
  },
  catppuccin_mocha = {
    name = "catppuccin-mocha",
    lualine = "catppuccin-nvim",
    module = "catppuccin",
    options = { transparent_background = true },
  },
  catppuccin_macchiato = {
    name = "catppuccin-macchiato",
    lualine = "catppuccin-nvim",
    module = "catppuccin",
    options = { transparent_background = true },
  },
  catppuccin_frappe = {
    name = "catppuccin-frappe",
    lualine = "catppuccin-nvim",
    module = "catppuccin",
    options = { transparent_background = true },
  },
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
  vim.opt.background = "dark"
  if theme.module then
    require(theme.module).setup(theme.options)
  elseif theme.setup then
    theme.setup()
  end
  vim.cmd.colorscheme(theme.name)

  require("lualine").setup({
    options = {
      theme = theme.lualine, 
      icons_enabled = true,
      globalstatus = true,
    },

    sections = {
      lualine_a = { "mode" },
      lualine_c = { { "filename", path = 1, } },
      lualine_x = { "filetype" },
      lualine_y = { "progress" },
      -- lualine_z = { "location" },
    },

    tabline = {
      lualine_a = {
        {
          "buffers",
          mode = 0, 
          show_filename_only = true,
          show_modified_status = true,
  		max_length = function()
  			return math.floor(vim.o.columns * 0.9)
  		end,
        }
      },
    },
  })
end

return M

