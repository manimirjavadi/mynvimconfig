return {
	-- tools
	{
		"williamboman/mason.nvim",
		opts = function(_, opts)
			vim.list_extend(opts.ensure_installed, {
				"stylua",
				"selene",
				"luacheck",
				"shellcheck",
				"shfmt",
				"tailwindcss-language-server",
				"typescript-language-server",
				"vtsls",
				"css-lsp",
			})
		end,
	},

	-- lsp servers (merge into LazyVim defaults)
	{
		"neovim/nvim-lspconfig",
		opts = function(_, opts)
			local util = require("lspconfig.util")

			opts.inlay_hints = opts.inlay_hints or {}
			opts.servers = opts.servers or {}
			opts.setup = opts.setup or {}
			opts.inlay_hints.enabled = false

			-- Prefer nearest tsconfig.json / package.json (so tsserver actually loads your paths/baseUrl)
			local ts_root = util.root_pattern("tsconfig.json", "package.json", ".git")

			local function merge(dst, src)
				return vim.tbl_deep_extend("force", dst or {}, src or {})
			end

			-- Shared TS/JS settings to force non-relative auto-imports
			local function ts_pref_block()
				return {
					preferences = {
						-- Newer key
						importModuleSpecifier = "non-relative",
						-- Legacy key still used by some tsserver builds
						importModuleSpecifierPreference = "non-relative",
						importModuleSpecifierEnding = "auto",
					},
				}
			end

			local ts_settings = {
				root_dir = ts_root,
				single_file_support = false,
				init_options = { hostInfo = "neovim" },
				settings = {
					typescript = merge(ts_pref_block(), {
						inlayHints = {
							includeInlayParameterNameHints = "literal",
							includeInlayParameterNameHintsWhenArgumentMatchesName = false,
							includeInlayFunctionParameterTypeHints = true,
							includeInlayVariableTypeHints = false,
							includeInlayPropertyDeclarationTypeHints = true,
							includeInlayFunctionLikeReturnTypeHints = true,
							includeInlayEnumMemberValueHints = true,
						},
					}),
					javascript = merge(ts_pref_block(), {
						inlayHints = {
							includeInlayParameterNameHints = "all",
							includeInlayParameterNameHintsWhenArgumentMatchesName = false,
							includeInlayFunctionParameterTypeHints = true,
							includeInlayVariableTypeHints = true,
							includeInlayPropertyDeclarationTypeHints = true,
							includeInlayFunctionLikeReturnTypeHints = true,
							includeInlayEnumMemberValueHints = true,
						},
					}),
				},
			}

			-- Support both server names (some lspconfig versions renamed tsserver -> ts_ls)
			opts.servers.tsserver = merge(opts.servers.tsserver, ts_settings)
			if opts.servers.ts_ls ~= nil then
				opts.servers.ts_ls = merge(opts.servers.ts_ls, ts_settings)
			end

			-- Your other servers (kept as-is)
			opts.servers.cssls = merge(opts.servers.cssls, {})

			opts.servers.eslint = merge(opts.servers.eslint, {
				settings = { workingDirectory = { mode = "auto" } },
			})

			opts.servers.tailwindcss = merge(opts.servers.tailwindcss, {
				root_dir = function(...)
					return util.root_pattern(".git")(...)
				end,
			})

			opts.servers.html = merge(opts.servers.html, {})

			opts.servers.yamlls = merge(opts.servers.yamlls, {
				settings = { yaml = { keyOrdering = false } },
			})

			opts.servers.lua_ls = merge(opts.servers.lua_ls, {
				single_file_support = true,
				settings = {
					Lua = {
						workspace = { checkThirdParty = false },
						completion = { workspaceWord = true, callSnippet = "Both" },
						misc = { parameters = {} },
						hint = {
							enable = true,
							setType = false,
							paramType = true,
							paramName = "Disable",
							semicolon = "Disable",
							arrayIndex = "Disable",
						},
						doc = { privateName = { "^_" } },
						type = { castNumberToInteger = true },
						diagnostics = {
							disable = { "incomplete-signature-doc", "trailing-space" },
							groupSeverity = { strong = "Warning", strict = "Warning" },
							groupFileStatus = {
								ambiguity = "Opened",
								["await"] = "Opened",
								codestyle = "None",
								duplicate = "Opened",
								global = "Opened",
								luadoc = "Opened",
								redefined = "Opened",
								strict = "Opened",
								strong = "Opened",
								["type-check"] = "Opened",
								unbalanced = "Opened",
								unused = "Opened",
							},
							unusedLocalExclude = { "_*" },
						},
						format = {
							enable = false,
							defaultConfig = {
								indent_style = "space",
								indent_size = "2",
								continuation_indent_size = "2",
							},
						},
					},
				},
			})

			-- Fix-on-save, same as your original
			opts.setup.eslint = function()
				vim.cmd([[autocmd BufWritePre *.tsx,*.ts,*.jsx,*.js EslintFixAll]])
			end

			return opts
		end,
	},

	-- your Telescope keymap
	{
		"neovim/nvim-lspconfig",
		opts = function()
			local keys = require("lazyvim.plugins.lsp.keymaps").get()
			vim.list_extend(keys, {
				{
					"gd",
					function()
						require("telescope.builtin").lsp_definitions({ reuse_win = false })
					end,
					desc = "Goto Definition",
					has = "definition",
				},
			})
		end,
	},
}
