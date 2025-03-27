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
		    { "<leader>;l", function() require("nvim-possession").list() end, desc = "-list sessions", },
		    { "<leader>;n", function() require("nvim-possession").new() end, desc = "-create new session", },
		    { "<leader>;u", function() require("nvim-possession").update() end, desc = "-update current session", },
		    { "<leader>;d", function() require("nvim-possession").delete() end, desc = "-delete selected session"},
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
	    {
		"olimorris/codecompanion.nvim",
		config = true,
		dependencies = {
		    "nvim-lua/plenary.nvim",
		    "nvim-treesitter/nvim-treesitter",
		},
	    },
	    checker = { enabled = true },
	}
    })


local function loadApiKey(key)
    local secrets_path = vim.fn.expand("$HOME/.secret/keys.json") -- Expands to full path
    local file = io.open(secrets_path, "r")
    if not file then
	error("Failed to open secrets file: " .. secrets_path)
    end

    local content = file:read("*a")
    file:close()

    local ok, secrets = pcall(vim.json.decode, content)
    if not ok or not secrets[key] then
	error("Invalid or missing key: " .. key .. " in: " .. secrets_path)
    end
    print(secrets[key])
    return secrets[key]
end

require("codecompanion").setup({
    strategies = {
	chat = {
	    adapter = "deepseek",
	},
	inline = {
	    adapter = "deepseek",
	},
	cmd = {
	    adapter = "deepseek",
	}
    },

    adapters = {
	deepseek = function()
	    return require("codecompanion.adapters").extend("deepseek", {
		env = {
		    api_key = loadApiKey("deepseek_api_key"),
		},
		schema = {
		    model = {
			default = "deepseek-chat",
		    }
		},
	    })
	end,
    },
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

local cc_loading = false
local spinner_frames = { "⡇", "⡏", "⡗", "⡟", "⡿", "⣿", "⢿", "⣻" }
local spinner_index = 1

vim.loop.new_timer():start(0, 100, function()
  spinner_index = spinner_index % #spinner_frames + 1
  vim.schedule(function()
    if package.loaded["lualine"] then
      require("lualine").refresh()
    end
  end)
end)
vim.api.nvim_create_autocmd("User", {
  pattern = "CodeCompanionRequestStarted",
  callback = function()
    cc_loading = true
    vim.schedule(require("lualine").refresh)
  end,
})
vim.api.nvim_create_autocmd("User", {
  pattern = "CodeCompanionRequestFinished",
  callback = function()
    cc_loading = false
    vim.schedule(require("lualine").refresh)
  end,
})
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
		function()
		    return cc_loading and spinner_frames[spinner_index] or ""
		end,
		color = { fg = "#ff9e64" },  -- Orange color
	    },
	    {
		require("nvim-possession").status,
		cond = function()
		    return require("nvim-possession").status() ~= nil
		end,
	    },
	},
    },
    refresh = {
	statusline = 100,  -- Update frequency
    },
    inactive_sections = {
	lualine_c = {'filename'},
	lualine_x = {'location'},
    },
}
require('fzf-lua').setup({
    file_ignore_patterns = {
	vim.fn.expand("config/back/"),
    },

    files = {
	fzf_opts = {
	    ['--tiebreak'] = 'index',
	},
	formatter = "path.filename_first",
    }
})

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

vim.keymap.set("n", "<leader>fp", function()
  require("fzf-lua").files()
end, { desc = "Fuzzy find files" })

vim.keymap.set("n", "<leader>ff", function()
  require("fzf-lua").builtin()
end, { desc = "FzfLua builtin" })

vim.keymap.set("n", "<leader>fh", function()
  require("fzf-lua").files({ cwd = vim.fn.expand("$HOME") })
end, { desc = "Fuzzy find in home" })

vim.keymap.set("n", "<leader>fg", function()
  require("fzf-lua").live_grep()
end, { desc = "Live grep" })

vim.keymap.set("n", "<leader>ft", function()
  require("fzf-lua").treesitter()
end, { desc = "Treesitter" })

vim.keymap.set("n", "<leader>fm", function()
  require("fzf-lua").treesitter({ query = "method | function " })
end, { desc = "Treesitter methods/functions" })

vim.keymap.set("n", "s", "<Plug>(easymotion-s)")
vim.keymap.set("n", "/", "<Plug>(easymotion-sn)")
vim.keymap.set("o", "/", "<Plug>(easymotion-tn)")

vim.keymap.set("n", "<leader>wq", ":SSave!<CR> :SClose<CR> :q!<CR>")

vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)

vim.keymap.set("n", "<leader>gd", "<Plug>(coc-definition)", { silent = true })
vim.keymap.set("n", "<leader>gn", "<Plug>(coc-type-definition)", { silent = true })
vim.keymap.set("n", "<leader>gs", "<Plug>(coc-implementation)", { silent = true })
vim.keymap.set("n", "<leader>gr", "<Plug>(coc-references)", { silent = true })
vim.keymap.set("n", "<leader>gf", "<Plug>(coc-fix-current)", { silent = true })
vim.keymap.set("n", "<leader>gc", "<Plug>(coc-rename)")
vim.keymap.set("n", "<leader>gl", function() vim.fn.CocAction("diagnosticNext") end, { silent = true })
vim.keymap.set("n", "<leader>gh", function() vim.fn.CocAction("diagnosticPrevious") end, { silent = true })
vim.keymap.set("n", "<leader>a", function() vim.cmd("CocCommand clangd.switchSourceHeader") end, { silent = true })
vim.keymap.set("n", "<leader>gi", function() vim.fn.CocAction("doHover") end, { silent = true })
vim.keymap.set("i", ",s", "<C-r>=CocActionAsync('showSignatureHelp')<CR>", { silent = true })

vim.keymap.set('i', '<Tab>', function()
  return vim.fn['coc#pum#visible']() == 1 and vim.fn['coc#pum#next'](1)
    or vim.fn.col('.') - 1 == 0 and '\t'
    or vim.fn.getline('.'):sub(vim.fn.col('.') - 1, vim.fn.col('.') - 1):match('%s') and '\t'
    or vim.fn['coc#refresh']()
end, { expr = true, silent = true })

vim.keymap.set("n", "<leader>ic", ":CodeCompanionChat<CR>")
vim.keymap.set("n", "<leader>ii", ":CodeCompanion<CR>")


