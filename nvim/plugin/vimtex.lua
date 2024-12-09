vim.g.vimtex_compiler_method = 'latexmk'
vim.g.vimtex_compiler_engine = 'xelatex'
vim.g.vimtex_compiler_latexmk = {
  options = {
    '-synctex=1',
    '-interaction=nonstopmode',
    '-file-line-error',
  },
}
vim.g.vimtex_view_method = 'zathura'
vim.g.vimtex_fold_enabled = false
vim.g.vimtex_view_forward_search_on_start = true
vim.g.vimtex_bibtex_options = '--min-crossrefs=999'
