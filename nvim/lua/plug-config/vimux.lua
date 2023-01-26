vim.api.nvim_create_autocmd("FileType",
    { group = "CustomAutoCmds", pattern = { "python" },
        command = [[noremap <silent><buffer> <Leader>x :call VimuxRunCommand("clear; src; python " . bufname("%"))<CR>]] })
-- do not send <CR>
-- command = [[noremap <silent><buffer> <Leader>x :call VimuxRunCommand("clear; src; python " . bufname("%"), 0)<CR>]] })
vim.api.nvim_create_autocmd("FileType",
    { group = "CustomAutoCmds", pattern = { "c" },
        command = [[noremap <silent><buffer> <Leader>x :call VimuxRunCommand("clear; gcc " . bufname("%") . " -o " . expand("%:t:r") . " && ./" . expand("%:t:r") )<CR>]] })

vim.g.VimuxHeight = 30
vim.g.VimuxOrientation = "h"
