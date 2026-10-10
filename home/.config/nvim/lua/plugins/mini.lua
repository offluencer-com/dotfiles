return {
  "echasnovski/mini.nvim",
  event = "VeryLazy",
  config = function()
    require("mini.icons").setup(require("mini.statusline").setup({
  content = {
    active = function()
      local mode, mode_hl = MiniStatusline.section_mode({ trunc_width = 120 })
      local git = MiniStatusline.section_git({ trunc_width = 40 })
      local diagnostics = MiniStatusline.section_diagnostics({ trunc_width = 75 })
      local filename = MiniStatusline.section_filename({ trunc_width = 140 })
      local fileinfo = MiniStatusline.section_fileinfo({ trunc_width = 120 })

     local fileinfo = MiniStatusline.section_fileinfo({ trunc_width = 120 })

local wordcount = ""
local prose_fts = { markdown = true, tex = true, latex = true, text = true, plaintex = true }
if prose_fts[vim.bo.filetype] then
  wordcount = vim.fn.wordcount().words .. " words"
end

return MiniStatusline.combine_groups({
  { hl = mode_hl, strings = { mode } },
  { hl = "MiniStatuslineDevinfo", strings = { git, diagnostics } },
  "%<",
  { hl = "MiniStatuslineFilename", strings = { filename } },
  "%=",
  { hl = "MiniStatuslineFileinfo", strings = { wordcount, fileinfo } },
})
    end,
  },
}))
    require("mini.comment").setup() -- gcc / gc motion

    require("mini.pairs").setup({
      -- auto-close brackets/quotes, but stay out of the way while writing prose
      modes = { insert = true, command = false, terminal = false },
    })

    -- Disable auto-pairing in prose buffers (marked by autocmds.lua)
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "markdown", "tex", "latex", "text", "plaintex" },
      callback = function()
        vim.b.minipairs_disable = true
      end,
    })
  end,
}
