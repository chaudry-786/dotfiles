local keymap = e_map
keymap("n", "<leader>rt", ":TestNearest<CR>", "Run nearest test.")
keymap("n", "<leader>rT", ":TestFile<CR>", "Run tests on entire file.")
keymap("n", "<leader>rl", ":TestLast<CR>", "Run last test.")
keymap("n", "<leader>rs", ":TestSuite<CR>", "Run entire test suite.")

if vim.g.vscode then
    -- Custom vim-test Strategy for VS Code Terminal
    -- Runs test commands in the VS Code terminal when using Neovim in VS Code.
    -- Focuses the terminal, clears it, and sends the test command.
    local vscode = require("vscode-neovim")
    function VSCodeStrategyLua(cmd)
        -- Remove 'vscode-remote://wsl%2Bubuntu' prefix from the command
        local clean_cmd = cmd:gsub([[vscode%-remote://wsl%%2Bubuntu]], "")
        vscode.action("workbench.action.terminal.focus")
        vscode.action("workbench.action.terminal.sendSequence", { args = { text = "clear\n" } })
        vscode.action("workbench.action.terminal.sendSequence", { args = { text = clean_cmd .. "\n" } })
        vscode.action("workbench.action.focusActiveEditorGroup")
    end

    vim.cmd([[
        function! VSCodeStrategy(cmd)
            lua VSCodeStrategyLua(vim.api.nvim_eval("a:cmd"))
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
