local M = {}
function M.get_local_plugins()
    return {
        {
            dir = "~/Projects/nvim/easypeasy/",
            keys = {
                {"s", function() require("easypeasy").searchSingleCharacter() end, mode = {"n","v"}},
                { "/", function() require("easypeasy").searchMultipleCharacters() end},
                { "<leader>z", function() require("easypeasy").searchLines() end, mode = {"n","v"}},
                { "<leader>tt", function() require("easypeasy").selectTreeSitter() end, mode = {"n",}},
                { "<leader>ty", function() require("easypeasy").commandTreeSitter('y') end, mode = {"n",}},
                { "<leader>tp", function() require("easypeasy").commandTreeSitter('p') end, mode = {"n",}},
                { "<leader>td", function() require("easypeasy").commandTreeSitter('d') end, mode = {"n",}},
                { "<leader>tc", function() require("easypeasy").commandTreeSitter('gc' ) end, mode = {"n"}},
                { "<leader>t=", function() require("easypeasy").commandTreeSitter('=') end, mode = {"n"}},
                { "<leader>tf", function() require("easypeasy").commandTreeSitter('zf') end, mode = {"n"}},
            },
            opts = {tsSelectionMode = 'V'}
        },
        {
            dir = "~/Projects/nvim/diyank/",
            keys = {
                {"<leader>yd", function() require("diyank").yankDiagnosticFromCurrentLine() end, mode = {"n"}, desc = "yank diagnostics on line"},
                {"<leader>yr", function() require("diyank").yankWithDiagnostic() end, mode = {"n", "v"}, desc = "yank all diagnostics"},
            },
            opts = { register = "+" }
        }
    }
end
return M
