local M = {};

local uv = vim.uv
local DIAGNOSTIC_MAP = {
    IGNORE = vim.diagnostic.severity.INFO,
    INFO = vim.diagnostic.severity.HINT,
    WARN = vim.diagnostic.severity.WARN,
    ERROR = vim.diagnostic.severity.ERROR,
}

function M.setup(opts)
    if opts.checkstyle_file == nil then
        print("No checkstyle file set")
        return
    end

    M.checkstyle_file = opts.checkstyle_file;
    opts = opts or {};
    if opts.keybind ~= nil then
        vim.keymap.set(opts.keybind.modes or { "n" }, opts.keybind.keys, "<CMD>Jcheck<CR>", opts.keybind.options);
    end

    M.force_severity = opts.force_severity
    M.pattern = opts.pattern or { "*.java" }

    if opts.checkstyle_on_write then
        vim.api.nvim_create_autocmd("BufWritePost", {
            desc = "Run checkstyle on save",
            group = vim.api.nvim_create_augroup("java-checkstyle-on-save", { clear = true }),
            callback = M.java_checkstyle,
            pattern = M.pattern
        })
    end

    vim.api.nvim_create_user_command("Jcheck", M.java_checkstyle, {})
end

function M.java_checkstyle()
    local namespace = vim.api.nvim_create_namespace("checkstyle")
    local handle;
    local pid_or_err;
    local stdin = uv.new_pipe(false)
    local stdout = uv.new_pipe(false)
    local stderr = uv.new_pipe(false)
    local diagnostic_result;
    local line_count
    local output = ""

    handle, pid_or_err = uv.spawn("checkstyle", {
        args = { "-f=plain", "-c", vim.fn.expand(M.checkstyle_file), vim.fn.expand("%") },
        cwd = vim.fn.getcwd(),
        hide = vim.fn.has("win32") == 1,
        stdio = { stdin, stdout, stderr }
    }, function(code, signal)
        if code ~= 0 and code ~= 1 then
            vim.schedule(function()
                vim.notify("Code " .. code .. "; Signal " .. signal, vim.diagnostic.severity.WARN)
            end)
        end
    end)
    if not handle then
        print("Handle unexpected close")
        stdin:close()
        stdout:close()
        stderr:close()
        return
    end

    uv.read_start(stdout, function(err, data)
        if err then
            print(err)
            -- TODO
        elseif data then
            output = output .. data
        else
            local result = M._convert_checkstyle_output_to_diagnostic(namespace, output)
            diagnostic_result = result.diagnostics
            line_count = result.line_count
            vim.schedule(function()
                vim.diagnostic.set(
                    namespace,
                    0,
                    diagnostic_result,
                    {
                        virtual_text = true,
                        severity_sort = true,
                        update_in_insert = false
                    }
                )

                local old_cmd_height = vim.o.cmdheight;
                vim.o.cmdheight = old_cmd_height + 1;
                if line_count == 0 then
                    print("You are good to go; No violations from checkstyle found", "")
                elseif line_count == 1 then
                    print("Found", line_count, "check style violation")
                else
                    print("Found", line_count, "check style violations")
                end
                if old_cmd_height == nil then
                    vim.o.cmdheight = 1;
                else
                    vim.o.cmdheight = old_cmd_height;
                end
            end)
        end
    end)
end

function M._convert_checkstyle_output_to_diagnostic(namespace, output)
    local diagnostics = {};
    local severity, line_n, line_col, message, d, line_count;
    line_count = 0

    for line in output:gmatch("[^\r\n]+") do
        if line:sub(0, 1) ~= '[' then
            goto continue
        end
        line_count = line_count + 1;
        _, _, severity = string.find(line, "%[(.-)%]")
        _, _, line_n = string.find(line, ":(%d+):")
        _, _, line_col = string.find(line, ":%d+:(%d+):")
        _, _, message = string.find(line, ":%d+: ([^ ].*)")

        severity = DIAGNOSTIC_MAP[M.force_severity or severity]

        d = {
            bufnr = 0,
            lnum = tonumber(line_n) - 1,
            end_lnum = tonumber(line_n) - 1,
            severity = severity,
            message = message,
            source = "checkstyle",
            namespace = namespace
        };
        if (line_col ~= nil) then
            d.col = tonumber(line_col)
            d.end_col = tonumber(line_col) + 1
        else
            d.col = 0
        end
        table.insert(diagnostics, d)
        ::continue::
    end

    return { diagnostics = diagnostics, line_count = line_count }
end

return M;
