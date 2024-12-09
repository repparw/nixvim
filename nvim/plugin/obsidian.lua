require('obsidian').setup {
  workspaces = {
    {
      name = 'obsidian',
      path = '~/Documents/obsidian',
    },
  },
  mappings = {
    ['gf'] = {
      action = function()
        return require('obsidian').util.gf_passthrough()
      end,
      opts = { noremap = false, expr = true, buffer = true },
    },
    ['<leader>o'] = {
      action = function()
        return require('obsidian').get_client():command('ObsidianOpen', { args = '' })
      end,
      opts = { noremap = false, expr = true, buffer = true },
    },
    -- Smart action depending on context, either follow link or toggle checkbox.
    ['<cr>'] = {
      action = function()
        return require('obsidian').util.smart_action()
      end,
      opts = { buffer = true, expr = true },
    },
  },
  ui = {
    enable = true, -- set to false to disable all additional syntax features
    update_debounce = 200, -- update delay after a text change (in milliseconds)
    max_file_length = 5000, -- disable UI features for files with more than this many lines
    -- Define how various check-boxes are displayed
    checkboxes = {
      -- NOTE: the 'char' value has to be a single character, and the highlight groups are defined below.
      [' '] = { char = '󰄱', hl_group = 'ObsidianTodo' },
      ['x'] = { char = '', hl_group = 'ObsidianDone' },
    },
  },
}
