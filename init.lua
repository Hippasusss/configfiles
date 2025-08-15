vim.opt.runtimepath:prepend("~/vimfiles")
vim.opt.runtimepath:append("~/vimfiles/after")
vim.g.mapleader, vim.g.mapleaderlocal = ",", ","

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", "https://github.com/folke/lazy.nvim.git", lazypath })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({{"Failed to clone lazy.nvim", "ErrorMsg"}}, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end
vim.opt.rtp:prepend(lazypath)

local localPlugins = (function()
    local path = vim.api.nvim_get_runtime_file('lua/localPlugins.lua', true)[1]
    return path and require('localPlugins').get_local_plugins() or {}
end)()

require("lazy").setup({
    spec = {
        localPlugins,
        { -- kanagawa.nvim
            "rebelot/kanagawa.nvim",
            lazy = false,
            config = function()
                vim.cmd([[colorscheme kanagawa]])
                vim.cmd([[highlight SignColumn guibg=NONE ctermbg=NONE]])
                vim.cmd([[highlight LineNr guibg=NONE ctermbg=NONE]])

            end,
            priority = 1000,
        },
        { -- fzf
            "ibhagwan/fzf-lua",
            keys = {
                { "<leader>fp", function() require("fzf-lua").files() end, desc = "Fuzzy find files" },
                { "<leader>ff", function() require("fzf-lua").builtin() end, desc = "FzfLua builtin" },
                { "<leader>fh", function() require("fzf-lua").files({ cwd = vim.fn.expand("~") }) end, desc = "Fuzzy find in home" },
                { "<leader>fg", function() require("fzf-lua").live_grep() end, desc = "Live grep" },
                { "<leader>ft", function() require("fzf-lua").treesitter() end, desc = "Treesitter" },
                { "<leader>fm", function() require("fzf-lua").treesitter({ query = "method | function " }) end, desc = "Treesitter methods/functions" },
            },
            dependencies = { "nvim-tree/nvim-web-devicons" },
            opts = {
                file_ignore_patterns = { vim.fn.expand("config/back/"), },
                files = { cmd = 'rg --files --follow --smart-case --color=never --glob !.git --glob !build', }
            }
        },
        { -- undotree
            "mbbill/undotree",
            keys = { { "<leader>u", vim.cmd.UndotreeToggle, desc = "Toggle Undotree" } }
        },
        { -- oil
            "stevearc/oil.nvim", opts = {}
        },
        { -- nvim-lspconfig
            "neovim/nvim-lspconfig",
            lazy = false,
            keys = {
                { "<leader>gd", vim.lsp.buf.definition, desc = "Go to definition", silent = true },
                { "<leader>gr", vim.lsp.buf.references, desc = "Find references", silent = true },
                { "<leader>gf", function() require("fzf-lua").lsp_code_actions() end,  desc = "Fix current", silent = true },
                { "<leader>gc", vim.lsp.buf.rename, desc = "Rename symbol" },
                { "<leader>gl", function() vim.diagnostic.jump({count = -1, float = true}) end, desc = "Jump to next diagnostic", silent = true, },
                { "<leader>gh", function() vim.diagnostic.jump({count = 1, float = true}) end, desc = "Jump to previous diagnostic", silent = true, },
                { "<leader>a", function() vim.cmd("ClangdSwitchSourceHeader") end, desc = "Switch source/header", silent = true },
                { "<leader>gi", vim.lsp.buf.hover, desc = "Show hover", silent = true },
            },
            dependencies = {
                {
                    "saghen/blink.cmp",
                    opts = {
                        keymap = {
                            preset = "none",
                            ['<Tab>'] = {'snippet_forward', 'select_next', 'fallback'},
                            ['<S-Tab>'] = {'snippet_backward', 'select_prev', 'fallback'},
                            ['<Enter>'] = {'accept', 'fallback'},
                        },
                        sources = { default = { 'lsp', 'snippets'} },
                        cmdline = { completion = { menu = { auto_show = true }, list = { selection = { preselect = false , auto_insert = true}} } },
                        completion = { list = { selection = { auto_insert = true, preselect = false } } , documentation = {auto_show = true} },
                        signature = { enabled = true },
                    },
                    version = '1.*',
                },
                {
                    "williamboman/mason.nvim",
                    opts = {}
                },
            },
            config = function()
                require('lspconfig').lua_ls.setup {
                    settings = {
                        Lua = {
                            runtime = { version = 'LuaJIT' },
                            workspace = {
                                checkThirdParty = false,
                                library = { vim.env.VIMRUNTIME, "${3rd}/luv/library", "${3rd}/busted/library", "~/vimfiles/"},
                            }
                        }
                    }
                }
                require('lspconfig').clangd.setup{}
                require('lspconfig').html.setup{}
                require('lspconfig').cssls.setup{}
                require('lspconfig').ts_ls.setup{}
                require('lspconfig').gopls.setup{}
                require('lspconfig').neocmake.setup{}
                require('lspconfig').powershell_es.setup{
                    bundle_path = vim.fn.stdpath('data') .. '/mason/packages/powershell-editor-services',
                }
            end,
        },
        { -- codecompanion.nvim
            "olimorris/codecompanion.nvim",
            keys = {
                { "<leader>ic", ":CodeCompanionChat<CR>", desc = "CodeCompanion chat" },
                { "<leader>ii", ":CodeCompanion<CR>", desc = "CodeCompanion" },
            },
            dependencies = { "nvim-lua/plenary.nvim", "nvim-treesitter/nvim-treesitter" },
            config = function()
                local function loadApiKey(key)
                    local secrets_path = vim.fn.expand("~/.secret/keys.json")
                    local content = table.concat(vim.fn.readfile(secrets_path), "\n")
                    local secrets = assert(vim.json.decode(content), "Invalid JSON in secrets file")
                    return assert(secrets[key], "Missing key: "..key)
                end

                require("codecompanion").setup({
                    strategies = { chat = { adapter = "deepseek" }, inline = { adapter = "deepseek" }, cmd = { adapter = "deepseek" } },
                    adapters = {
                        gemini = function()
                            return require("codecompanion.adapters").extend("gemini", {
                                env = { api_key = loadApiKey("gemini_api_key") },
                                schema = { model = { default = "gemini-2.5-pro-exp-03-25" } },
                            })
                        end,
                        deepseek = function()
                            return require("codecompanion.adapters").extend("deepseek", {
                                env = { api_key = loadApiKey("deepseek_api_key") },
                                schema = { model = { default = "deepseek-chat" } },
                            })
                        end,
                    },
                })
            end,
        },
        { -- lualine
            "nvim-lualine/lualine.nvim",
            dependencies = { 'nvim-tree/nvim-web-devicons' },
            opts = {
                options = {
                    theme = 'auto',
                    component_separators = ' ', section_separators = ' ',
                    disabled_filetypes = { statusline = {}, winbar = {} },
                    always_divide_middle = true,
                    globalstatus = false,
                    refresh = { statusline = 100, tabline = 100, winbar = 100 }
                },
                tabline = { lualine_a = { { 'tabs', mode = 2, max_length = vim.o.columns } } },
                sections = {
                    lualine_a = {'mode'}, lualine_b = {'branch', 'diff', 'diagnostics'}, lualine_c = {'filename'},
                    lualine_x = {'encoding', 'filetype', function() return string.format('%d/%d', vim.fn.line('.'), vim.fn.line('$')) end},
                    lualine_y = { { 'datetime', style = '%H:%M:%S' } },
                    lualine_z = {
                        {
                            function() local ok, p = pcall(require, 'nvim-possession') return ok and p.status() or nil end,
                            cond = function() local ok, p = pcall(require, 'nvim-possession') return ok and p.status() ~= nil end,
                        },
                    },
                },
                inactive_sections = { lualine_c = {'filename'}, lualine_x = {'location'} },
            }
        },
        {
            "folke/snacks.nvim",
            priority = 1000,
            lazy = false,
            opts = {
                bigfile = { enabled = true },
                lazygit = { enabled = true, configure = true},
            },
            keys = {
                { "<leader>vg", function() require("snacks").lazygit.open() end, desc = "open LazyGit", },
            }

        },
        { -- nvim-possession
            "gennaro-tedesco/nvim-possession",
            keys = {
                { "<leader>;l", function() require("nvim-possession").list() end, desc = "-list sessions", },
                { "<leader>;n", function() require("nvim-possession").new() end, desc = "-create new session", },
                { "<leader>;s", function() require("nvim-possession").update() end, desc = "-update current session", },
                { "<leader>;d", function() require("nvim-possession").delete() end, desc = "-delete selected session"},
            },
            config = function()
                local session_path = vim.fn.expand("~/vimfiles/session/")
                if vim.fn.isdirectory(session_path) == 0 then
                    vim.fn.mkdir(session_path, "p")
                end
                require("nvim-possession").setup({
                    sessions = {
                        sessions_path = session_path,
                        sessions_prompt = "Saved Sessions:",
                        sessions_icon = ''
                    },
                    autoload = true,
                    autosave = true,
                    save_hook = function()
                        local name_pattern = "CodeCompanion"
                        for _, win in ipairs(vim.api.nvim_list_wins()) do
                            local buf = vim.api.nvim_win_get_buf(win)
                            if string.find(vim.api.nvim_buf_get_name(buf), name_pattern) then
                                vim.api.nvim_win_close(win, false)
                            end
                        end
                        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                            if string.find(vim.api.nvim_buf_get_name(buf), name_pattern) then
                                vim.api.nvim_buf_delete(buf, {force = true})
                            end
                        end
                    end
                })
            end
        },
        { -- nvim-treesitter
            "nvim-treesitter/nvim-treesitter",
            config = function ()
                require("nvim-treesitter.configs").setup({
                    ensure_installed = { "c", "c_sharp", "css", "lua", "vim", "vimdoc", "cpp", "python", "html" },
                    highlight = { enable = true },
                    indent = { enable = true },
                })
            end,
            build = ":TSUpdate",
        },
        { -- nvim-surround
            "kylechui/nvim-surround",
            opts = {},
            event = "VeryLazy",
        },
        {
            "ariel-frischer/bmessages.nvim",
            event = "CmdlineEnter",
            opts = {}
        }
    },
})

