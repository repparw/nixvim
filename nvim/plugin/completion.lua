if vim.g.did_load_completion_plugin then
  return
end
vim.g.did_load_completion_plugin = true

local cmp = require('cmp')
local lspkind = require('lspkind')
local luasnip = require('luasnip')
require('luasnip.loaders.from_vscode').lazy_load()

vim.opt.completeopt = { 'menu', 'menuone', 'noselect' }

luasnip.config.setup {
  history = true,
  update_events = 'TextChanged,TextChangedI',
  delete_check_events = 'TextChanged',
  enable_autosnippets = true,
}

cmp.setup {
  snippet = {
    expand = function(args)
      vim.snippet.expand(args.body)
    end,
  },
  completion = { completeopt = 'menu,menuone,noinsert' },

  -- For an understanding of why these mappings were
  -- chosen, you will need to read `:help ins-completion`
  --
  -- No, but seriously. Please read `:help ins-completion`, it is really good!
  mapping = cmp.mapping.preset.insert {
    -- Select the [n]ext item
    ['<C-n>'] = cmp.mapping.select_next_item(),
    -- Select the [p]revious item
    ['<C-p>'] = cmp.mapping.select_prev_item(),

    -- Scroll the documentation window [b]ack / [f]orward
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),

    -- Accept ([y]es) the completion.
    -- This will auto-import if your LSP supports it.
    -- This will expand snippets if the LSP sent a snippet.
    ['<C-y>'] = cmp.mapping.confirm { select = true },

    -- Manually trigger a completion from nvim-cmp.
    -- Generally you don't need this, because nvim-cmp will display
    -- completions whenever it has completion options available.
    ['<C-Space>'] = cmp.mapping.complete {},

    -- Think of <c-l> as moving to the right of your snippet expansion.
    -- So if you have a snippet that's like:
    -- function $name($args)
    --   $body
    -- end
    --
    -- <c-l> will move you to the right of each of the expansion locations.
    -- <c-h> is similar, except moving you backwards.
    ['<C-l>'] = cmp.mapping(function()
      if luasnip.expand_or_locally_jumpable() then
        luasnip.expand_or_jump()
      end
    end, { 'i', 's' }),
    ['<C-h>'] = cmp.mapping(function()
      if luasnip.locally_jumpable(-1) then
        luasnip.jump(-1)
      end
    end, { 'i', 's' }),

    -- For more advanced Luasnip keymaps (e.g. selecting choice nodes, expansion) see:
    -- https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
  },
  formatting = {
    fields = { 'kind', 'abbr', 'menu' },
    format = lspkind.cmp_format {
      mode = 'symbol',
      maxwidth = 50,
      symbol_map = { Copilot = '' },
      ellipsis_char = '...', -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead (must define maxwidth first)
      show_labelDetails = true, -- show labelDetails in menu. Disabled by default
    },
  },
  sources = cmp.config.sources({
    { name = 'copilot', group_index = 2 },
    { name = 'nvim_lsp', group_index = 2 },
    { name = 'luasnip', group_index = 2 },
    { name = 'path', group_index = 2 },
  }, {
    { name = 'buffer', group_index = 3 },
  }, {
    { name = 'latex_symbols', group_index = 3, option = { strategy = 2 } },
  }),
  sorting = {
    priority_weight = 2,
    comparators = {
      cmp.config.compare.exact,
      cmp.config.compare.score,
      cmp.config.compare.recently_used,
      cmp.config.compare.locality,
      cmp.config.compare.kind,
      cmp.config.compare.length,
      cmp.config.compare.order,
    },
  },
  window = {
    completion = {
      border = { '╭', '─', '╮', '│', '╯', '─', '╰', '│' },
      winhighlight = 'Normal:CmpNormal,FloatBorder:CmpBorder,CursorLine:CmpSelection,Search:None',
    },
    documentation = {
      border = { '╭', '─', '╮', '│', '╯', '─', '╰', '│' },
      winhighlight = 'Normal:CmpDocNormal,FloatBorder:CmpDocBorder',
    },
  },
  experimental = {
    ghost_text = true, -- show future text as ghost text
  },
}
