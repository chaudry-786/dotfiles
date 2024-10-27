local keymap = e_map
keymap("n", "<leader>rt", ":TestNearest<CR>", "Run nearest test.")
keymap("n", "<leader>rT", ":TestFile<CR>", "Run tests on entire file.")
keymap("n", "<leader>rl", ":TestLast<CR>", "Run last test.")
keymap("n", "<leader>rs", ":TestSuite<CR>", "Run entire test suite.")

if vim.g.vscode then
    -- Custom vim-test Strategy for VS Code Terminal
    -- Runs test commands in the VS Code terminal when using Neovim in VS Code.
    -- Focuses the terminal, clears it, and sends the test command.
    vim.cmd([[
        function! VSCodeStrategy(cmd)
            " Optional: Focus the VS Code terminal
            call VSCodeNotify('workbench.action.terminal.focus')
            " Clear the terminal
            call VSCodeNotify('workbench.action.terminal.sendSequence', {'text': "clear\n"})
            " Send the test command to the terminal
            call VSCodeNotify('workbench.action.terminal.sendSequence', {'text': a:cmd . "\n"})
            " Focus back on the editor
            call VSCodeNotify('workbench.action.focusActiveEditorGroup')
        endfunction

    let g:test#custom_strategies = {'vscode': function('VSCodeStrategy')}
    let g:test#strategy = 'vscode'
    ]])
else
    vim.g["test#strategy"] = "vimux"
end

--language-specific
vim.g["test#python#runner"] = "pytest"
vim.g["test#python#pytest#options"] = "--disable-warnings -s"
