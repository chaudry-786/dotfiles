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
        "regex",
        "sql"
    },

    -- TS modules
    highlight = {
        enable = true,
        disable = { "rust" },
    },
    incremental_selection = {
        enable = true,
        keymaps = {
            init_selection = "<CR>",
            node_incremental = "<CR>",
            node_decremental = "<BS>",
            scope_incremental = "<Nop>", -- instead use IB
        },
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
                ["aB"] = "@block.outer",
                ["iB"] = "@block.inner",
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
                ["]B"] = "@block.outer",
            },
            goto_next_end = {
                ["]]C"] = "@class.outer",
                ["]]f"] = "@function.outer",
                ["]]l"] = "@loop.outer",
                ["]]i"] = "@conditional.outer",
                ["]]c"] = "@comment.outer",
                ["]]B"] = "@block.outer",
            },
            goto_previous_start = {
                ["[C"] = "@class.outer",
                ["[f"] = "@function.outer",
                ["[l"] = "@loop.outer",
                ["[i"] = "@conditional.outer",
                ["[c"] = "@comment.outer",
                ["[B"] = "@block.outer",
            },
            goto_previous_end = {
                ["[]C"] = "@class.outer",
                ["[]f"] = "@function.outer",
                ["[]l"] = "@loop.outer",
                ["[]i"] = "@conditional.outer",
                ["[]c"] = "@comment.outer",
                ["[]B"] = "@block.outer",
            },
        },
    },

    -- Auto tag for typescript, javascript
    autotag = { enable = true }
}

-- reminder on how to correctly navigate
vim.keymap.set("", "[[", function() vim.notify("START = [f END = []f ") end, { noremap = true, silent = true })
vim.keymap.set("", "][", function() vim.notify("START = [f END = []f ") end, { noremap = true, silent = true })

