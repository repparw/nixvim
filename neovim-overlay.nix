  all-plugins = with pkgs.vimPlugins; [
    lspkind-nvim # vscode-like LSP pictograms | https://github.com/onsails/lspkind.nvim
    friendly-snippets
    cmp-nvim-lsp # LSP as completion source | https://github.com/hrsh7th/cmp-nvim-lsp
    cmp-nvim-lsp-signature-help # https://github.com/hrsh7th/cmp-nvim-lsp-signature-help
    cmp-path # file paths as completion source | https://github.com/hrsh7th/cmp-path/

    telescope-zoxide

    neodev-nvim

  ];
