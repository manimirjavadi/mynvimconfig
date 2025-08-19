return {
	"neovim/nvim-lspconfig",
	dependencies = { "williamboman/mason-lspconfig.nvim" },
	opts = function(_, opts)
		local util = require("lspconfig.util")
		opts.servers = opts.servers or {}

		-- Ensure vtsls is configured (craftzdog often uses vtsls by default)
		opts.servers.vtsls = vim.tbl_deep_extend("force", opts.servers.vtsls or {}, {
			root_dir = util.root_pattern("tsconfig.json", "package.json", ".git"),
			settings = {
				-- ↓↓↓ These are the keys vtsls reads and forwards to TS
				typescript = {
					preferences = {
						importModuleSpecifier = "non-relative",
						importModuleSpecifierPreference = "non-relative", -- legacy key for older TS
						importModuleSpecifierEnding = "auto",
					},
					suggest = { completeFunctionCalls = true },
					updateImportsOnFileMove = { enabled = "always" },
					inlayHints = {
						parameterNames = { enabled = "literals" },
						parameterTypes = { enabled = true },
						variableTypes = { enabled = false },
						propertyDeclarationTypes = { enabled = true },
						functionLikeReturnTypes = { enabled = true },
						enumMemberValues = { enabled = true },
					},
				},
				javascript = {
					preferences = {
						importModuleSpecifier = "non-relative",
						importModuleSpecifierPreference = "non-relative",
						importModuleSpecifierEnding = "auto",
					},
					suggest = { completeFunctionCalls = true },
					updateImportsOnFileMove = { enabled = "always" },
					inlayHints = {
						parameterNames = { enabled = "literals" },
						parameterTypes = { enabled = true },
						variableTypes = { enabled = false },
						propertyDeclarationTypes = { enabled = true },
						functionLikeReturnTypes = { enabled = true },
						enumMemberValues = { enabled = true },
					},
				},
				vtsls = {
					autoUseWorkspaceTsdk = true,
					enableMoveToFileCodeAction = true,
					experimental = {
						completion = { enableServerSideFuzzyMatch = true },
						maxInlayHintLength = 30,
					},
				},
			},
		})

		return opts
	end,
}
