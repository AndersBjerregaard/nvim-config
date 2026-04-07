vim.pack.add{
    { src = 'https://github.com/neovim/nvim-lspconfig' },
    { src = 'https://github.com/seblyng/roslyn.nvim' },
    { src = 'https://github.com/hrsh7th/cmp-nvim-lsp' },
    { src = 'https://github.com/hrsh7th/nvim-cmp' },
    { src = 'https://github.com/L3MON4D3/LuaSnip' },
    { src = 'https://github.com/arnamak/stay-centered.nvim' },
    { src = 'https://github.com/nvim-treesitter/nvim-treesitter' },
    { src = 'https://github.com/catppuccin/nvim' },
    { src = 'https://github.com/onsails/lspkind.nvim' },
    { src = 'https://github.com/nvim-tree/nvim-web-devicons' },
    { src = 'https://github.com/nvim-lualine/lualine.nvim' },
    { src = 'https://github.com/nvim-tree/nvim-tree.lua' },
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
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true
-- Always show diagnostics sign column
vim.opt.signcolumn = "yes"

-- Keymap configuration
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

-- Language Servers
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
        -- Pass your standard lspconfig options here
        on_attach = function(client, bufnr)
            -- Your keybindings
        end,
        capabilities = require('cmp_nvim_lsp').default_capabilities(),
    },
})

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
