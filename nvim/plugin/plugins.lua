if vim.g.did_load_plugins_plugin then
  return
end
vim.g.did_load_plugins_plugin = true

-- many plugins annoyingly require a call to a 'setup' function to be loaded,
-- even with default configs

require('nvim-surround').setup()

require('notify').setup {
  background_colour = '#000000',
}

require('copilot').setup {
  suggestion = { enabled = false },
  panel = { enabled = false },
}

require('trouble').setup()

require('copilot_cmp').setup()
