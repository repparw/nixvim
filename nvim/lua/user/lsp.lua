---@mod user.lsp
---
---@brief [[
---LSP related functions
---@brief ]]

local keymap = vim.keymap
local M = {}

local function desc(description, bufnr)
  return { noremap = true, silent = true, buffer = bufnr, desc = description }
end

local function preview_location_callback(_, result)
  if result == nil or vim.tbl_isempty(result) then
    vim.notify('No location found', vim.log.levels.WARN)
    return nil
  end

  local buf, win = vim.lsp.util.preview_location(result[1])
  if buf and win then
    local cur_buf = vim.api.nvim_get_current_buf()
    vim.bo[buf].filetype = vim.bo[cur_buf].filetype
    return buf, win
  end

  vim.notify('Failed to open preview window', vim.log.levels.ERROR)
  return nil
end

---@param method string The LSP method to peek
---@return boolean success
local function peek_definition_handler(method)
  local params = vim.lsp.util.make_position_params()
  local success = vim.lsp.buf_request(0, method, params, preview_location_callback)
  if not success then
    vim.notify('LSP ' .. method .. ' request failed', vim.log.levels.ERROR)
    return false
  end
  return true
end

local function peek_definition()
  return peek_definition_handler('textDocument/definition')
end

local function peek_type_definition()
  return peek_definition_handler('textDocument/typeDefinition')
end

-- Initialize trouble keymaps
keymap.set('n', '<space>tt', '<cmd>Trouble diagnostics toggle<cr>', { desc = '[T]rouble [T]oggle' })
keymap.set('n', '[t', '<cmd>Trouble previous<cr>', { desc = '[T]rouble previous' })
keymap.set('n', ']t', '<cmd>Trouble next<cr>', { desc = '[T]rouble next' })

--- Don't create a comment string when hitting <Enter> on a comment line
vim.api.nvim_create_autocmd('BufEnter', {
  group = vim.api.nvim_create_augroup('DisableNewLineAutoCommentString', {}),
  callback = function()
    vim.opt.formatoptions = vim.opt.formatoptions - { 'c', 'r', 'o' }
  end,
})

local lsp_attach = vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    local bufnr = ev.buf
    local client = vim.lsp.get_client_by_id(ev.data.client_id)

    vim.cmd.setlocal('signcolumn=yes')
    vim.bo[bufnr].bufhidden = 'hide'

    -- Enable completion triggered by <c-x><c-o>
    vim.bo[bufnr].omnifunc = 'v:lua.vim.lsp.omnifunc'

    keymap.set('n', 'gD', vim.lsp.buf.declaration, desc('lsp [g]o to [D]eclaration', bufnr))
    keymap.set('n', 'gd', vim.lsp.buf.definition, desc('lsp [g]o to [d]efinition'))
    keymap.set('n', '<space>gt', vim.lsp.buf.type_definition, desc('lsp [g]o to [t]ype definition'))
    keymap.set('n', 'K', vim.lsp.buf.hover, desc('[lsp] hover'))
    keymap.set('n', '<space>pd', peek_definition, desc('lsp [p]eek [d]efinition'))
    keymap.set('n', '<space>pt', peek_type_definition, desc('lsp [p]eek [t]ype definition'))
    keymap.set('n', 'gi', vim.lsp.buf.implementation, desc('lsp [g]o to [i]mplementation'))
    keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, desc('[lsp] signature help'))
    keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, desc('lsp add [w]orksp[a]ce folder'))
    keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, desc('lsp [w]orkspace folder [r]emove'))
    keymap.set('n', '<space>wl', function()
      vim.print(vim.lsp.buf.list_workspace_folders())
    end, desc('[lsp] [w]orkspace folders [l]ist'))
    keymap.set('n', '<space>rn', vim.lsp.buf.rename, desc('lsp [r]e[n]ame'))
    keymap.set('n', '<space>wq', vim.lsp.buf.workspace_symbol, desc('lsp [w]orkspace symbol [q]'))
    keymap.set('n', '<space>dd', vim.lsp.buf.document_symbol, desc('lsp [dd]ocument symbol'))
    keymap.set('n', '<space>ca', vim.lsp.buf.code_action, desc('[lsp] code action'))
    keymap.set('n', '<M-l>', vim.lsp.codelens.run, desc('[lsp] run code lens'))
    keymap.set('n', '<space>cr', vim.lsp.codelens.refresh, desc('lsp [c]ode lenses [r]efresh'))
    keymap.set('n', 'gr', vim.lsp.buf.references, desc('lsp [g]et [r]eferences'))
    keymap.set('n', '<space>fl', function()
      vim.lsp.buf.format { async = true }
    end, desc('[lsp] [f]ormat buffer'))
    if client and client.server_capabilities.inlayHintProvider then
      keymap.set('n', '<space>h', function()
        local current_setting = vim.lsp.inlay_hint.is_enabled { bufnr = bufnr }
        vim.lsp.inlay_hint.enable(not current_setting, { bufnr = bufnr })
      end, desc('[lsp] toggle inlay hints'))
    end

    -- Auto-refresh code lenses
    if not client then
      return
    end
    local group = vim.api.nvim_create_augroup(string.format('lsp-%s-%s', bufnr, client.id), {})
    if client.server_capabilities.codeLensProvider then
      vim.api.nvim_create_autocmd({ 'InsertLeave', 'BufWritePost', 'TextChanged' }, {
        group = group,
        callback = function()
          vim.lsp.codelens.refresh { bufnr = bufnr }
        end,
        buffer = bufnr,
      })
      vim.lsp.codelens.refresh { bufnr = bufnr }
    end
  end,
})

---Gets a 'ClientCapabilities' object, describing the LSP client capabilities
---Extends the object with capabilities provided by plugins.
---@return lsp.ClientCapabilities
function M.make_client_capabilities()
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  -- Add com_nvim_lsp capabilities
  local cmp_lsp = require('cmp_nvim_lsp')
  local cmp_lsp_capabilities = cmp_lsp.default_capabilities()
  capabilities = vim.tbl_deep_extend('keep', capabilities, cmp_lsp_capabilities)
  -- Add any additional plugin capabilities here.
  -- Make sure to follow the instructions provided in the plugin's docs.
  return capabilities
end

require('lsp-zero').extend_lspconfig {
  sign_text = true,
  lsp_attach = lsp_attach,
  capabilities = M.make_client_capabilities(),
}

---@type string[]
local servers = {
  'basedpyright',
  'ts_ls',
  'nixd',
  'rust_analyzer',
  'lua_ls',
  'marksman',
  'ruby_lsp',
  'volar',
}

-- Setup LSP servers
for _, server in ipairs(servers) do
  local ok, lspconfig = pcall(require, 'lspconfig')
  if not ok then
    vim.notify('Failed to load lspconfig', vim.log.levels.ERROR)
    break
  end

  local server_config = {} -- Add server-specific settings here if needed
  lspconfig[server].setup(server_config)
end

return M