--autocommands
vim.api.nvim_create_autocmd({'BufWinEnter'}, {
    desc = 'return cursor to where it was last time closing the file',
    pattern = '*',
    command = 'silent! normal! g`"zv',
})

vim.api.nvim_create_autocmd('TextYankPost', {callback = function() vim.hl.on_yank({higroup = 'Substitute', timeout = 200}) end})

--sometimes gets changed by pesky plugins
vim.api.nvim_create_autocmd({"BufEnter", "BufWinEnter"},  {
    pattern = "*",
    callback = function()
        vim.opt_local.tabstop = 4
        vim.opt_local.shiftwidth = 4
        vim.opt_local.expandtab = true
    end
})

--options
vim.g.completion_enable_auto_popup = 0
vim.diagnostic.config {virtual_text= true}

local backUpPath = vim.fn.expand("~\\vimfiles\\back")
if vim.fn.isdirectory(backUpPath) == 0 then
    vim.fn.mkdir(backUpPath, 'p')
end
vim.opt.shell = 'powershell.exe'
vim.opt.undofile = true
vim.opt.swapfile= false
vim.opt.backup = true
vim.opt.undolevels = 1000
vim.opt.undodir = backUpPath
vim.opt.backupdir = backUpPath
vim.opt.directory = backUpPath

