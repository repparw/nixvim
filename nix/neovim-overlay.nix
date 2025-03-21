# This overlay, when applied to nixpkgs, adds the final neovim derivation to nixpkgs.
{ inputs }:
final: prev:
with final.pkgs.lib;
let
  pkgs = final;

  # Use this to create a plugin from a flake input
  mkNvimPlugin =
    src: pname:
    pkgs.vimUtils.buildVimPlugin {
      inherit pname src;
      version = src.lastModifiedDate;
    };

  # Make sure we use the pinned nixpkgs instance for wrapNeovimUnstable,
  # otherwise it could have an incompatible signature when applying this overlay.
  pkgs-wrapNeovim = inputs.nixpkgs.legacyPackages.${pkgs.system};

  # This is the helper function that builds the Neovim derivation.
  mkNeovim = pkgs.callPackage ./mkNeovim.nix { inherit pkgs-wrapNeovim; };

  # A plugin can either be a package or an attrset, such as
  # { plugin = <plugin>; # the package, e.g. pkgs.vimPlugins.nvim-cmp
  #   config = <config>; # String; a config that will be loaded with the plugin
  #   # Boolean; Whether to automatically load the plugin as a 'start' plugin,
  #   # or as an 'opt' plugin, that can be loaded with `:packadd!`
  #   optional = <true|false>; # Default: false
  #   ...
  # }
  all-plugins = with pkgs.vimPlugins; [
    nvim-cmp # https://github.com/hrsh7th/nvim-cmp
    luasnip # snippets | https://github.com/l3mon4d3/luasnip/
    cmp_luasnip # snippets autocompletion extension for nvim-cmp | https://github.com/saadparwaiz1/cmp_luasnip/
    lspkind-nvim # vscode-like LSP pictograms | https://github.com/onsails/lspkind.nvim
    friendly-snippets
    cmp-nvim-lsp # LSP as completion source | https://github.com/hrsh7th/cmp-nvim-lsp
    cmp-nvim-lsp-signature-help # https://github.com/hrsh7th/cmp-nvim-lsp-signature-help
    cmp-path # file paths as completion source | https://github.com/hrsh7th/cmp-path/
    cmp-nvim-lua # neovim lua API as completion source | https://github.com/hrsh7th/cmp-nvim-lua/

    nvim-treesitter
    cmp-treesitter

    copilot-lua
    copilot-cmp

    vimtex
    cmp-vimtex

    # git integration plugins
    diffview-nvim # https://github.com/sindrets/diffview.nvim/

    gitsigns-nvim # https://github.com/lewis6991/gitsigns.nvim/
    vim-fugitive # https://github.com/tpope/vim-fugitive/

    # telescope and extensions
    telescope-nvim # https://github.com/nvim-telescope/telescope.nvim/
    telescope-fzf-native-nvim # https://github.com/nvim-telescope/telescope-fzy-native.nvim
    telescope-zoxide
    telescope-ui-select-nvim

    # LSP and language tools
    lsp-zero-nvim
    nvim-lspconfig
    fidget-nvim
    neodev-nvim

    conform-nvim

    nvim-surround # https://github.com/kylechui/nvim-surround/

    # Obsidian
    obsidian-nvim

    # UI
    lualine-nvim # Status line | https://github.com/nvim-lualine/lualine.nvim/
    undotree
    trouble-nvim
    todo-comments-nvim
    noice-nvim
    which-key-nvim

    # Themes/colors
    gruvbox-nvim
    tokyonight-nvim
    rose-pine

    nvim-highlight-colors

    # libraries that other plugins depend on
    plenary-nvim
    nvim-notify
    nui-nvim
    nvim-web-devicons
    vim-repeat
    # ^ libraries that other plugins depend on

    # bleeding-edge plugins from flake inputs
    # (mkNvimPlugin inputs.wf-nvim "wf.nvim") # (example) keymap hints | https://github.com/Cassin01/wf.nvim
    # ^ bleeding-edge plugins from flake inputs
  ];

  extraPackages = with pkgs; [
    beautysh

    marksman

    lua-language-server
    stylua

    nodejs

    nixd # nix lsp
    nixfmt-rfc-style

    typescript-language-server

    biome
    nodePackages.prettier
  ];
in
{
  # This is the neovim derivation
  # returned by the overlay
  nvim-pkg = mkNeovim {
    plugins = all-plugins;
    inherit extraPackages;
  };

  # This can be symlinked in the devShell's shellHook
  nvim-luarc-json = final.mk-luarc-json { plugins = all-plugins; };

  # You can add as many derivations as you like.
  # Use `ignoreConfigRegexes` to filter out config
  # files you would not like to include.
  #
  # For example:
  #
  # nvim-pkg-no-telescope = mkNeovim {
  #   plugins = [];
  #   ignoreConfigRegexes = [
  #     "^plugin/telescope.lua"
  #     "^ftplugin/.*.lua"
  #   ];
  #   inherit extraPackages;
  # };
}
