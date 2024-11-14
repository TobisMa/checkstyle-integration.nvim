local M = {};

function M.setup(opts) 
    opts = opts or {};
    if opts.keybind ~= nil then
        vim.keymap.set(opts.keybind.modes or {"n"}, opts.keybind.keys, "<CMD>Jcheck<CR>", opts.keybind.options);
    end

    if opts.checkstyle_on_write then
        vim.api.nvim_create_autocmd("BufWritePost", {
            desc="Run checkstyle on save",
            group=vim.api.nvim_create_augroup("java-checkstyle-on-save", {clear=true}),
            pattern={"*.java"},
            callback=M.java_checkstyle
        })
    end
end


function M.java_checkstyle()
    -- TODO use vim.system() for not blocking
    local output = vim.fn.system({"checkstyle", "-f=plain", "-c", vim.g.checkstyle_file, vim.fn.expand("%")});
    local namespace = vim.api.nvim_create_namespace("checkstyle")
    local diagnostics = {};
    local severity, line_n, line_col, message, d, line_count;
    line_count = 0
    for line in output:gmatch("[^\r\n]+") do
        if line:sub(0, 1) ~= '[' then
            goto continue
        end
        line_count = line_count + 1;
        -- _, _, severity = string.find(line, "%[(.-)%]")
        _, _, line_n = string.find(line, ":(%d+):")
        _, _, line_col = string.find(line, ":%d+:(%d+):")
        _, _, message = string.find(line, ":%d+: ([^ ].*)")


        d = {
            bufnr = 0,
            lnum = tonumber(line_n) - 1,
            end_lnum = tonumber(line_n) - 1,
            severity = vim.diagnostic.severity.ERROR,
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

    vim.diagnostic.set(
        namespace,
        0,
        diagnostics,
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
end
return M;
