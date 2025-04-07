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

local local_plugins = (function()
    for _, path in ipairs(vim.api.nvim_get_runtime_file('lua/localPlugins.lua', true)) do
        if vim.loop.fs_stat(path) then return require('localPlugins').get_local_plugins() end
    end
    return {}
end)()

require("lazy").setup({
    spec = {
        {
            "ibhagwan/fzf-lua",
            dependencies = { "nvim-tree/nvim-web-devicons" },
            keys = {
                { "<leader>fp", function() require("fzf-lua").files() end, desc = "Fuzzy find files" },
                { "<leader>ff", function() require("fzf-lua").builtin() end, desc = "FzfLua builtin" },
                { "<leader>fh", function() require("fzf-lua").files({ cwd = vim.fn.expand("$HOME") }) end, desc = "Fuzzy find in home" },
                { "<leader>fg", function() require("fzf-lua").live_grep() end, desc = "Live grep" },
                { "<leader>ft", function() require("fzf-lua").treesitter() end, desc = "Treesitter" },
                { "<leader>fm", function() require("fzf-lua").treesitter({ query = "method | function " }) end, desc = "Treesitter methods/functions" },
            }
        },
        {
            "mbbill/undotree",
            keys = {
                { "<leader>u", vim.cmd.UndotreeToggle, desc = "Toggle Undotree" }
            }
        },
        {
            "neoclide/coc.nvim",
            branch="release",
            lazy = false,
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
            }
        },
        {
            "olimorris/codecompanion.nvim",
            config = true,
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
            end,
        },
        {
            "kylechui/nvim-surround",
            event = "VeryLazy",
            config = function()
                require("nvim-surround").setup({
                    -- Configuration here, or leave empty to use defaults
                })
            end
        },
        {
            "Hippasusss/easypeasy",
            keys = {
                {"s", function() require("easypeasy").searchSingleCharacter() end, desc = "Search for character and then jump"},
                { "/", function() require("easypeasy").searchMultipleCharacters() end, desc = "Search for regex and then jump"},
                { "<leader>z", function() require("easypeasy").searchLiness() end, desc = "Search lines" },
                { "<leader>tt", function() require("easypeasy").selectTreeSitter() end, desc = "Search and then visualy select treesitter nodes"},
                { "<leader>ty", function() require("easypeasy").yankTreeSitter() end, desc = "Search and then yank treesitter nodes"},
                { "<leader>td", function() require("easypeasy").deleteTreeSitter() end, desc = "Search and then delete treesitter nodes"},
            },
        },
        -- unpack(local_plugins),
        checker = { enabled = true },
    }
})

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


local function loadApiKey(key)
    local secrets_path = vim.fn.expand("$HOME/.secret/keys.json")
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

require("nvim-possession").setup({
    sessions = {
        sessions_path = vim.fn.expand("$HOME/vimfiles/session/"),
        sessions_variable = "session",
        sessions_icon = "",
        sessions_prompt = "Saved Sessions:",
    },

    autoload = true, -- whether to autoload sessions in the cwd at startup
    autosave = true, -- whether to autosave loaded sessions before quitting
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
        cmd = 'rg --files --follow --smart-case --color=never --glob !.git --glob !build',
    }
})

require'nvim-treesitter.configs'.setup {
}

--autocommands
vim.api.nvim_create_autocmd({'BufWinEnter'}, {
    desc = 'return cursor to where it was last time closing the file',
    pattern = '*',
    command = 'silent! normal! g`"zv',
})

vim.api.nvim_create_autocmd('TextYankPost', {callback = function() vim.highlight.on_yank({higroup = 'IncSearch', timeout = 100}) end})

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

local backUpPath = "$HOME\\.config\\back"
vim.g.undotree_DiffCommand = "FC"
vim.opt.undofile = true
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
vim.keymap.set("n", "<leader>eb", ":e $HOME/.bashrc<CR>")

vim.keymap.set("n", "s", function() require("easypeasy").searchSingleCharacter() end)
vim.keymap.set("n", "/", function() require("easypeasy").searchMultipleCharacters() end)
vim.keymap.set('n', '<leader>0', function() vim.cmd("luafile " .. vim.fn.expand("%:p")) end)

