vim.pack.add{
	{ src = 'https://github.com/neovim/nvim-lspconfig', rev = '9ccd58a7949091c0cc2777d4e92a45a209c808c1' },
	{ src = 'https://github.com/seblyng/roslyn.nvim', rev = 'ff43201090361b8936e008a006473b59ef2c0ca6' },
	{ src = 'https://github.com/hrsh7th/cmp-nvim-lsp', rev = 'cbc7b02bb99fae35cb42f514762b89b5126651ef' },
	{ src = 'https://github.com/hrsh7th/nvim-cmp', rev = 'a1d504892f2bc56c2e79b65c6faded2fd21f3eca' },
	{ src = 'https://github.com/L3MON4D3/LuaSnip', rev = 'a62e1083a3cfe8b6b206e7d3d33a51091df25357' },
	{ src = 'https://github.com/arnamak/stay-centered.nvim', rev = 'e1a63ccaf2584e97c0ef8e64f9654c9a80d983f6' },
	{ src = 'https://github.com/nvim-treesitter/nvim-treesitter', rev = '4916d6592ede8c07973490d9322f187e07dfefac' },
	{ src = 'https://github.com/catppuccin/nvim', rev = '426dbebe06b5c69fd846ceb17b42e12f890aedf1' },
	{ src = 'https://github.com/onsails/lspkind.nvim', rev = 'c7274c48137396526b59d86232eabcdc7fed8a32' },
	{ src = 'https://github.com/nvim-tree/nvim-web-devicons', rev = '95b7a002d5dba1a42eb58f5fac5c565a485eefd0' },
	{ src = 'https://github.com/nvim-lualine/lualine.nvim', rev = '8811f3f3f4dc09d740c67e9ce399e7a541e2e5b2' },
	{ src = 'https://github.com/nvim-tree/nvim-tree.lua', rev = '509962f21ab7289d8dcd28568af539be39a8c01e' },
	{ src = 'https://github.com/akinsho/bufferline.nvim', rev = '655133c3b4c3e5e05ec549b9f8cc2894ac6f51b3' },
  { src = 'https://github.com/famiu/bufdelete.nvim', rev = 'f6bcea78afb3060b198125256f897040538bcb81' },
  { src = 'https://github.com/nvim-lua/plenary.nvim', rev = '74b06c6c75e4eeb3108ec01852001636d85a932b' },
  { src = 'https://github.com/nvim-telescope/telescope.nvim', rev = '48d2656e54d3e3953ae647153ccdaffa50d4d76b' },
  { src = 'https://github.com/lewis6991/gitsigns.nvim', rev = '8d82c240f190fc33723d48c308ccc1ed8baad69d' },
}

-- Disable netrw at the very start for nvim-tree
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.opt.termguicolors = true    -- Enable 24-bit colors

-- File Explorer
---@type nvim_tree.config
local fileTreeConfig = {
	view = {
		side = "right"
	}
}
require("nvim-tree").setup(fileTreeConfig)

-- General vim configuration
vim.opt.number = true		    -- Enable line numbers
vim.opt.relativenumber = true	-- Enable relative line numbers
-- Set tab spaces
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.expandtab = true
vim.opt.signcolumn = "yes" -- Always show diagnostics sign column

