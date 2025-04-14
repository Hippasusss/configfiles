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
    for _, path in ipairs(vim.api.nvim_get_runtime_file('lua/localPlugins.lua', true)) do
        if vim.loop.fs_stat(path) then return require('localPlugins').get_local_plugins() end
    end
    return {}
end)()

require("lazy").setup({
    spec = {
        unpack(localPlugins),
        {
            "rebelot/kanagawa.nvim",
            lazy = false,
            priority = 1000,
            config = function()
                vim.cmd([[colorscheme kanagawa]])
            end,
        },
        {
            "ibhagwan/fzf-lua",
            lazy = true,
            dependencies = { "nvim-tree/nvim-web-devicons" },
            keys = {
                { "<leader>fp", function() require("fzf-lua").files() end, desc = "Fuzzy find files" },
                { "<leader>ff", function() require("fzf-lua").builtin() end, desc = "FzfLua builtin" },
                { "<leader>fh", function() require("fzf-lua").files({ cwd = vim.fn.expand("$HOME") }) end, desc = "Fuzzy find in home" },
                { "<leader>fg", function() require("fzf-lua").live_grep() end, desc = "Live grep" },
                { "<leader>ft", function() require("fzf-lua").treesitter() end, desc = "Treesitter" },
                { "<leader>fm", function() require("fzf-lua").treesitter({ query = "method | function " }) end, desc = "Treesitter methods/functions" },
            },
            opts = {
                file_ignore_patterns = {
                    vim.fn.expand("config/back/"),
                },
                files = {
                    cmd = 'rg --files --follow --smart-case --color=never --glob !.git --glob !build',
                }
            }
        },
        {
            "mbbill/undotree",
            lazy = true,
            keys = {
                { "<leader>u", vim.cmd.UndotreeToggle, desc = "Toggle Undotree" }
            }
        },
        {
            "neoclide/coc.nvim",
            lazy = false,
            branch="release",
            keys = {
                { "<leader>gd", "<Plug>(coc-definition)", desc = "Go to definition", silent = true },
                { "<leader>gr", "<Plug>(coc-references)", desc = "Find references", silent = true },
                { "<leader>gf", "<Plug>(coc-fix-current)", desc = "Fix current", silent = true },
                { "<leader>gc", "<Plug>(coc-rename)", desc = "Rename symbol" },
                { "<leader>gl", function() vim.fn.CocAction("diagnosticNext") end, desc = "Next diagnostic", silent = true },
                { "<leader>gh", function() vim.fn.CocAction("diagnosticPrevious") end, desc = "Prev diagnostic", silent = true },
                { "<leader>a", function() vim.cmd("CocCommand clangd.switchSourceHeader") end, desc = "Switch source/header", silent = true },
                { "<leader>gi", function() vim.fn.CocAction("doHover") end, desc = "Show hover", silent = true },
                { ",s", "<C-r>=CocActionAsync('showSignatureHelp')<CR>", desc = "Signature help", mode = "i", silent = true },
                { '<Tab>', function()
                    return vim.fn['coc#pum#visible']() == 1 and vim.fn['coc#pum#next'](1)
                        or vim.fn.col('.') - 1 == 0 and '\t'
                        or vim.fn.getline('.'):sub(vim.fn.col('.') - 1, vim.fn.col('.') - 1):match('%s') and '\t'
                        or vim.fn['coc#refresh']()
                end,  expr = true, silent = true , mode = "i"}
            },
            config = function()
                vim.g.coc_user_config = {
                    semanticTokens = { enable = true },
                    inlayHint = { enable = false },
                    suggest = {
                        enablePreselect = false,
                        noselect = true
                    },
                    diagnostic = {
                        errorSign = "!",
                        warningSign = "?",
                        showUnused = false,
                        virtualText = true,
                        virtualTextCurrentLineOnly = false,
                        messageTarget = "echo"
                    },
                    powershell = { integratedConsole = { showOnStartup = false } },
                    ["luals"] = {
                        enableNvimLuaDev = true,
                    },
                    Lua = { runtime = { version = "LuaJIT" } },
                    coc = { preferences = { useQuickfixForLocations = true } }
                }
            end,
        },
        {
            "olimorris/codecompanion.nvim",
            lazy = true,
            config = function()
                local function loadApiKey(key)
                    local secrets_path = vim.fn.expand("$HOME/.secret/keys.json")
                    local content = table.concat(vim.fn.readfile(secrets_path), "\n")
                    local secrets = assert(vim.json.decode(content), "Invalid JSON in secrets file")
                    return assert(secrets[key], "Missing key: "..key)
                end

                require("codecompanion").setup({
                    strategies = {
                        chat = { adapter = "deepseek" },
                        inline = { adapter = "deepseek" },
                        cmd = { adapter = "deepseek" }
                    },
                    adapters = {
                        gemini = function()
                            return require("codecompanion.adapters").extend("gemini", {
                                env = {
                                    api_key = loadApiKey("gemini_api_key"),
                                },
                                schema = { model = { default = "gemini-2.5-pro-exp-03-25",} },
                            })
                        end,
                        deepseek = function()
                            return require("codecompanion.adapters").extend("deepseek", {
                                env = {
                                    api_key = loadApiKey("deepseek_api_key"),
                                },
                                schema = { model = { default = "deepseek-chat",} },
                            })
                        end,
                    },
                })
            end,
            dependencies = {
                "nvim-lua/plenary.nvim",
                "nvim-treesitter/nvim-treesitter",
            },
            keys = {
                { "<leader>ic", ":CodeCompanionChat<CR>", desc = "CodeCompanion chat" },
                { "<leader>ii", ":CodeCompanion<CR>", desc = "CodeCompanion" },
            }
        },
        {
            'nvim-lualine/lualine.nvim',
            dependencies = { 'nvim-tree/nvim-web-devicons' },
            opts = {
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
                            mode = 2,
                            max_length = vim.o.columns
                        }
                    },
                },
                sections = {
                    lualine_a = {'mode'},
                    lualine_b = {'branch', 'diff', 'diagnostics'},
                    lualine_c = {'filename'},
                    lualine_x = {'encoding', 'filetype', function()
                        local current_line = vim.fn.line('.')
                        local total_lines = vim.fn.line('$')
                        return string.format('%d/%d', current_line, total_lines)
                    end},
                    lualine_y = {
                        {
                            'datetime',
                            style = '%H:%M:%S'
                        },
                    },
                    lualine_z = {
                        {
                            function()
                                local ok, possession = pcall(require, 'nvim-possession')
                                return ok and possession.status() or nil
                            end,
                            cond = function()
                                local ok, possession = pcall(require, 'nvim-possession')
                                return ok and possession.status() ~= nil
                            end,
                        },
                    },
                },
                refresh = {
                    statusline = 100,
                },
                inactive_sections = {
                    lualine_c = {'filename'},
                    lualine_x = {'location'},
                },
            }
        },
        {
            "kdheepak/lazygit.nvim",
            lazy = true,
            cmd = {
                "LazyGit",
                "LazyGitConfig",
                "LazyGitCurrentFile",
                "LazyGitFilter",
                "LazyGitFilterCurrentFile",
            },
            keys = {
                { "<leader>vg", "<cmd>LazyGit<cr>", desc = "LazyGit" }
            }
        },
        {
            "gennaro-tedesco/nvim-possession",
            dependencies = {
                "ibhagwan/fzf-lua",
            },
            opts = {
                sessions = {
                    sessions_path = vim.fn.expand("$HOME/vimfiles/session/"),
                    sessions_variable = "session",
                    sessions_icon = "",
                    sessions_prompt = "Saved Sessions:",
                },
                autoload = true,
                autosave = true,
                save_hook = function()
                    local bufs = vim.api.nvim_list_bufs()
                    local name_pattern = "CodeCompanion"

                    for _, win in ipairs(vim.api.nvim_list_wins()) do
                        local buf = vim.api.nvim_win_get_buf(win)
                        local buf_name = vim.api.nvim_buf_get_name(buf)
                        if string.find(buf_name, name_pattern) then
                            vim.api.nvim_win_close(win, false)
                        end
                    end

                    for _, buf in ipairs(bufs) do
                        local buf_name = vim.api.nvim_buf_get_name(buf)
                        if string.find(buf_name, name_pattern) then
                            vim.api.nvim_buf_delete(buf, {force = true})
                        end
                    end
                end
            },
            keys = {
                { "<leader>;l", function() require("nvim-possession").list() end, desc = "-list sessions", },
                { "<leader>;n", function() require("nvim-possession").new() end, desc = "-create new session", },
                { "<leader>;s", function() require("nvim-possession").update() end, desc = "-update current session", },
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
            end,
        },
        {
            "kylechui/nvim-surround",
            event = "VeryLazy",
            opts = {}
        },
        -- {
        --     "Hippasusss/easypeasy",
        --     keys = {
        --         {"s", function() require("easypeasy").searchSingleCharacter() end, mode = {"n","v"}},
        --         { "/", function() require("easypeasy").searchMultipleCharacters() end},
        --         { "<leader>z", function() require("easypeasy").searchLines() end, mode = {"n","v"}},
        --         { "<leader>tt", function() require("easypeasy").selectTreeSitter() end, mode = {"n","v"}},
        --         { "<leader>ty", function() require("easypeasy").yankTreeSitter() end, mode = {"n","v"}},
        --         { "<leader>td", function() require("easypeasy").deleteTreeSitter() end, mode = {"n","v"}},
        --         { "<leader>tw", function() require("easypeasy").commandTreeSitter('gc') end, mode = {"n","v"}},
        --     },
        --     opts = {
        --         -- tsSelectionMode = 'V'
        --     }
        -- },
    },
    checker = { enabled = true },
})

