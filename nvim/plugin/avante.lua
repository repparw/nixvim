require('avante').setup {
  provider = 'copilot',
  copilot = {
    model = 'claude-3.5-sonnet',
  },
  auto_suggestions_provider = 'copilot',
  hints = { enabled = false },
  behaviour = { auto_suggestions = false },
}

-- Set up Avante keymaps
vim.keymap.set({ 'n', 'v' }, '<leader>ac', ':AvanteChat<CR>', { silent = true, desc = 'avante: chat' })
