local keymap = vim.keymap.set
local expr_opts = { noremap = true, silent = true, expr = true }
local opts = { noremap = true, silent = true }

if vim.g.vscode then
    Vscode = require("vscode-neovim")
end

--  symbol renaming.
keymap("n", "<leader>rn", function()
    Vscode.call("editor.action.rename")
end, {})

-- formatting
keymap("x", "<leader><leader>f", function()
    Vscode.call("editor.action.formatSelection")
end, {})
keymap("n", "<leader><leader>f", function()
    Vscode.call("editor.action.formatDocument")
end, opts)

-- -- navigate diagnostics
keymap("n", "]a", function()
    Vscode.call("editor.action.marker.next")
end, { silent = true })
keymap("n", "[a", function()
    Vscode.call("editor.action.marker.prev")
end, { silent = true })

keymap("i", "<c-j>",
    function()
        Vscode.call("selectNextSuggestion")
    end,
    opts)

-- keymap("i", "<c-k>",
--     function()
--         Vscode.call("selectPrevSuggestion")
--     end,
--     opts)

--
-- -- use CR to complete
-- keymap("i", "<CR>", [[coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"]], expr_opts)
--
-- keymap("i", "<c-l>", [[<Plug>(coc-snippets-expand-jump)]], {})
-- -- use CTRL-J and K to move through snippets and auto-completion


-- Jupyter
-- -- {
-- "key": "ctrl+enter",
-- "command": "jupyter.runcurrentcell",
-- "when": "editorTextFocus && isWorkspaceTrusted && jupyter.hascodecells && !editorHasSelection && !jupyter.havenativecells && !notebookEditorFocused"
-- }
keymap("n", "<leader>rc",
    function()
        Vscode.call("jupyter.runcurrentcell")
        print("another hello")
    end,
    opts)

keymap("n", "<leader>rC",
    function()
        Vscode.call("jupyter.runallcellsabove.palette")
        print("another hello")
    end,
    opts)
--     {
--     "key": "",
--     "command": "jupyter.runallcellsabove.palette"
--   }
-- --
-- Run
-- { "n", "<leader>rc", ":call jukit#send#section(0)<cr>",               "Run current cell" },
-- { "n", "<leader>rC", "::call jukit#send#until_current_section()<cr>", "Run cells until cursor" },
-- { "v", "<leader>rc", ":<C-U>call jukit#send#selection()<cr>",         "Run visually highlighted" },
--
-- -- cells
-- { "n", "<leader>co", ":call jukit#cells#create_below(0)<cr>",         "Create new code cell below" },
-- { "n", "<leader>cO", ":call jukit#cells#create_above(0)<cr>",         "Create new code cell above" },
-- { "n", "<leader>ct", ":call jukit#cells#create_below(1)<cr>",         "Create new text cell below" },
-- { "n", "<leader>cT", ":call jukit#cells#create_above(1)<cr>",         "Create new text cell above" },
-- { "n", "<leader>cd", ":call jukit#cells#delete()<cr>",                "Delete current cell" },
-- { "n", "<leader>cs", ":call jukit#cells#split()<cr>",                 "Split current cell" },
-- { "n", "<leader>cM", ":call jukit#cells#merge_above()<cr>",           "Merge current cell with cell above" },
-- { "n", "<leader>cm", ":call jukit#cells#merge_below()<cr>",           "Merge current cell with cell below" },
-- { "n", "<leader>ck", ":call jukit#cells#move_up()<cr>",               "Move current cell up" },
-- { "n", "<leader>cj", ":call jukit#cells#move_down()<cr>",             "Move current cell down" },
-- { "n", "]c",         ":call jukit#cells#jump_to_next_cell()<cr>",     "Jump to next cell below" },
-- { "n", "[c",         ":call jukit#cells#jump_to_previous_cell()<cr>", "Jump to previous cell above" },
-- -- ("n", "<leader>ddo", ":call jukit#cells#delete_outputs(0)<cr>", "Delete saved output of current cell")},
-- -- ("n", "<leader>dda", ":call jukit#cells#delete_outputs(1)<cr>", "Delete saved outputs of all cells")},
--
-- -- Conversion to files
-- { "n", "<leader>Cb", ":call jukit#convert#notebook_convert('jupyter-notebook')<cr>",
--     "Convert from ipynb to py or vice versa" },
-- { "n", "<leader>Ch", ":call jukit#convert#save_nb_to_file(0, 1, 'html')<cr>", "Convert file to html" },
-- { "n", "<leader>CH", ":call jukit#convert#save_nb_to_file(1, 1, 'html')<cr>",
--     "Convert file to html and rerun all cells" },
-- { "n", "<leader>Cp", ":call jukit#convert#save_nb_to_file(0, 1, 'pdf')<cr>",  "Convert file to pdf" },
-- { "n", "<leader>CP", ":call jukit#convert#save_nb_to_file(1, 1, 'pdf')<cr>",
--     "Convert file to pdf and rerun all cells" }
