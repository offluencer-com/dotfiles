-- Typewriter scrolling: in Zen mode the line you are on always stays in the middle
-- of the screen, also inside long wrapped paragraphs and at the end of the file.
local function center_cursor()
  local mid = math.floor((vim.api.nvim_win_get_height(0) + 1) / 2)
  local diff = vim.fn.winline() - mid
  -- Ctrl-E / Ctrl-Y scroll by one screen line (smoothscroll), the cursor stays put
  if diff > 0 then
    vim.cmd("normal! " .. diff .. "\5")
  elseif diff < 0 then
    vim.cmd("normal! " .. -diff .. "\25")
  end
end

-- Words written today, in the bottom-right corner: grey, and green from GOAL words on.
-- The number comes from the log of scripts/writingstats.sh and updates on every :w.
local GOAL = 1000
local LOG = (vim.env.XDG_DATA_HOME or vim.fn.expand("~/.local/share")) .. "/writingstats/log"
local counter = {} -- { buf, win } while Zen mode is open

-- Today's total minus the last total from an earlier day (same as writingstats.sh).
local function today_words()
  local f = io.open(LOG)
  if not f then return 0 end
  local today, before, now = os.date("%Y-%m-%d"), nil, nil
  for line in f:lines() do
    local day, total = line:match("^(%S+) (%d+)$")
    if day and day < today then before = tonumber(total) end
    if day == today then now = tonumber(total) end
  end
  f:close()
  if not before or not now then return 0 end
  return math.max(0, now - before)
end

local function show_counter()
  local words = today_words()
  local text = ("󱐍 %d words today "):format(words)
  -- same background as Zen mode's dimmed sides, so no box shows around it
  local bg = vim.api.nvim_get_hl(0, { name = "ZenBg", link = false }).bg
  local grey = vim.api.nvim_get_hl(0, { name = "Comment", link = false }).fg
  vim.api.nvim_set_hl(0, "ZenCounter", { fg = grey, bg = bg })
  vim.api.nvim_set_hl(0, "ZenCounterDone", { fg = "#39D353", bg = bg, bold = true })

  if not (counter.buf and vim.api.nvim_buf_is_valid(counter.buf)) then
    counter.buf = vim.api.nvim_create_buf(false, true)
  end
  vim.api.nvim_buf_set_lines(counter.buf, 0, -1, false, { text })

  local cfg = {
    relative = "editor", anchor = "SE", row = vim.o.lines - 1, col = vim.o.columns - 1,
    width = vim.fn.strdisplaywidth(text), height = 1,
    style = "minimal", focusable = false, zindex = 60,
  }
  if counter.win and vim.api.nvim_win_is_valid(counter.win) then
    vim.api.nvim_win_set_config(counter.win, cfg)
  else
    counter.win = vim.api.nvim_open_win(counter.buf, false, cfg)
  end
  -- transparent background, grey text; all green once the goal is reached
  local hl = words >= GOAL and "ZenCounterDone" or "ZenCounter"
  vim.wo[counter.win].winhighlight = "NormalFloat:" .. hl
  vim.wo[counter.win].winblend = 0
end

local function hide_counter()
  if counter.win and vim.api.nvim_win_is_valid(counter.win) then vim.api.nvim_win_close(counter.win, true) end
  counter.win = nil
end

return {
  "folke/zen-mode.nvim",
  opts = {
    on_open = function(win)
      -- Save current statusline state
      vim.g.zen_laststatus = vim.o.laststatus
      vim.o.laststatus = 0

      -- Hide LSP diagnostics
      vim.diagnostic.enable(false)

      -- Disable completion popup
      vim.g.zen_completion_disabled = true

      require("cmp").setup.buffer({
        enabled = false,
      })

      -- Typewriter scrolling, only in the Zen window
      vim.wo[win].smoothscroll = true
      vim.wo[win].scrolloff = 0
      local group = vim.api.nvim_create_augroup("Typewriter", { clear = true })
      vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "WinResized" }, {
        group = group,
        callback = function()
          if vim.api.nvim_get_current_win() == win then center_cursor() end
        end,
      })
      center_cursor()

      -- Words-today counter in the bottom-right corner
      vim.api.nvim_create_autocmd("User", { group = group, pattern = "WritingStats", callback = show_counter })
      vim.api.nvim_create_autocmd("VimResized", { group = group, callback = show_counter })
      show_counter()
    end,

    on_close = function()
      pcall(vim.api.nvim_del_augroup_by_name, "Typewriter")
      hide_counter()

      -- Restore statusline
      vim.o.laststatus = vim.g.zen_laststatus or 3

      -- Restore LSP diagnostics
      vim.diagnostic.enable(true)

      -- Restore completion
      vim.g.zen_completion_disabled = false

      require("cmp").setup.buffer({
        enabled = true,
      })
    end,
  },
}
