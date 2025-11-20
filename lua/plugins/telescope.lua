return {
	{
		"nvim-telescope/telescope.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		keys = {
			{ "<leader>f", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
			{ "<leader>s", "<cmd>Telescope live_grep<cr>", desc = "Live Grep" },
			{ "<leader>b", "<cmd>Telescope buffers<cr>", desc = "Find Buffers" },
			{ "<leader>d", "<cmd>Telescope diagnostics<cr>", desc = "Find Diagnostics" },
		},
		opts = function()
			local actions = require("telescope.actions")
			return {
				defaults = {
					layout_strategy = "horizontal",
					mappings = {
						i = {
							["<Esc>"] = actions.close,
						},
					},
				},
			}
		end,
		config = function(_, opts)
			local telescope = require("telescope")
			telescope.setup(opts)

			local colors = {
				TelescopeBorder = { bg = "none" },
				TelescopeNormal = { bg = "none" },
				TelescopePromptNormal = { bg = "none" },
				TelescopeResultsNormal = { bg = "none" },
				TelescopePreviewNormal = { bg = "none" },
				TelescopePromptBorder = { bg = "none" },
				TelescopeResultsBorder = { bg = "none" },
				TelescopePreviewBorder = { bg = "none" },
				TelescopeTitle = { bg = "none" },
				TelescopePromptTitle = { bg = "none" },
				TelescopeResultsTitle = { bg = "none" },
				TelescopePreviewTitle = { bg = "none" },
			}

			for hl, col in pairs(colors) do
				vim.api.nvim_set_hl(0, hl, col)
			end
		end,
	},
}