vim.opt.clipboard = 'unnamedplus'
vim.opt.signcolumn = "yes"

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.autoindent = true
vim.cmd("filetype plugin indent on")

vim.opt.scrolloff = 999
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.visualbell = true
vim.opt.wildmenu = true
vim.opt.cursorline = true
vim.opt.encoding= "utf-8"
vim.opt.incsearch = true
vim.opt.hlsearch = false
vim.opt.paste = false
vim.opt.sessionoptions = "blank,curdir,folds,help,tabpages,winsize,terminal"

--mappings
vim.keymap.set("i", "jj", "<Esc>")
vim.keymap.set("n", ";", ":")
vim.keymap.set("n", "v", "V")
vim.keymap.set("n", "V", "v")
vim.keymap.set("n", "<A-v>", "<c-v>")
vim.keymap.set("n", "<C-J>", "J")

vim.keymap.set("n",  "H", "<C-W>h")
vim.keymap.set("n",  "J", "<C-W>j")
vim.keymap.set("n",  "K", "<C-W>k")
vim.keymap.set("n",  "L", "<C-W>l")

vim.keymap.set("n", "tn", ":tabnew<CR>", { silent = true })
vim.keymap.set("n", "tl", ":tabnext<CR>", { silent = true })
vim.keymap.set("n", "th", ":tabprevious<CR>", { silent = true })

vim.keymap.set("n", "<leader>s", "<C-6>")
vim.keymap.set("n", "<leader>ev", ":e $MYVIMRC<CR>")

