local servers = {
  'basedpyright',
  'ts_ls',
  'nil_ls',
  'rust_analyzer',
  'lua_ls',
  'marksman',
  'ruby_lsp',
  'volar',
}

-- Loop through the server names and set up each one
for _, server in ipairs(servers) do
  require('lspconfig')[server].setup {}
end
