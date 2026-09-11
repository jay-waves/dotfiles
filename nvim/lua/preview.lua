-- Markdown and Typst have independent previews; only dependencies live here.
local M = {}
local state = { exiting = false }
local server
local task_id = "nvim_browsing_preview"
local root = vim.fs.joinpath(vim.fn.stdpath("config"), "lua")

local function notify(message)
    vim.notify(message, vim.log.levels.ERROR, { title = "Typst Preview" })
end

local function close_wrapper()
    local wrapper = state.wrapper
    state.wrapper, state.url = nil, nil
    if wrapper then
        server.send_event(wrapper, "typst-close", "{}")
        -- Give libuv a bounded opportunity to flush the event before teardown.
        if state.exiting then
            vim.wait(100, function() return server.connected_client_count(wrapper) == 0 end, 10)
            server.stop(wrapper)
        else
            vim.defer_fn(function() server.stop(wrapper) end, 150)
        end
    end
end

local function open_wrapper(url)
    if not state.wrapper then
        -- TODO: Authenticate both this wrapper and Tinymist's data plane if
        -- preview content or source-location metadata needs protection.
        state.wrapper = server.start({
            host = "127.0.0.1", port = 0, root = root,
            default_index = vim.fs.joinpath(root, "typst.html"),
            live = { enabled = false },
        })
    end
    state.url = url
    if server.connected_client_count(state.wrapper) == 0 then
        local wrapper_url = ("http://127.0.0.1:%d/typst.html?url=%s"):format(
            state.wrapper.port, vim.uri_encode(url))
        local _, err = vim.ui.open(wrapper_url)
        if err then notify(tostring(err)) end
    end
end

local function current_client()
    return vim.lsp.get_clients({ bufnr = 0, name = "tinymist" })[1]
end

local function focus(client, bufnr)
    client:exec_cmd({
        title = "Focus Tinymist Preview", command = "tinymist.focusMain",
        arguments = { vim.api.nvim_buf_get_name(bufnr) },
    }, { bufnr = bufnr })
end

local function kill(client, callback)
    if not client or client:is_stopped() then
        if callback then callback() end
        return
    end
    client:exec_cmd({
        title = "Stop Tinymist Preview", command = "tinymist.doKillPreview",
        arguments = { task_id },
    }, {}, function(err)
        if err and not state.exiting then notify(vim.inspect(err)) end
        if callback then callback() end
    end)
end

function M.typst_stop()
    close_wrapper()
    if state.pending then
        state.cancelled = true
        return
    end
    local client = state.client
    state.client = nil
    if client then
        state.stopping = true
        kill(client, function() state.stopping = false end)
    end
end

function M.typst_start()
    if state.exiting or state.pending then return end
    if state.stopping then return notify("Preview is stopping; retry shortly") end
    local client = current_client()
    if not client then return notify("Tinymist is not attached to the current buffer") end
    if state.client and state.client ~= client then
        return notify("Stop the existing Typst preview before previewing another workspace")
    end
    local bufnr = vim.api.nvim_get_current_buf()
    focus(client, bufnr)
    if state.url then
        open_wrapper(state.url)
        return
    end
    state.pending, state.cancelled = true, false
    client:exec_cmd({
        title = "Start Tinymist Preview", command = "tinymist.doStartBrowsingPreview",
        arguments = { {
            "--data-plane-host=127.0.0.1:0", "--invert-colors=auto",
            "--no-open", "--task-id=" .. task_id,
        } },
    }, { bufnr = bufnr }, function(err, result)
        state.pending = false
        if err then
            if not state.exiting then notify(vim.inspect(err)) end
            return
        end
        if state.exiting or state.cancelled then
            state.stopping = true
            kill(client, function() state.stopping = false end)
            return
        end
        local port = type(result) == "table" and (result.staticServerPort or result.dataPlanePort)
        if type(port) ~= "number" then
            kill(client)
            return notify("Tinymist returned no preview port: " .. vim.inspect(result))
        end
        state.client = client
        local ok, failure = pcall(open_wrapper, ("http://127.0.0.1:%d/"):format(port))
        if not ok then
            M.typst_stop()
            notify(tostring(failure))
        end
    end)
end

function M.setup()
    if M.configured then return end
    M.configured = true
    vim.pack.add({
        "https://github.com/selimacerbas/live-server.nvim",
        "https://github.com/jay-waves/markdown-preview.nvim",
    })
    server = require("live_server.server")
    require("markdown_preview").setup({
        default_theme = "auto", follow_current_buffer = true,
    })

    vim.lsp.config("tinymist", {
        cmd = { "tinymist", "lsp" }, filetypes = { "typst" },
        capabilities = require("blink.cmp").get_lsp_capabilities(),
        root_markers = { ".git" },
        settings = {
            projectResolution = "singleFile", formatterMode = "typstyle",
        },
        handlers = {
            ["tinymist/preview/dispose"] = function(_, result, ctx)
                if result and result.taskId == task_id and state.client
                    and state.client.id == ctx.client_id then
                    state.client = nil
                    close_wrapper()
                end
            end,
        },
    })
    vim.lsp.enable("tinymist")

    vim.api.nvim_create_user_command("TypstPreview", M.typst_start, { desc = "Start or reopen Typst preview" })
    vim.api.nvim_create_user_command("TypstPreviewStop", M.typst_stop, { desc = "Stop Typst preview and close its page" })

    local group = vim.api.nvim_create_augroup("DocumentPreview", { clear = true })
    vim.api.nvim_create_autocmd("FileType", {
        group = group, pattern = "typst",
        callback = function() vim.opt_local.backupcopy = "yes" end,
    })
    vim.api.nvim_create_autocmd("BufEnter", {
        group = group, pattern = "*.typ",
        callback = function(args)
            vim.schedule(function()
                if state.exiting or vim.api.nvim_get_current_buf() ~= args.buf then return end
                local client = current_client()
                if client then focus(client, args.buf) end
            end)
        end,
    })
    vim.api.nvim_create_autocmd("LspDetach", {
        group = group,
        callback = function(args)
            local client = state.client
            if not client or client.id ~= args.data.client_id then return end
            vim.schedule(function()
                if state.client == client and (client:is_stopped() or vim.tbl_isempty(client.attached_buffers)) then
                    M.typst_stop()
                end
            end)
        end,
    })
    vim.api.nvim_create_autocmd("VimLeavePre", {
        group = group,
        callback = function()
            state.exiting = true
            M.typst_stop()
        end,
    })
end

return M
