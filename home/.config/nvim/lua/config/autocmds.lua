-- Prose / writing mode: markdown, latex, plain text.
-- Goal: soft-wrapped, spellchecked, navigation that respects visual lines,
-- and none of the coding chrome (autopairs, tight indenting, hard column limits).

local prose_group = vim.api.nvim_create_augroup("ProseMode", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
  group = prose_group,
  pattern = { "markdown", "tex", "latex", "text", "plaintex" },
  callback = function(ev)
    local o = vim.opt_local

    o.wrap = true
    o.linebreak = true -- wrap at word boundaries, not mid-word
    o.textwidth = 0 -- don't hard-break lines with gq; let them soft-wrap
    o.spell = false
    o.spelllang = "en_us"
    o.number = false
    o.relativenumber = false
    o.signcolumn = "no"
    o.conceallevel = 2
    o.colorcolumn = "" -- no hard column guide, prose isn't code

    -- Move by visual (display) line instead of logical line, so long
    -- wrapped paragraphs feel like a normal text editor
    local map = vim.keymap.set
    local buf = ev.buf
    map("n", "j", "gj", { buffer = buf, silent = true })
    map("n", "k", "gk", { buffer = buf, silent = true })
    map("n", "0", "g0", { buffer = buf, silent = true })
    map("n", "$", "g$", { buffer = buf, silent = true })

    -- Mark buffer so plugins (autopairs) can check it and disable themselves
    vim.b.is_prose = true
  end,

})
