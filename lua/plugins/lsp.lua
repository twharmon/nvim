return {
    "neovim/nvim-lspconfig",
    dependencies = {
        { "williamboman/mason.nvim",          config = true },
        { "williamboman/mason-lspconfig.nvim" },
        "hrsh7th/cmp-nvim-lsp", -- Required for nvim-cmp integration
        -- 'saghen/blink.cmp'   -- Alternative: Replace cmp-nvim-lsp with this if using blink
    },
    config = function()
        -- 1. Setup Mason (Installs binaries)
        require("mason").setup()

        -- 2. Setup Mason-LSPConfig
        -- In v2.0, 'automatic_enable = true' is the default.
        -- It automatically runs vim.lsp.enable() for any server installed by Mason.
        require("mason-lspconfig").setup({
            ensure_installed = { "lua_ls", "ts_ls", "pyright", "eslint", "svelte" },
            automatic_installation = true,
        })

        -- 3. Define Global Capabilities (for nvim-cmp)
        -- The '*' wildcard applies this config to ALL servers attached via vim.lsp.enable
        local capabilities = require("cmp_nvim_lsp").default_capabilities()
        vim.lsp.config("*", {
            capabilities = capabilities,
        })

        -- 4. Server-Specific Overrides
        -- Just define the config. Mason will auto-enable the server with these settings.
        vim.lsp.config("lua_ls", {
            settings = {
                Lua = {
                    diagnostics = { globals = { "vim" } },
                },
            },
        })

        -- 5. Keymaps (LspAttach event)
        -- This replaces the old "on_attach" function
        vim.api.nvim_create_autocmd("LspAttach", {
            callback = function(args)
                -- local client = vim.lsp.get_client_by_id(args.data.client_id)
                local opts = { buffer = args.buf }
                local function show_documentation()
                    local float_opts = {
                        focusable = false,
                        close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
                        border = "rounded",
                        source = "always",
                        prefix = " ",
                        scope = "cursor",
                    }
                    local line_diagnostics = vim.diagnostic.get(args.buf, { lnum = vim.fn.line(".") - 1 })
                    if #line_diagnostics > 0 then
                        vim.diagnostic.open_float(nil, float_opts)
                    else
                        vim.lsp.buf.hover({ border = "rounded" })
                    end
                end

                vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
                vim.keymap.set("n", "<leader>k", show_documentation, opts)
                vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename, opts)
                vim.keymap.set({ "n", "v" }, "<leader>a", vim.lsp.buf.code_action, opts)
                vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
            end,
        })
    end,
}
