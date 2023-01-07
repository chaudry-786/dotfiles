require 'nvim-treesitter.configs'.setup {
    -- TS parsers
    ensure_installed = { "c",
        "python",
        "java",
        "bash",
        "vim",
        "comment",
        "json",
        "javascript",
        "typescript",
        "html",
        "css",
        "lua",
        "regex"
    },

    -- TS modules
    highlight = {
        enable = true,
        disable = { "rust" },
    },

    -- nvim-treesitter/nvim-treesitter-textobjects
    textobjects = {
        select = {
            enable = true,
            -- Automatically jump forward to textobj, similar to targets.vim
            lookahead = true,
            keymaps = {
                ["aC"] = "@class.outer",
                ["iC"] = "@class.inner",
                ["af"] = "@function.outer",
                ["if"] = "@function.inner",
                ["al"] = "@loop.outer",
                ["il"] = "@loop.inner",
                ["ai"] = "@conditional.outer",
                ["ii"] = "@conditional.inner",
                ["ac"] = "@comment.outer",
            },
        },

        move = {
            enable = true,
            set_jumps = true, -- whether to set jumps in the jumplist
            goto_next_start = {
                ["]C"] = "@class.outer",
                ["]f"] = "@function.outer",
                ["]l"] = "@loop.outer",
                ["]i"] = "@conditional.outer",
                ["]c"] = "@comment.outer",
            },
            goto_previous_start = {
                ["[C"] = "@class.outer",
                ["[f"] = "@function.outer",
                ["[l"] = "@loop.outer",
                ["[i"] = "@conditional.outer",
                ["[c"] = "@comment.outer",
            },
        },
    },

    -- Auto tag for typescript, javascript
    autotag = { enable = true }
}

-- context
require'treesitter-context'.setup{
    max_lines = 3, -- How many lines the window should span. Values <= 0 mean no limit.
    separator = "-",
}
--disable by default
vim.cmd(":TSContextDisable")
vim.api.nvim_set_keymap("n", "<leader>tc", ":TSContextToggle<CR>  :echo 'Context toggeled'<CR>", {noremap = true, silent = true})
