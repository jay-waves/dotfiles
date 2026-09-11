--> 最初方案来自： https://github.com/keaising/im-select.nvim/issues/20
--> 仅针对 Microsoft.PinYin 2052 (微软拼音）下的 Neovim 自动输入法切换
--  * 离开 Insert 模式，自动切换为 微软拼音（英文），而不是 Microsoft.English 
--  * 进入 Insert 模式，恢复原本的模式，即微软拼音输入法的中文或英文
--  * 失去焦点后，重新进入，默认返回 微软拼音（英文）
--
--  为什么使用 PinYin 而不是 English？
--  English 完全切换为了另一种输入法，而 PinYin 只是中文输入法的一种英文模式，更轻量。
--  不容易影响系统其他应用。并且，一些标点、快捷键、全半角的上下文可以保持。
--  这在“中文+英文标点”的使用场景中非常方便。

local ffi = require("ffi")

ffi.cdef([[
typedef void* HWND;
typedef unsigned int UINT;
typedef uintptr_t WPARAM;
typedef intptr_t LPARAM;
typedef intptr_t LRESULT;

HWND GetForegroundWindow(void);
HWND ImmGetDefaultIMEWnd(HWND);
LRESULT SendMessageW(HWND, UINT, WPARAM, LPARAM);
]])

local user32 = ffi.load("user32")
local imm32 = ffi.load("imm32")

local WM_IME_CONTROL = 0x0283
local IMC_GETCONVERSIONMODE = 0x0001
local IMC_SETCONVERSIONMODE = 0x0002

local saved_mode

local function ime()
	return imm32.ImmGetDefaultIMEWnd(user32.GetForegroundWindow())
end

local function get()
	return tonumber(
		user32.SendMessageW(
			ime(),
			WM_IME_CONTROL,
			IMC_GETCONVERSIONMODE,
			0
		)
	)
end

local function set(mode)
	user32.SendMessageW(
		ime(),
		WM_IME_CONTROL,
		IMC_SETCONVERSIONMODE,
		mode
	)
end

local M = {}

function M.setup()
	local group = vim.api.nvim_create_augroup("MicrosoftPinyin", {
		clear = true,
	})

	vim.api.nvim_create_autocmd("InsertLeave", {
		group = group,
		callback = function()
			saved_mode = get()
			set(0) -- 微软拼音（英）
		end,
	})

	vim.api.nvim_create_autocmd("InsertEnter", {
		group = group,
		callback = function()
			if saved_mode ~= nil then
				set(saved_mode)
			end
		end,
	})

	--> Windows11 在失去焦点后，总是返回 微软拼音（中）
	--> 即使勾选了：“允许我为每个应用窗口使用不同的输入法”
	--> 另外，聚焦时立即写入，会有和系统输入法程序的竞争状态。延迟一会。
	vim.api.nvim_create_autocmd("FocusGained", {
		group = group,
		callback = function()
			local mode = vim.api.nvim_get_mode().mode

			if mode == "n" then
				vim.defer_fn(function()
					if vim.api.nvim_get_mode().mode == "n" then
						set(0)
					end
				end, 50)
			end
		end,
	})
end

return M
