-- return {
--   "uZer/pywal16.nvim",
--   lazy = false,
--   priority = 1000, -- load before anything else that might paint the UI
--   config = function()
--     vim.cmd.colorscheme("pywal16")
--   end,
-- }
-- UNCOMENT THIS ABOVE IF U WANT ONLY PYWAL, ANDE DELETE ALL BELOW
--
return {
  "uZer/pywal16.nvim",
  lazy = false,
  priority = 1000,

  config = function()
    vim.cmd.colorscheme("pywal16")

    -- Stable syntax colors
    vim.api.nvim_set_hl(0, "@function",       { fg = "#61AFEF" })
    vim.api.nvim_set_hl(0, "@function.call",  { fg = "#61AFEF" })
    vim.api.nvim_set_hl(0, "@method",         { fg = "#61AFEF" })
    vim.api.nvim_set_hl(0, "@method.call",    { fg = "#61AFEF" })

    vim.api.nvim_set_hl(0, "@keyword",        { fg = "#C678DD" })
    vim.api.nvim_set_hl(0, "@type",           { fg = "#E5C07B" })
    vim.api.nvim_set_hl(0, "@type.builtin",   { fg = "#E5C07B" })

    vim.api.nvim_set_hl(0, "@variable",       { fg = "#ABB2BF" })
    vim.api.nvim_set_hl(0, "@constant",       { fg = "#E06C75" })
    vim.api.nvim_set_hl(0, "@string",         { fg = "#98C379" })
    vim.api.nvim_set_hl(0, "@number",         { fg = "#D19A66" })
    vim.api.nvim_set_hl(0, "@boolean",        { fg = "#D19A66" })

    -- Brackets / punctuation
    vim.api.nvim_set_hl(0, "@punctuation.bracket", { fg = "#ABB2BF" })
    vim.api.nvim_set_hl(0, "@punctuation.delimiter", { fg = "#ABB2BF" })

    -- Errors / warnings
    vim.api.nvim_set_hl(0, "DiagnosticError", { fg = "#E06C75" })
    vim.api.nvim_set_hl(0, "DiagnosticWarn",  { fg = "#E5C07B" })
    vim.api.nvim_set_hl(0, "DiagnosticInfo",  { fg = "#61AFEF" })
    vim.api.nvim_set_hl(0, "DiagnosticHint",  { fg = "#56B6C2" })
  end,
}
