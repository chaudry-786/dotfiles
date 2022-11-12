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
                ["ac"] = "@conditional.outer",
                ["ic"] = "@conditional.inner",
            },
        },

        move = {
            enable = true,
            set_jumps = true, -- whether to set jumps in the jumplist
            goto_next_start = {
                ["]C"] = "@class.outer",
                ["]f"] = "@function.outer",
                ["]l"] = "@loop.outer",
                ["]c"] = "@conditional.outer",
            },
            goto_previous_start = {
                ["[C"] = "@class.outer",
                ["[f"] = "@function.outer",
                ["[l"] = "@loop.outer",
                ["[c"] = "@conditional.outer",
            },
        },
    },
}

-- context
require'treesitter-context'.setup{
    max_lines = 3, -- How many lines the window should span. Values <= 0 mean no limit.
    separator = "-",
}
