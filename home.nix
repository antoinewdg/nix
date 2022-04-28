{ config, pkgs, ... }:

{
	  # Let Home Manager install and manage itself.
	  programs.home-manager.enable = true;
	
	  nixpkgs.config.allowUnfree = true;
	
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
	
	
	  home.packages = with pkgs; [
	      nushell
	      ripgrep
	      exa
	      bat
	      direnv
	      starship
	      redis
	      dbmate
	      docker-compose
	      kubectl
	      tree-sitter
	  ];
	
	  /* home.file."${config.xdg.configHome}/nvim/parser/nix.so".source = "${pkgs.tree-sitter.builtGrammars.tree-sitter-nix}/parser"; */
	
	  home.file = 
	    let
	      mkFilePath = name: "${config.xdg.configHome}/nvim/parser/${name}.so";
	      mkGrammarPath = (name: 
	        let 
	          attrName = "tree-sitter-${name}";
	          grammar = pkgs.tree-sitter.builtGrammars.${attrName};
	        in  "${grammar}/parser");
	    in 
	    {
	      ${mkFilePath("nix")}.source = mkGrammarPath("nix");
	      ${mkFilePath("python")}.source = mkGrammarPath("python");
	      ${mkFilePath("markdown")}.source = mkGrammarPath("markdown");
	    };
}
