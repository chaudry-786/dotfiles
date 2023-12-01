local keymap = vim.api.nvim_set_keymap
local expr_opts = { noremap = true, silent = true, expr = true }
local opts = { noremap = true, silent = true }

-------------------------------------------------
-- Extensions
-------------------------------------------------
vim.g["coc_global_extensions"] = {
    "coc-json",                     -- LSP for JSON
    "coc-yaml",                     -- LSP for YAML
    "coc-pyright",                  -- LSP for python
    "coc-java",                     -- LSP for java
    "coc-tsserver",                 -- LSP for typescript and javascript
    "coc-eslint",                   -- Linter for typescript and javascript
    "@yaegassy/coc-tailwindcss3",   -- LSP for tailwindcss3
    "coc-sh",                       -- LSP for bash
    "coc-sumneko-lua",              -- LSP for lua, neovim autocompletion included
    "coc-rust-analyzer",            -- LSP for rust
    "coc-clangd",                   -- LSP for c
    "coc-sql",                      -- LSP for .sql files
    "coc-vimlsp",                   -- LSP for vimscript
    "coc-lists",                    -- Lists e.g buffers, symbols
    "coc-snippets",                 -- Snippet support
    "coc-marketplace",              -- Browse coc extensions
    "coc-prettier",                 -- Formatter for javascript, typescript and JSON
    "coc-htmldjango",               -- Format, Lint and compl for html-django (jinja templating)
    "coc-html-css-support",         -- CSS completion
}

-------------------------------------------------
-- Key Mappings
-------------------------------------------------
-- toggle diagnostics
keymap("n", "<leader>ta", ":call CocAction('diagnosticToggle')<CR>", {})

-- use CTRL-J and K to move through snippets and auto-completion
keymap("i", "<c-j>",
    [[coc#pum#visible() ? coc#pum#next(1) : coc#jumpable() ? "\<c-r>=coc#rpc#request('snippetNext', [])<cr>" : "\<c-j>"]],
    expr_opts)
keymap("i", "<c-k>",
    [[coc#pum#visible() ? coc#pum#prev(1) : coc#jumpable() ? "\<c-r>=coc#rpc#request('snippetPrev', [])<cr>" : "\<c-k>"]],
    expr_opts)

-- use CR to complete
keymap("i", "<CR>", [[coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"]], expr_opts)

-- use <C-space> to trigger completion.
keymap("i", "<c-space>", [[coc#refresh()]], expr_opts)

-- expand snippet
keymap("i", "<c-l>", [[<Plug>(coc-snippets-expand-jump)]], {})

-- navigate diagnostics
keymap("n", "[a", "<Plug>(coc-diagnostic-prev)", { silent = true })
keymap("n", "]a", "<Plug>(coc-diagnostic-next)", { silent = true })

-- goto code navigation.
keymap("n", "gd", "<Plug>(coc-definition)", { silent = true })
keymap("n", "gD", ":call CocAction('jumpDefinition', 'vsplit') <CR>", { silent = true })
keymap("n", "gy", "<Plug>(coc-type-definition)", { silent = true })
keymap("n", "gi", "<Plug>(coc-implementation)", { silent = true })
keymap("n", "gr", "<Plug>(coc-references)", { silent = true })

-- show documentation
function Show_documentation()
    local filetype = vim.bo.filetype
    if filetype == "vim" or filetype == "help" then
        vim.api.nvim_command("h " .. vim.fn.expand("<cword>"))
    elseif vim.fn["coc#rpc#ready"]() then
        vim.fn.CocActionAsync("doHover")
    else
        vim.api.nvim_command(
            "!" .. vim.bo.keywordprg .. " " .. vim.fn.expand("<cword>")
        )
    end
end
keymap("n", "K", ":lua Show_documentation() <CR>", opts)

-- symbol renaming.
keymap("n", "<leader>rn", "<Plug>(coc-rename)", {})

-- formatting
keymap("x", "<leader><leader>f", "<Plug>(coc-format-selected)", {})
keymap("n", "<leader><leader>f", ":Format<CR>", opts)

-- show all diagnostics (errors and warnings).
keymap("n", "<leader>a", ":<C-u>CocList diagnostics<CR>", opts)

-------------------------------------------------
-- AutoCommands | Commands
-------------------------------------------------
-- highlight the symbol and its references when holding the cursor.
vim.api.nvim_create_autocmd("CursorHold", {
    group = "CustomAutoCmds",
    pattern = "*",
    command = [[call CocActionAsync("highlight")]]
})

-- add `:Format` command to format the current buffer.
vim.api.nvim_create_user_command("Format", ":call CocAction('format')", { nargs = 0 })

-- add `:OI` command for organizing imports of the current buffer.
vim.api.nvim_create_user_command("OI", ":call CocActionAsync('runCommand', 'editor.action.organizeImport')",
    { nargs = 0 })

-- set all html files to htmldjango (coc-htmldjango)
vim.api.nvim_create_autocmd("FileType", {
    group = "CustomAutoCmds",
    pattern = "html",
    command = [[ set filetype=htmldjango ]]
})