--------------------------
-- Keymap configuration --
--------------------------
-- LSP specific keymaps can be found at their own section
vim.g.mapleader = " " -- Map leader to <space>
-- Diagnostics
vim.keymap.set('n', 'gh', vim.diagnostic.open_float) -- Show diagnostic message in a floating window
-- 'float = true' automatically opens the diagnostic float window
-- Jump to the NEXT diagnostic
vim.keymap.set('n', ']d', function()
	vim.diagnostic.jump({ count = 1, float = true })
end, { desc = 'Jump to next diagnostic' })
-- Jump to the PREVIOUS diagnostic
vim.keymap.set('n', '[d', function()
	vim.diagnostic.jump({ count = -1, float = true })
end, { desc = 'Jump to previous diagnostic' })
-- Move between windows using <Ctrl> + direction
vim.keymap.set('n', '<C-h>', '<C-w>h', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w>l', { desc = 'Move focus to the right window' })
-- Toggle nvim-tree
vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>', { desc = 'Toggle File Explorer' })
-- Focus nvim-tree (without toggling)
vim.keymap.set('n', '<leader>f', ':NvimTreeFocus<CR>', { desc = 'Focus File Explorer' })
-- Navigate buffers
vim.keymap.set('n', '<Tab>', ':bnext<CR>', { desc = 'Next buffer' })
vim.keymap.set('n', '<S-Tab>', ':bprevious<CR>', { desc = 'Previous buffer' })
-- -- Close current buffer (without closing the window)
-- vim.keymap.set('n', '<leader>x', ':bdelete<CR>', { desc = 'Close current buffer' })
-- Use the plugin 'bufdelete' to handle deletion of buffers
vim.keymap.set('n', '<leader>x', ':Bdelete<CR>', { desc = 'Close current buffer' })
-- Searching
local builtin = require('telescope.builtin')
-- Search for files by name (Project-wide)
vim.keymap.set('n', '<leader>pf', builtin.find_files, { desc = 'Find Files' })
-- Search for specific text (Live Grep - Project-wide)
vim.keymap.set('n', '<leader>ps', builtin.live_grep, { desc = 'Project Search (Text)' })
-- Search for text under your cursor
vim.keymap.set('n', '<leader>pw', builtin.grep_string, { desc = 'Search Word under cursor' })
-- List open buffers (The alternative to the top bar we discussed!)
vim.keymap.set('n', '<leader>pb', builtin.buffers, { desc = 'List Buffers' })
-- Search help tags
vim.keymap.set('n', '<leader>ph', builtin.help_tags, { desc = 'Search Help' })
-- Git interactions
local gs = require('gitsigns')
-- Navigation through changes
vim.keymap.set('n', ']c', function()
  if vim.wo.diff then return ']c' end
  vim.schedule(function() gs.next_hunk() end)
  return '<Ignore>'
end, { expr = true, desc = "Next Git hunk" })
vim.keymap.set('n', '[c', function()
  if vim.wo.diff then return '[c' end
  vim.schedule(function() gs.prev_hunk() end)
  return '<Ignore>'
end, { expr = true, desc = "Previous Git hunk" })
-- Preview the change in a floating window
vim.keymap.set('n', '<leader>gp', gs.preview_hunk, { desc = "Preview Git hunk" })
-- Reset the current hunk (undo changes to that specific block)
vim.keymap.set('n', '<leader>gr', gs.reset_hunk, { desc = "Reset Git hunk" })

-- Treesitter
require('nvim-treesitter').setup {
	highlight = {
		enable = true,  -- Switch for colors
		additional_vim_regex_highlighting = false,
	},
	-- Directory to install parsers and queries to (prepended to `runtimepath` to have priority)
	install_dir = vim.fn.stdpath('data') .. '/site'
}

-- Default options for configuration of centering screen at cursor
require('stay-centered').setup({
	-- The filetype is determined by the vim filetype, not the file extension. In order to get the filetype, open a file and run the command:
	-- :lua print(vim.bo.filetype)
	skip_filetypes = {},
	-- Set to false to disable by default
	enabled = true,
	-- allows scrolling to move the cursor without centering, default recommended
	allow_scroll_move = true,
	-- temporarily disables plugin on left-mouse down, allows natural mouse selection
	-- try disabling if plugin causes lag, function uses vim.on_key
	disable_on_mouse = true,
})

-- Git signs
require('gitsigns').setup({
  signs = {
    add          = { text = '┃' },
    change       = { text = '┃' },
    delete       = { text = '_' },
    topdelete    = { text = '‾' },
    changedelete = { text = '~' },
    untracked    = { text = '┆' },
  },
  signcolumn = true,  -- Toggle with `:Gitsigns toggle_signs`
  watch_gitdir = {
    interval = 1000,
    follow_files = true
  },
  attach_to_untracked = true,
  current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
})

-- Completion Engine and Snippets
local cmp = require('cmp')
local lspkind = require('lspkind') -- float window icons

vim.opt.completeopt = { "menu", "menuone", "noselect" }

cmp.setup({
	snippet = {
		expand = function(args)
			require('luasnip').lsp_expand(args.body)
		end,
	},
	mapping = cmp.mapping.preset.insert({
		['<C-b>'] = cmp.mapping.scroll_docs(-4),
		['<C-f>'] = cmp.mapping.scroll_docs(4),
		['<C-Space>'] = cmp.mapping.complete(), -- Manually trigger completion
		['<C-e>'] = cmp.mapping.abort(),
		['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept current item
		['<Tab>'] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_next_item()
			else
				fallback()
			end
		end, { 'i', 's' }),
	}),
	formatting = {
		format = lspkind.cmp_format({
			mode = 'symbol_text',
			maxwidth = 50,
			ellipsis_char = '...',
		})
	},
	sources = cmp.config.sources({
		{ name = 'nvim_lsp' }, -- This pulls from Roslyn/LuaLS
	}, {
		{ name = 'buffer' },
	}),
})

local capabilities = require('cmp_nvim_lsp').default_capabilities()

--------------------------
---- Language Servers ----
--------------------------

-- Language Server keymaps
vim.api.nvim_create_autocmd('LspAttach', {
	group = vim.api.nvim_create_augroup('UserLspConfig', {}),
	callback = function(ev)
		local builtin = require('telescope.builtin')
		local opts = { buffer = ev.buf, remap = false }

		-- Definitions & Navigation
		vim.keymap.set('n', 'gd', builtin.lsp_definitions, opts)
		vim.keymap.set('n', 'gr', builtin.lsp_references, opts)
		vim.keymap.set('n', 'gi', builtin.lsp_implementations, opts)
		vim.keymap.set('n', 'gt', builtin.lsp_type_definitions, opts)
		vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)

		-- Actions
		vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
		vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
	end,
})