--autocommands
vim.api.nvim_create_autocmd({'BufWinEnter'}, {
    desc = 'return cursor to where it was last time closing the file',
    pattern = '*',
    command = 'silent! normal! g`"zv',
})

vim.api.nvim_create_autocmd('TextYankPost', {callback = function() vim.highlight.on_yank({higroup = 'Substitute', timeout = 200}) end})

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
vim.g.undotree_DiffCommand = "FC"
vim.g.coc_disable_workspace_config = 1
vim.g.completion_enable_auto_popup = 0

local backUpPath = "$HOME\\.config\\back"

vim.opt.undofile = true
vim.opt.swapfile= false
vim.opt.backup = true
vim.opt.undolevels = 1000
vim.opt.undodir = vim.fn.expand(backUpPath)
vim.opt.backupdir = vim.fn.expand(backUpPath)
vim.opt.directory = vim.fn.expand(backUpPath)
vim.opt.showtabline = 1

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
vim.keymap.set({"n", "v"}, "<leader>y", "\"+y")
vim.keymap.set({"n", "v"}, "<leader>p", "\"+p")

vim.keymap.set("n",  "H", "<C-W>h")
vim.keymap.set("n",  "J", "<C-W>j")
vim.keymap.set("n",  "K", "<C-W>k")
vim.keymap.set("n",  "L", "<C-W>l")

vim.keymap.set("n", "tn", ":tabnew<CR>", { silent = true })
vim.keymap.set("n", "tl", ":tabnext<CR>", { silent = true })
vim.keymap.set("n", "th", ":tabprevious<CR>", { silent = true })

vim.keymap.set("n", "<leader>s", "<C-6>")

vim.keymap.set("n", "<leader>ev", ":e $MYVIMRC<CR>")

vim.keymap.set('n', '<leader>0', function() vim.cmd("luafile " .. vim.fn.expand("%:p")) end)

