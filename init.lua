vim.opt.runtimepath:prepend("~/vimfiles")
vim.opt.runtimepath:append("~/vimfiles/after")
vim.g.mapleader, vim.g.maplocalleader = ",", ","

vim.pack.add({
    "https://github.com/rebelot/kanagawa.nvim",
    "https://github.com/ibhagwan/fzf-lua",
    "https://github.com/stevearc/oil.nvim",
    "https://github.com/neovim/nvim-lspconfig",
    "https://github.com/p00f/clangd_extensions.nvim",
    "https://github.com/williamboman/mason.nvim",
    "https://github.com/seblyng/roslyn.nvim",
    "https://github.com/olimorris/codecompanion.nvim", "https://github.com/nvim-lua/plenary.nvim",
    "https://github.com/nvim-lualine/lualine.nvim",
    "https://github.com/folke/snacks.nvim",
    "https://github.com/gennaro-tedesco/nvim-possession",
    "https://github.com/nvim-treesitter/nvim-treesitter",
    { src = 'https://github.com/Saghen/blink.cmp', version = vim.version.range('*') },
})
vim.opt.rtp:prepend("~/Projects/nvim/easypeasy")
vim.opt.rtp:prepend("~/Projects/nvim/diyank")

for _, p in ipairs({"oil", "roslyn", "diyank", "easypeasy"}) do require(p).setup() end

vim.cmd.colorscheme("kanagawa")
vim.api.nvim_set_hl(0, "SignColumn", { bg = "none", ctermbg = "none" })
vim.api.nvim_set_hl(0, "LineNr", { bg = "none", ctermbg = "none" })

require("fzf-lua").setup({
    files = { cmd = 'rg --files --follow --smart-case --color=never --glob !.git --glob !build --glob !config/back/*'},
    ui_select = true;
})

require("blink.cmp").setup({
    keymap = { preset = "none",
        ['<tab>'] = {'snippet_forward', 'select_next', 'fallback'},
        ['<s-tab>'] = {'snippet_backward', 'select_prev', 'fallback'},
        ['<enter>'] = {'accept', 'fallback'},
    },
    sources = { default = { 'lsp', 'snippets', 'codecompanion'} },
    cmdline = { completion = { menu = { auto_show = true }, list = { selection = { preselect = false , auto_insert = true}} } },
    completion = { list = { selection = { auto_insert = true, preselect = false } } , documentation = {auto_show = true} },
    signature = { enabled = true },
})

require("mason").setup({ registries = { "github:mason-org/mason-registry", "github:crashdummyy/mason-registry", }, })
vim.lsp.config('powershell_es', { bundle_path = vim.fn.stdpath('data') .. '/mason/packages/powershell-editor-services', })
vim.lsp.config('lua_ls', { settings = { Lua = { workspace = { library = vim.api.nvim_get_runtime_file("", true) }, } }})
vim.lsp.enable({'lua_ls', 'clangd', 'html' , 'cssls', 'roslyn', 'neocmake', 'powershell_es'})

local function loadapikey(key) return assert(vim.json.decode(table.concat(vim.fn.readfile(vim.fn.expand("~/.secret/keys.json")), "\n"))[key], "missing key: "..key) end
require("codecompanion").setup({
    interactions = { chat = { adapter = "deepseek" }, inline = { adapter = "deepseek" }, cmd = { adapter = "deepseek" } },
    adapters = { http = {
        deepseek = function()
            return require("codecompanion.adapters").extend("deepseek", {
                env = { api_key = loadapikey("deepseek_api_key") },
                schema = { model = { default = "deepseek-chat" } },
                })
        end, opts = { show_presets = false }, }},
})

local has_poss, poss = pcall(require, 'nvim-possession')
require("lualine").setup({
    options = { component_separators = ' ', section_separators = ' ', },
    tabline = { lualine_a = { { 'tabs', mode = 2, max_length = vim.o.columns} } },
    sections = {
        lualine_a = {'mode'}, lualine_b = {'branch', 'diff', 'diagnostics'}, lualine_c = {'filename'},
        lualine_x = {'encoding', 'filetype', function() return string.format('%d/%d', vim.fn.line('.'), vim.fn.line('$')) end},
        lualine_y = { { 'datetime', style = '%H:%M:%S' } },
        lualine_z = { { function() return poss.status() end, cond = function() return has_poss and poss.status() ~= nil end } },
    },
    inactive_sections = { lualine_c = {'filename'}, lualine_x = {'location'} },
})

require("snacks").setup({ bigfile = { enabled = true }, lazygit = { enabled = true, configure = true }, styles = { lazygit = { width = 0, height = 0, } } })

local session_path = vim.fn.expand("~/vimfiles/session/")
vim.fn.mkdir(session_path, "p")
require("nvim-possession").setup({
    sessions = { sessions_path = session_path, sessions_icon = '' },
    autoload = true, autosave = true,
    save_hook = function()
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            if vim.api.nvim_buf_get_name(buf):match("CodeCompanion") then
                vim.api.nvim_buf_delete(buf, { force = true })
            end
        end
    end
})

require("nvim-treesitter").setup({
    highlight = { enable = true, },
    indent = { enable = true },
})
require('nvim-treesitter').install { "c", "c_sharp", "css", "lua", "vim", "vimdoc", "cpp", "python", "html" }
require('vim._core.ui2').enable({ enable = true })

--AutoCommands
vim.api.nvim_create_autocmd('PackChanged', { callback = function(e) if e.data.kind == 'update' and e.data.spec.name == 'nvim-treesitter' then pcall(function() vim.cmd('TSUpdate') end) end end })
vim.api.nvim_create_autocmd('BufWinEnter', { desc = 'Return cursor to last position', command = 'silent! normal! g`"zv' })
vim.api.nvim_create_autocmd('TextYankPost', { desc = 'Highlight yanked text', callback = function() vim.hl.on_yank({higroup = 'Substitute', timeout = 200}) end })

