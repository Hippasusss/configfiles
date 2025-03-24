vim.opt.runtimepath:prepend("~/vimfiles")
vim.opt.runtimepath:append("~/vimfiles/after")
vim.g.mapleader = ","
vim.g.mapleaderlocal = ","

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
    if vim.v.shell_error ~= 0 then
	vim.api.nvim_echo({
	    { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
	    { out, "WarningMsg" },
	    { "\nPress any key to exit..." },
	}, true, {})
	vim.fn.getchar()
	os.exit(1)
    end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup(
    {
	spec = {
	    {
		"ibhagwan/fzf-lua",
		dependencies = { "nvim-tree/nvim-web-devicons" }
	    },
	    {
		'nvim-lualine/lualine.nvim',
		dependencies = { 'nvim-tree/nvim-web-devicons' },
	    },
	    {
		'tpope/vim-fugitive',
		dependencies = { 'tpope/vim-dispatch', 'tpope/vim-rhubarb'}
	    },
	    {
		'easymotion/vim-easymotion',
		"mbbill/undotree"
	    },
	    {
		"neoclide/coc.nvim",
		branch="release"
	    },
	    {
		"rebelot/kanagawa.nvim",
		lazy = false,
		priority = 1000,
		config = function()
		    vim.cmd([[colorscheme kanagawa]])
		end,
	    },
	    {
		"gennaro-tedesco/nvim-possession",
		dependencies = {
		    "ibhagwan/fzf-lua",
		},
		config = true,
		keys = {
		    { "<leader>sl", function() require("nvim-possession").list() end, desc = "-list sessions", },
		    { "<leader>sn", function() require("nvim-possession").new() end, desc = "-create new session", },
		    { "<leader>su", function() require("nvim-possession").update() end, desc = "-update current session", },
		    { "<leader>sd", function() require("nvim-possession").delete() end, desc = "-delete selected session"},
		},
	    },
	    {
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		config = function ()
		    local configs = require("nvim-treesitter.configs")

		    configs.setup({
			ensure_installed = { "c", "c_sharp", "css", "lua", "vim", "vimdoc", "cpp", "python", "html" },
			sync_install = false,
			highlight = { enable = true },
			indent = { enable = true },
		    })
		end
	    },
	    checker = { enabled = true },
	}
    })

require("nvim-possession").setup({
    sessions = {
	sessions_path = vim.fn.expand("$HOME/vimfiles/session/"),
	sessions_variable = "session",
	sessions_icon = "",
	sessions_prompt = "Saved Sessions:",
    },

    autoload = false, -- whether to autoload sessions in the cwd at startup
    autosave = false, -- whether to autosave loaded sessions before quitting
    sort = require("nvim-possession.sorting").alpha_sort -- callback, sorting function to list sessions
})


local function line_ratio()
  local current_line = vim.fn.line('.')
  local total_lines = vim.fn.line('$')
  return string.format('%d/%d', current_line, total_lines)
end

require('lualine').setup {
    options = {
	icons_enabled = true,
	theme = 'auto',
	component_separators = { left = ' ', right = ' '},
	section_separators = { left = ' ', right = ' '},
	disabled_filetypes = {
	    statusline = {},
	    winbar = {},
	},
	ignore_focus = {},
	always_divide_middle = true,
	globalstatus = false,
	refresh = {
	    statusline = 100,
	    tabline = 100,
	    winbar = 100,
	}
    },
    tabline = {
	lualine_a = {
	    {
		'tabs',
		mode = 2,  -- Show tab numbers and names
		max_length = vim.o.columns
	    }
	 },
    },
    sections = {
	lualine_a = {'mode'},
	lualine_b = {'branch', 'diff', 'diagnostics'},
	lualine_c = {'filename'},
	lualine_x = {'encoding', 'filetype', line_ratio },
	lualine_y = {
	    {
		'datetime',
		style = '%H:%M:%S'
	    },
	},
	lualine_z = {
	    {
		require("nvim-possession").status,
		cond = function()
		    return require("nvim-possession").status() ~= nil
		end,
	    },
	},
    },
    inactive_sections = {
	lualine_c = {'filename'},
	lualine_x = {'location'},
    },
}

vim.api.nvim_create_autocmd({'BufWinEnter'}, {
    desc = 'return cursor to where it was last time closing the file',
    pattern = '*',
    command = 'silent! normal! g`"zv',
})

--options
local backUpPath = "$HOME\\.config\\back"
vim.g.undotree_DiffCommand = "FC"
vim.opt.undofile = true
vim.opt.undolevels = 1000
vim.opt.undolevels = 1000
vim.opt.backup = true
vim.opt.undodir = vim.fn.expand(backUpPath)
vim.opt.backupdir = vim.fn.expand(backUpPath)
vim.opt.directory = vim.fn.expand(backUpPath)
vim.opt.showtabline = 2


vim.opt.scrolloff = 999
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.wrap = false
vim.opt.linebreak = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.smartindent = true
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.visualbell = true
vim.opt.wildmenu = true
vim.opt.cursorline = true
vim.opt.encoding= "utf-8"
vim.opt.guifont="InputMono_Medium:h10:cANSI:qDRAFT"
vim.opt.incsearch = true
vim.opt.hlsearch = false
vim.opt.completeopt:append('preview')
vim.opt.showmode = true

--mappings
vim.keymap.set("i", "<Esc>", "<Nop>")
vim.keymap.set("i", "jj", "<Esc>")
vim.keymap.set("n", ";", ":")
vim.keymap.set("n", "<leader>cd", ":lcd %:p:h<CR>:pwd<CR>")
vim.keymap.set("n", "v", "V")
vim.keymap.set("n", "V", "v")
vim.keymap.set("n", "<A-v>", "<c-v>")
vim.keymap.set("n", "<leader>y", "\"+y")
vim.keymap.set("v", "<leader>y", "\"+y")
vim.keymap.set("n", "<leader>p", "\"+p")

vim.keymap.set("n",  "H", "<C-W>h")
vim.keymap.set("n",  "J", "<C-W>j")
vim.keymap.set("n",  "K", "<C-W>k")
vim.keymap.set("n",  "L", "<C-W>l")

vim.keymap.set("n", "tn" , ":tabnew<CR>")
vim.keymap.set("n", "tl" , ":tabnext<CR>")
vim.keymap.set("n", "th" , ":tabprevious<CR>")

vim.keymap.set("n", "<leader>s", "<C-6>")
vim.keymap.set("n", "<C-V>", "<Esc>\"*p")

vim.keymap.set("n" , "<leader>ev", ":e $MYVIMRC<CR>")
vim.keymap.set("n", "<leader>eb", ":e $HOME/.bashrc<CR>")
vim.keymap.set("n", "<Leader>ec", ":e <C-R>=get(split(globpath(&runtimepath, 'colors/' . g:colors_name . '.vim'), \"\\n\"), 0, '')<CR><CR>")
vim.keymap.set("n", "<leader>rv", ":so $MYVIMRC<CR>;")

vim.keymap.set("n", "<leader>vg", ":G<CR>")
vim.keymap.set("n", "<leader>vp", ":G push<CR>")

vim.keymap.set("n", "<leader>fp", ":FzfLua files <CR>")
vim.keymap.set("n", "<leader>ff", ":FzfLua <CR>")
vim.keymap.set("n", "<leader>fh", ":FzfLua files cwd=\"~\" <CR>")
vim.keymap.set("n", "<leader>fg", ":FzfLua live_grep <CR>")

vim.keymap.set("n", "s", "<Plug>(easymotion-s)")
vim.keymap.set("n", "/", "<Plug>(easymotion-sn)")
vim.keymap.set("o", "/", "<Plug>(easymotion-tn)")

vim.keymap.set("n", "<leader>wq", ":SSave!<CR> :SClose<CR> :q!<CR>")

vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)
vim.keymap.set("n", "<silent><leader>gd", "<Plug>(coc-definition)")
vim.keymap.set("n", "<silent><leader>gn", "<Plug>(coc-type-definition)")
vim.keymap.set("n", "<silent><leader>gs", "<Plug>(coc-implementation)")
vim.keymap.set("n", "<silent><leader>gr", "<Plug>(coc-references)")
vim.keymap.set("n", "<silent><leader>gf", "<Plug>(coc-fix-current)")
vim.keymap.set("n", "<leader>gc", "<Plug>(coc-rename)")
vim.keymap.set("n", "<silent><leader>gl", ":call CocAction('diagnosticNext')<cr>")
vim.keymap.set("n", "<silent><leader>gh", ":call CocAction('diagnosticPrevious')<cr>")
vim.keymap.set("n", "<leader>a", ":<C-u>CocCommand clangd.switchSourceHeader<CR>")
vim.keymap.set("n", "<silent><leader>gi", ":call ShowDocumentation()<CR>")
vim.keymap.set("i", "<silent>", ",s <C-r>=CocActionAsync('showSignatureHelp')<CR>")

-- ivim.keymap.set("n", jjldwi"jjWhi", jjlxi"jjA")jjjIjj 



