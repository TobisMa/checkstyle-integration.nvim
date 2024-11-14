local checkstyle = require("checkstyle-integration");

if vim.g.checkstyle_file == nil then
    vim.fn.printf("Checkstyle: No checkstyle file")

else
    if vim.g.checkstyle_on_write then
        vim.api.nvim_create_autocmd("BufWritePost", {
            desc="Run checkstyle on save",
            group=vim.api.nvim_create_augroup("java-checkstyle-on-save", {clear=true}),
            pattern={"*.java"},
            callback=checkstyle.java_checkstyle
        })
    end

    vim.api.nvim_create_user_command("Jcheck", checkstyle.java_checkstyle, {})
end
