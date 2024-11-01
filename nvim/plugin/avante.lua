require('avante').setup {
  provider = 'copilot',
  copilot = {
    model = 'claude-3.5-sonnet',
    --max_tokens = 4096,
  },
  auto_suggestions_provider = 'claude',
  hints = { enabled = false },
  behaviour = { auto_suggestions = false },
}
