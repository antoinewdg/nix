{ config, pkgs, ... }:

{
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    nushell
    ripgrep
    fd
    exa
    bat
    delta
    direnv
    starship
    redis
    pass
    lens
    nixfmt
    # Apps
    megasync
    vlc
    # Dev
    jq
    dbmate
    docker-compose
    kubectl
    kubecolor
    k9s
    skaffold
    stern
    emacs
    nodePackages.pyright
    tree-sitter
    helmfile
    sops
    awscli2
    sqlitebrowser
  ];

  programs.vscode = {
    package = pkgs.vscode;
    enable = true;
    extensions = with pkgs.vscode-extensions; [
      ms-python.python
      ms-python.vscode-pylance
      yzhang.markdown-all-in-one
      vscodevim.vim
    ];

    # userSettings = ''
    # {
    # "keyboard.dispatch": "keyCode",
    # "vscode-neovim": {
    # "neovimExecutablePaths.linux": "/usr/bin/nvim",
    # }
    # }
    # '';
  };

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;

    plugins = with pkgs.vimPlugins; [
      # Looks
      gruvbox
      gruvbox-material
      # Utility
      lualine-nvim
      plenary-nvim
      nvim-web-devicons
      popup-nvim
      pkgs.vimExtraPlugins.vimpeccable
      # IDE
      nvim-treesitter # syntax highlighting
      nvim-lspconfig # pre-configured LSP for all languages
      telescope-nvim # Ctrl + P
      nvim-spectre # search and replase
      nvim-compe # Autocompletion with LSP
      nvim-comment
      open-browser-vim
      open-browser-github-vim
      goyo-vim
      pkgs.custom.lsp-format-nvim # Format on save using LSP
    ];

    extraConfig = ''
      luafile ${builtins.toString ./nvim_init.lua}
    '';
  };

  # home.file."${config.xdg.configHome}/nvim/parser/nix.so".source = "${pkgs.tree-sitter.builtGrammars.tree-sitter-nix}/parser";

  home.file = {
    # "${config.home.homeDirectory}/.profile".text = ''
    # export XDG_DATA_DIRS="$HOME/.nix-profile/share:$XDG_DATA_DIRS"
    # '';
  } // (let
    mkFilePath = name: "${config.xdg.configHome}/nvim/parser/${name}.so";
    mkGrammarPath = (name:
      let
        attrName = "tree-sitter-${name}";
        grammar = pkgs.tree-sitter.builtGrammars.${attrName};
      in "${grammar}/parser");
    grammars = [ "python" "nix" "markdown" "json" "make" "lua" "toml" ];
    # Adds the grammar files necessary for nvim-treesitter
  in builtins.listToAttrs (map (grammar: {
    name = mkFilePath (grammar);
    value = { source = mkGrammarPath (grammar); };
  }) grammars));
}
