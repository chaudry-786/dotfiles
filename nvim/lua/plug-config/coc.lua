local keymap = map
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
keymap("n", "<leader>ta", ":call CocAction('diagnosticToggle')<CR>", "Toggle diagnostics")
keymap("i", "<c-j>",
    [[coc#pum#visible() ? coc#pum#next(1) : coc#jumpable() ? "\<c-r>=coc#rpc#request('snippetNext', [])<cr>" : "\<c-j>"]],
    "use CTRL-J and K to move through snippets and auto-completion",true)
keymap("i", "<c-k>",
    [[coc#pum#visible() ? coc#pum#prev(1) : coc#jumpable() ? "\<c-r>=coc#rpc#request('snippetPrev', [])<cr>" : "\<c-k>"]],
    "use CTRL-J and K to move through snippets and auto-completion",true)
keymap("i", "<CR>", [[coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"]], "use CR to complete", true)
keymap("i", "<c-space>", [[coc#refresh()]], "use <C-space> to trigger completion.", true)
keymap("i", "<c-l>", [[<Plug>(coc-snippets-expand-jump)]], "Expand snippet")

-- navigate diagnostics
keymap("n", "[a", "<Plug>(coc-diagnostic-prev)", "Previous diagnostic")
keymap("n", "]a", "<Plug>(coc-diagnostic-next)", "Next diagnostic")

-- goto code navigation.
keymap("n", "gd", "<Plug>(coc-definition)", "Go to definition.")
keymap("n", "gD", ":call CocAction('jumpDefinition', 'vsplit') <CR>", "Go to definition. (vertial split)")
keymap("n", "gy", "<Plug>(coc-type-definition)", "Go to type definition.")
keymap("n", "gi", "<Plug>(coc-implementation)", "Go to implementations.")
keymap("n", "gr", "<Plug>(coc-references)", "Go to references")

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
keymap("n", "K", ":lua Show_documentation() <CR>", "Show documentation. (Hover)")
keymap("n", "<leader>rn", "<Plug>(coc-rename)", "Rename symbol.")

-- formatting
keymap("x", "<leader><leader>f", "<Plug>(coc-format-selected)", "Fromat selected code.")
keymap("n", "<leader><leader>f", ":Format<CR>", "Format buffer.")
keymap("n", "<leader>a", ":<C-u>CocList diagnostics<CR>", "Show all diagnostics (errors and warnings).")

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

-- to allow comments in JSON files
vim.cmd("au BufRead,BufNewFile *.json set filetype=jsonc")
