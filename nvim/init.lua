vim.pack.add{
    { src = 'https://github.com/neovim/nvim-lspconfig' },
    { src = 'https://github.com/seblyng/roslyn.nvim' },
    { src = 'https://github.com/hrsh7th/nvim-cmp' },
    { src = 'https://github.com/hrsh7th/cmp-nvim-lsp' },
    { src = 'https://github.com/arnamak/stay-centered.nvim' },
    { src = 'https://github.com/nvim-treesitter/nvim-treesitter' },
}

-- General vim configuration
vim.opt.number = true		-- Enable line numbers
vim.opt.relativenumber = true	-- Enable relative line numbers
-- Set tab spaces
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true

-- Keymap configuration
vim.g.mapleader = " " -- Map leader to <space>
-- Diagnostics
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float) -- Show diagnostic message in a floating window
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
    -- Directory to install parsers and queries to (prepended to `runtimepath` to have priority)
    install_dir = vim.fn.stdpath('data') .. '/site'
}
require('nvim-treesitter').install { 'c_sharp', 'lua' }
vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'cs' },
    callback = function() vim.treesitter.start() end,
})

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
