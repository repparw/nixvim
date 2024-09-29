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
}