--Options
local backuppath = vim.fn.expand("~\\vimfiles\\back")
vim.fn.mkdir(backuppath, "p")
vim.diagnostic.config({ virtual_lines = { current_line = true }, })
vim.opt.undodir, vim.opt.backupdir, vim.opt.directory = backuppath, backuppath, backuppath
vim.opt.shell = 'powershell.exe'
vim.opt.undofile, vim.opt.swapfile, vim.opt.backup = true, false, true
vim.opt.clipboard = 'unnamedplus'
vim.opt.signcolumn = "yes"
vim.opt.tabstop, vim.opt.shiftwidth = 4, 4
vim.opt.expandtab, vim.opt.autoindent = true, true
vim.opt.scrolloff = 999
vim.opt.wrap, vim.opt.linebreak = true, true
vim.opt.ignorecase, vim.opt.smartcase = true, true
vim.opt.splitbelow, vim.opt.splitright = true, true
vim.opt.visualbell, vim.opt.wildmenu, vim.opt.cursorline = true, true, true
vim.opt.incsearch, vim.opt.hlsearch = true, false
vim.opt.sessionoptions = "blank,curdir,folds,help,tabpages,winsize,terminal"

-- Mappings
vim.keymap.set("n", "<leader>fp", function() require("fzf-lua").files() end, { desc = "fuzzy find files" })
vim.keymap.set("n", "<leader>ff", function() require("fzf-lua").builtin() end, { desc = "fzflua builtin" })
vim.keymap.set("n", "<leader>fh", function() require("fzf-lua").files({ cwd = vim.fn.expand("~") }) end, { desc = "fuzzy find in home" })
vim.keymap.set("n", "<leader>fg", function() require("fzf-lua").live_grep() end, { desc = "live grep" })
vim.keymap.set("n", "<leader>ft", function() require("fzf-lua").treesitter() end, { desc = "treesitter" })
vim.keymap.set("n", "<leader>fm", function() require("fzf-lua").treesitter({ query = "method | function " }) end, { desc = "treesitter methods/functions" })
vim.keymap.set("n", "<leader>a", function() vim.cmd("ClangdSwitchSourceHeader") end, { desc = "switch source/header", silent = true })
vim.keymap.set("n", "<leader>ic", ":CodeCompanionChat<cr>", { desc = "codecompanion chat" })
vim.keymap.set("n", "<leader>ii", ":CodeCompanion<cr>", { desc = "codecompanion" })
vim.keymap.set("n", "<leader>vg", function() require("snacks").lazygit.open() end, { desc = "open lazygit" })
vim.keymap.set("n", "<leader>;l", function() require("nvim-possession").list() end, { desc = "-list sessions" })
vim.keymap.set({"n", "v"}, "s", function() require("easypeasy").searchSingleCharacter() end)
vim.keymap.set("n", "/", function() require("easypeasy").searchMultipleCharacters() end)
vim.keymap.set("n", "<leader>tt", function() require("easypeasy").selectTreeSitter() end)
vim.keymap.set("n", "<leader>ty", function() require("easypeasy").commandTreeSitter('y') end)
vim.keymap.set("n", "<leader>tp", function() require("easypeasy").commandTreeSitter('p') end)
vim.keymap.set("n", "<leader>td", function() require("easypeasy").commandTreeSitter('d') end)
vim.keymap.set("n", "<leader>tc", function() require("easypeasy").commandTreeSitter('gc') end)
vim.keymap.set("n", "<leader>t=", function() require("easypeasy").commandTreeSitter('=') end)
vim.keymap.set("n", "<leader>tf", function() require("easypeasy").commandTreeSitter('zf') end)
vim.keymap.set("n", "<leader>ti", function() require("easypeasy").codeCompanionTreeSitter() end)
vim.keymap.set("n", "<leader>yd", function() require("diyank").yankDiagnosticFromCurrentLine() end, { desc = "yank diagnostics on line" })
vim.keymap.set({"n", "v"}, "<leader>yr", function() require("diyank").yankWithDiagnostic() end, { desc = "yank all diagnostics" })

vim.keymap.set("n", "grl", function() vim.diagnostic.jump({ count = 1, float = true }) end, { desc = "Next Diagnostic" })
vim.keymap.set("n", "grh", function() vim.diagnostic.jump({ count = -1, float = true }) end, { desc = "Previous Diagnostic" })
vim.keymap.set("n", "gri", vim.lsp.buf.hover, { desc = "show hover", silent = true })

vim.keymap.set("i", "jj", "<Esc>")
vim.keymap.set("n", ";", ":")
vim.keymap.set("n", "v", "V")
vim.keymap.set("n", "V", "v")
vim.keymap.set("n", "<A-v>", "<C-v>")
vim.keymap.set("n", "<C-j>", "J")

vim.keymap.set("n",  "H", "<C-w>h")
vim.keymap.set("n",  "J", "<C-w>j")
vim.keymap.set("n",  "K", "<C-w>k")
vim.keymap.set("n",  "L", "<C-w>l")

vim.keymap.set("n", "tn", ":tabnew<CR>", { silent = true })
vim.keymap.set("n", "tl", ":tabnext<CR>", { silent = true })
vim.keymap.set("n", "th", ":tabprevious<CR>", { silent = true })

vim.keymap.set("n", "<leader>s", "<C-6>")
vim.keymap.set("n", "<leader>ev", ":e $MYVIMRC<CR>")
