local M = {}

local ENTRIES = {
  { icon = "󰙅", label = "Explorer",  fn = function() vim.cmd("Neotree toggle") end },
  { icon = "󰆼", label = "Database",  fn = function() vim.cmd("DBUIToggle") end },
  { icon = "󰃤", label = "Debugger",  fn = function() require("dapui").toggle() end },
  { icon = "󰊢", label = "Git",       fn = function() vim.cmd("Neogit") end },
  { icon = "󰭎", label = "Telescope", fn = function() require("telescope.builtin").find_files() end },
  { icon = "󰆍", label = "Terminal",  fn = function() vim.cmd("ToggleTerm") end },
}

local state = { buf = nil, win = nil }

function M.apply_highlights()
  vim.api.nvim_set_hl(0, "ActivityBar",       { link = "Normal" })
  vim.api.nvim_set_hl(0, "ActivityBarCursor", { link = "CursorLine" })
end

vim.api.nvim_create_autocmd("ColorScheme", { callback = M.apply_highlights })

local function build_lines()
  local result = { "" }
  for _, e in ipairs(ENTRIES) do
    table.insert(result, " " .. e.icon .. " ")
    table.insert(result, "")
  end
  return result
end

local function entry_at(lnum)
  if lnum < 2 then return nil end
  local idx = math.floor((lnum - 2) / 2) + 1
  return ENTRIES[idx]
end

local function trigger()
  local e = entry_at(vim.api.nvim_win_get_cursor(0)[1])
  if e then pcall(e.fn) end
end

function M.open()
  if state.win and vim.api.nvim_win_is_valid(state.win) then return end

  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].buftype   = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].filetype  = "activitybar"

  vim.cmd("noautocmd topleft vsplit")
  local win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(win, buf)
  vim.api.nvim_win_set_width(win, 4)

  vim.wo[win].number         = false
  vim.wo[win].relativenumber = false
  vim.wo[win].signcolumn     = "no"
  vim.wo[win].foldcolumn     = "0"
  vim.wo[win].statuscolumn   = ""
  vim.wo[win].wrap           = false
  vim.wo[win].cursorline     = true
  vim.wo[win].winfixwidth    = true
  vim.wo[win].scrolloff      = 0
  vim.wo[win].winhl          = "Normal:ActivityBar,CursorLine:ActivityBarCursor"

  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, build_lines())
  vim.bo[buf].modifiable = false

  M.apply_highlights()

  local map = function(k, fn)
    vim.keymap.set("n", k, fn, { buffer = buf, nowait = true, silent = true })
  end
  map("<CR>",           trigger)
  map("<LeftRelease>",  trigger)
  map("<2-LeftMouse>",  trigger)

  vim.api.nvim_create_autocmd("CursorMoved", {
    buffer = buf,
    callback = function()
      local e = entry_at(vim.api.nvim_win_get_cursor(0)[1])
      vim.api.nvim_echo(e and {{ " " .. e.label, "Normal" }} or {}, false, {})
    end,
  })

  vim.api.nvim_create_autocmd("WinClosed", {
    pattern  = tostring(win),
    once     = true,
    callback = function() state.win = nil; state.buf = nil end,
  })

  state.buf = buf
  state.win = win

  vim.api.nvim_create_autocmd({ "WinNew", "WinClosed" }, {
    callback = function()
      vim.schedule(function()
        if not (state.win and vim.api.nvim_win_is_valid(state.win)) then return end
        vim.api.nvim_win_call(state.win, function() vim.cmd("wincmd H") end)
        vim.api.nvim_win_set_width(state.win, 4)
      end)
    end,
  })

  vim.cmd("wincmd p")
end

function M.close()
  if state.win and vim.api.nvim_win_is_valid(state.win) then
    vim.api.nvim_win_close(state.win, true)
  end
  state = { buf = nil, win = nil }
end

function M.toggle()
  if state.win and vim.api.nvim_win_is_valid(state.win) then M.close() else M.open() end
end

function M.is_open()
  return state.win ~= nil and vim.api.nvim_win_is_valid(state.win)
end

vim.api.nvim_create_autocmd("VimEnter", {
  once     = true,
  callback = function() vim.schedule(M.open) end,
})

vim.api.nvim_create_user_command("ActivityBar", M.toggle, { desc = "Toggle activity bar" })

return M
