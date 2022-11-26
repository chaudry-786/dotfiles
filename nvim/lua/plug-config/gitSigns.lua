require('gitsigns').setup {
    on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, opts)
            opts = opts or {}
            opts.silent = true
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map('n', ']h', function()
            if vim.wo.diff then return ']h' end
            vim.schedule(function() gs.next_hunk() end)
            return '<Ignore>'
        end, { expr = true })

        map('n', '[h', function()
            if vim.wo.diff then return '[h' end
            vim.schedule(function() gs.prev_hunk() end)
            return '<Ignore>'
        end, { expr = true })

        -- Actions
        map({ 'n', 'v' }, '<leader>gha', ':Gitsigns stage_hunk<CR>')
        map({ 'n', 'v' }, '<leader>ghu', ':Gitsigns reset_hunk<CR>')
        map('n', '<leader>ghp', gs.preview_hunk)

        --toggle_signs
        map('n', '<leader>tg', gs.toggle_signs)

        -- Text object
        map({ 'o', 'x' }, 'ah', ':<C-U>Gitsigns select_hunk<CR>')
    end

}
-- Useful toggle
-- Gitsigns toggle_linehl               > highlights changed lines
-- Gitsigns toggle_word_diff            > highlight changed word
-- Gitsigns toggle_deleted              > display deleted text
-- Gitsigns toggle_current_line_blame   > show current line blame info
