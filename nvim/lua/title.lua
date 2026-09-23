local M = {}

function M.setup()
  -- 保存原始标题配置
  local original = {
    title = vim.o.title,
    titlestring = vim.o.titlestring,
  }

  local group = vim.api.nvim_create_augroup("BufTitle", {
    clear = true,
  })

  local function restore()
    vim.o.titlestring = original.titlestring
    vim.o.title = original.title
  end

  -- 进入 Buffer 或窗口时更新标题
  vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
    group = group,
    callback = function()
      if vim.bo.buftype ~= "" then
        restore()
        return
      end

      vim.o.title = true
      vim.o.titlestring = "%t"
    end,
  })

  -- 离开窗口时恢复原始标题
  vim.api.nvim_create_autocmd("WinLeave", {
    group = group,
    callback = restore,
  })
end

return M
