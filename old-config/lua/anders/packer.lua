-- This file can be loaded by calling `lua require('plugins')` from your init.vim

-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  use {
	  'nvim-telescope/telescope.nvim', tag = '0.1.5',
	  -- or                            , branch = '0.1.x',
	  requires = { {'nvim-lua/plenary.nvim'} }
  }

  use({
	  'catppuccin/nvim', 
	  as = 'catppuccin',
	  config = function()
		  vim.cmd('colorscheme catppuccin')
	  end
  })

  use('nvim-treesitter/nvim-treesitter', {run = ':TSUpdate'})
  use('neovim/nvim-lspconfig')
  use  {
	  'VonHeikemen/lsp-zero.nvim',
	  branch = 'v3.x',
	  requires = {
		  {'williamboman/mason.nvim'},
		  {'williamboman/mason-lspconfig.nvim'},
		  {
			  'hrsh7th/nvim-cmp',
			  config = function ()
				  require'cmp'.setup {
					  snippet = {
						  expand = function(args)
							  require'luasnip'.lsp_expand(args.body)
						  end
					  },

					  sources = {
						  { name = 'luasnip' },
						  -- more sources
					  },
				  }
			  end
		  },
		  {'hrsh7th/cmp-nvim-lsp'},
		  {'hrsh7th/cmp-buffer'},
		  {'hrsh7th/cmp-path'},
		  {'saadparwaiz1/cmp_luasnip'},
		  {'hrsh7th/cmp-nvim-lua'},
		  {'L3MON4D3/LuaSnip'},
		  {'rafamadriz/friendly-snippets'}
	  }
  }

end)
