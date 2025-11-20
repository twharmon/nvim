vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.g.have_nerd_font = false
vim.o.number = true
vim.o.mouse = "a"
vim.o.showmode = false
vim.o.breakindent = true
vim.o.undofile = true
vim.o.ignorecase = false
vim.o.smartcase = false
vim.o.signcolumn = "yes"
vim.o.updatetime = 250
vim.o.timeoutlen = 300
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.list = true
vim.opt.listchars = { tab = "  ", trail = "·", nbsp = "␣" }
vim.o.inccommand = "split"
vim.o.cursorline = true
vim.o.cursorlineopt = "both"
vim.o.scrolloff = 5
vim.o.confirm = true
vim.opt.clipboard = "unnamedplus"
vim.opt.ruler = false
vim.o.showcmd = false
vim.opt.shortmess:append("c")
vim.opt.shortmess:append("W")
vim.opt.shortmess:append("sI")
vim.opt.shortmess:append("S")
vim.opt.wrap = false

-- key bindings
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.keymap.set("n", "<leader>w", "<cmd>w<CR>", { desc = "[W]rite buffer" })
vim.keymap.set("n", "<leader>q", "<cmd>q<CR>", { desc = "[Q]uit Neovim" })
vim.keymap.set("n", "<leader>c", "<cmd>bd<CR>", { desc = "[C]lose buffer" })
vim.keymap.set("n", "U", "<C-r>", { desc = "Redo (Custom)" })
vim.keymap.set("n", "<C-c>", "gcc", { desc = "Toggle Comment", remap = true })
vim.keymap.set("v", "<C-c>", "gc", { desc = "Toggle Comment", remap = true })

require("config.lazy")

vim.diagnostic.config({
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = "",
            [vim.diagnostic.severity.WARN] = "",
            [vim.diagnostic.severity.HINT] = "",
            [vim.diagnostic.severity.INFO] = "",
        },
        severity = {
            min = vim.diagnostic.severity.HINT,
        },
    },
    underline = {
        severity = {
            min = vim.diagnostic.severity.HINT,
        },
    },
    jump = {
        severity = {
            min = vim.diagnostic.severity.HINT,
        },
    },
    float = {
        severity = {
            min = vim.diagnostic.severity.HINT,
        },
        border = "rounded",
        wrap = true,
    },
})

require("catppuccin").setup({
    flavour = "auto",
    custom_highlights = function(colors)
        return {
            CursorLineNr = { bg = "#2a2b3c", fg = colors.lavender, style = { "bold" } },
            CursorLineSign = { bg = "#2a2b3c", fg = colors.lavender, style = { "bold" } },
            NormalFloat = { bg = colors.base },
            FloatBorder = { bg = colors.base, fg = colors.text },
            DiagnosticLineNrError = { fg = colors.red, style = { "bold" } },
            DiagnosticLineNrWarn = { fg = colors.yellow, style = { "bold" } },
            DiagnosticLineNrInfo = { fg = colors.blue, style = { "bold" } },
            DiagnosticLineNrHint = { fg = colors.teal, style = { "bold" } },
        }
    end,
})
vim.cmd.colorscheme("catppuccin")

require("lualine").setup({
    options = {
        icons_enabled = false,
        section_separators = "",
        component_separators = "",
        refresh = {
            statusline = 250,
        },
    },
    sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch" },
        lualine_c = {
            "filename",
            {
                "diagnostics",
                symbols = {
                    error = " ● ",
                    warn = " ● ",
                    info = " ● ",
                    hint = " ● ",
                },
                colored = true,
                source = "nvim_lsp",
            },
        },
        lualine_x = { "selectioncount", "searchcount" },
        lualine_z = {
            {
                function()
                    return "%l:%c / %L"
                end,
                padding = { left = 1, right = 1 }, -- Optional: Adjust outer padding
            },
        },
        lualine_y = {
            {
                "filetype",
                color = { gui = "bold" },
            },
        },
    },
})

local function handle_esc()
    vim.cmd.nohlsearch()
    local closed_count = 0
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        local config = vim.api.nvim_win_get_config(win)
        if config.relative ~= "" then
            vim.api.nvim_win_close(win, false)
            closed_count = closed_count + 1
        end
    end
    vim.cmd("echo ''")
    if closed_count == 0 then
        vim.cmd("normal! " .. vim.api.nvim_replace_termcodes("<Esc>", true, true, true))
    end
end
vim.keymap.set("n", "<Esc>", handle_esc, { desc = "Close all floating windows" })

-- Custom Diagnostic Logic: Color Line Numbers based on Severity
local ns = vim.api.nvim_create_namespace("DiagnosticLineNr")

-- Map severity to Highlight Groups (using Catppuccin's groups)
local severity_hl = {
    [vim.diagnostic.severity.ERROR] = "DiagnosticLineNrError",
    [vim.diagnostic.severity.WARN] = "DiagnosticLineNrWarn",
    [vim.diagnostic.severity.INFO] = "DiagnosticLineNrInfo",
    [vim.diagnostic.severity.HINT] = "DiagnosticLineNrHint",
}

vim.api.nvim_create_autocmd("DiagnosticChanged", {
    callback = function(args)
        local buf = args.buf
        local diagnostics = args.data.diagnostics
        vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
        local line_severity = {}
        for _, d in ipairs(diagnostics) do
            local line = d.lnum
            local current = line_severity[line]
            if not current or d.severity < current then -- Lower val = Higher severity
                line_severity[line] = d.severity
            end
        end
        for line, severity in pairs(line_severity) do
            local hl_group = severity_hl[severity]
            vim.api.nvim_buf_set_extmark(buf, ns, line, 0, {
                number_hl_group = hl_group,
                priority = 100,
            })
        end
    end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*",
    callback = function(args)
        vim.lsp.buf.format({
            bufnr = args.buf,
            lsp_fallback = true,
        })
    end,
})