-- Lua
vim.lsp.config['lua_ls'] = {
	-- Command and arguments to start the server.
	cmd = { 'lua-language-server' },
	-- Filetypes to automatically attach to.
	filetypes = { 'lua' },
	-- Sets the "workspace" to the directory where any of these files is found.
	-- Files that share a root directory will reuse the LSP server connection.
	-- Nested lists indicate equal priority, see |vim.lsp.Config|.
	root_markers = { { '.luarc.json', '.luarc.jsonc' }, '.git' },
	-- Specific settings to send to the server. The schema is server-defined.
	-- Example: https://raw.githubusercontent.com/LuaLS/vscode-lua/master/setting/schema.json
	capabilities = capabilities,
	settings = {
		Lua = {
			runtime = {
				version = 'LuaJIT',
			}
		}
	}
}
vim.lsp.enable('lua_ls')

-- Bash
vim.lsp.config('bashls', { capabilities = capabilities })
vim.lsp.enable('bashls')

-- Add filetype support for those weird .net files
vim.filetype.add({
	extension = {
		razor = 'razor',
		cshtml = 'razor',
	},
})

-- C#
require('roslyn').setup({
	exe = {
		"roslyn-language-server",
	},
	args = {
		"--logLevel=Information",
		"--extensionLogDirectory=" .. vim.fs.dirname(vim.lsp.log.get_filename()),
		"--stdio",
	},
	config = {
		capabilities = capabilities,
	},
})

-- TypeScript and Vue
local vue_language_server_path = vim.fn.expand('~/.local/share/node/lib/node_modules/@vue/language-server')
local tsserver_filetypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue' }

local vue_plugin = {
	name = '@vue/typescript-plugin',
	location = vue_language_server_path,
	languages = { 'vue' },
	configNamespace = 'typescript',
}

local vtsls_config = {
	capabilities = capabilities,
	settings = {
		vtsls = {
			tsserver = {
				globalPlugins = {
					vue_plugin,
				},
			},
		},
	},
	filetypes = tsserver_filetypes,
}

local ts_ls_config = {
	capabilities = capabilities,
	init_options = {
		plugins = {
			vue_plugin,
		},
	},
	filetypes = tsserver_filetypes,
}

local vue_ls_config = {
	capabilities = capabilities,
}

vim.lsp.config('vtsls', vtsls_config)
vim.lsp.config('vue_ls', vue_ls_config)
vim.lsp.config('ts_ls', ts_ls_config)
vim.lsp.enable({'vtsls', 'vue_ls'})

-- Statusline
require('lualine').setup {
	options = {
		icons_enabled = true,
		theme = 'auto',
		component_separators = { left = '', right = ''},
		section_separators = { left = '', right = ''},
		disabled_filetypes = {
			statusline = {},
			winbar = {},
		},
		ignore_focus = {},
		always_divide_middle = true,
		always_show_tabline = true,
		globalstatus = false,
		refresh = {
			statusline = 1000,
			tabline = 1000,
			winbar = 1000,
			refresh_time = 16, -- ~60fps
			events = {
				'WinEnter',
				'BufEnter',
				'BufWritePost',
				'SessionLoadPost',
				'FileChangedShellPost',
				'VimResized',
				'Filetype',
				'CursorMoved',
				'CursorMovedI',
				'ModeChanged',
			},
		}
	},
	sections = {
		lualine_a = {'mode'},
		lualine_b = {'branch', 'diff', 'diagnostics'},
		lualine_c = {'filename'},
		lualine_x = {'encoding', 'fileformat', 'filetype'},
		lualine_y = {'progress'},
		lualine_z = {'location'}
	},
	inactive_sections = {
		lualine_a = {},
		lualine_b = {},
		lualine_c = {'filename'},
		lualine_x = {'location'},
		lualine_y = {},
		lualine_z = {}
	},
	tabline = {},
	winbar = {},
	inactive_winbar = {},
	extensions = {}
}

-- Bufferline
require("bufferline").setup({
  options = {
    mode = "buffers",
    separator_style = "slant", -- Can be "slant" | "slope" | "thick" | "thin"
    diagnostics = "nvim_lsp",  -- Show LSP icons (errors/warnings) on the tabs
    offsets = {
      {
        filetype = "nvim-tree",
        text = "File Explorer",
        text_align = "left",
        separator = true
      }
    },
    exclude_ft = { "nvim-tree" },
  }
})

-- Color scheme
vim.cmd.colorscheme "catppuccin-mocha" -- or latte, frappe or macchiato

require("catppuccin").setup({
	integrations = {
		cmp = true,
		treesitter = true,
		native_lsp = {
			enabled = true,
			underlines = {
				errors = { "undercurl" },
				hints = { "undercurl" },
				warnings = { "undercurl" },
				information = { "undercurl" },
			},
		},
	},
})

-- Init functions
local function open_nvim_tree()
	-- require("nvim-tree.api").tree.open()
	vim.cmd("NvimTreeOpen")   -- Open tree
	vim.cmd("wincmd p")       -- Focus file buffer
end

-- Open file explorer at startup
vim.api.nvim_create_autocmd({ "VimEnter" }, {
	callback = open_nvim_tree
})
