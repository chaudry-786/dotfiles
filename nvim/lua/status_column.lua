local set = vim.opt

-- status column: fold_col | line_number | sign_col
set.signcolumn = "yes:1"                                -- 1; fixed number of column
-- set.foldcolumn = "1"                                    -- 1; fixed number of column
set.relativenumber = true                               -- without this relative numbers don't update properly

-- Function to determine the fold character for a given line number
local fill_chars = vim.opt.fillchars:get()
local function get_fold_character(line_num)
    local fold_character = ""
    if vim.fn.foldlevel(line_num) <= vim.fn.foldlevel(line_num - 1) then
        fold_character = " "
    else
        fold_character = (vim.fn.foldclosed(line_num) == -1 and fill_chars.foldopen or fill_chars.foldclose)
    end
    local fold_highlight_group = "FoldColumn"
    return "%#" .. fold_highlight_group .. "#" .. fold_character .. "%*"
end

local sign_column = "%s"
local line_number = '%=%{ v:relnum ? v:relnum : v:lnum}'
-- Global function to generate the content for the status column
_G.get_status_column_content = function()
    local fold_character = get_fold_character(vim.v.lnum)
    return sign_column .. line_number .. " "
end
set.statuscolumn = "%!v:lua.get_status_column_content()"


-- Change background of highlight groups to make status-column distinct
local function set_background_color(highlight_groups, bg_color)
    bg_color = bg_color or "#1f1d2e"
    for _, group in ipairs(highlight_groups) do
        local foreground = string.format("%06x", vim.api.nvim_get_hl_by_name(group, true).foreground)
        vim.cmd('highlight ' .. group .. ' guibg=' .. bg_color .. " guifg=#" .. foreground)
    end
end

local function set_background_color_with_delay()
    local highlight_groups_to_change = { "FoldColumn", "SignColumn", "LineNr", "CursorLineNr", "GitSignsAdd",
        "GitSignsChange", "GitSignsDelete", "CocErrorSign", "CocHintSign", "CocInfoSign", "CocWarningSign",
        "NeotestRunning", "NeotestPassed", "NeotestFailed"}
    set_background_color(highlight_groups_to_change)
end

-- Delay execution of set_background_color_with_delay for 2 seconds
-- because some highlights aren't ready that fast
vim.defer_fn(set_background_color_with_delay, 1000)
