local function send_commands_to_tmux_pane(filetype_and_commands)
    for fileType, command in pairs(filetype_and_commands) do
        command = string.format(command, [[bufname("%")]])
        vim.api.nvim_create_autocmd("FileType",
            {
                group = "CustomAutoCmds",
                pattern = { fileType },
                command = "noremap <silent><buffer> <Leader>xf :call VimuxRunCommand(" ..
                command .. [[)<CR>]]
            })
    end
end

-- Note % needs to be escaped. to literally use %%
local filetype_and_commands = {
    python = [["clear; src; python " . %s ]],
    lua = [["clear; lua " . %s ]],
    javascript = [["clear; node " . %s ]],
    c = [["clear; gcc " . %s .  " -o " . expand("%%:t:r") . " && ./" . expand("%%:t:r")]]
}
send_commands_to_tmux_pane(filetype_and_commands)

vim.g.VimuxHeight = 30
vim.g.VimuxOrientation = "h"
