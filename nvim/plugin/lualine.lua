if vim.g.did_load_lualine_plugin then
  return
end
vim.g.did_load_lualine_plugin = true

---Indicators for special modes,
---@return string status
local function extra_mode_status()
  -- recording macros
  local reg_recording = vim.fn.reg_recording()
  if reg_recording ~= '' then
    return ' @' .. reg_recording
  end
  -- executing macros
  local reg_executing = vim.fn.reg_executing()
  if reg_executing ~= '' then
    return ' @' .. reg_executing
  end
  -- ix mode (<C-x> in insert mode to trigger different builtin completion sources)
  local mode = vim.api.nvim_get_mode().mode
  if mode == 'ix' then
    return '^X: (^]^D^E^F^I^K^L^N^O^Ps^U^V^Y)'
  end
  return ''
end

require('lualine').setup {
  sections = {
    lualine_x = {
      {
        require('noice').api.statusline.mode.get,
        cond = require('noice').api.statusline.mode.has,
        color = { fg = '#ff9e64' },
      },
    },
    lualine_z = {
      -- (see above)
      { extra_mode_status },
    },
  },
  options = {
    theme = 'gruvbox-material',
  },
  extensions = { 'fugitive', 'fzf', 'toggleterm', 'quickfix' },
}
