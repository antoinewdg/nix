{
  description = "Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    vim-extra-plugins.url = "github:m15a/nixpkgs-vim-extra-plugins";

    lsp-format-nvim = {
      url = "github:lukas-reineke/lsp-format.nvim";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, home-manager, vim-extra-plugins, ... }@inputs:
    let
      system = "x86_64-linux";
      username = "toto";
      customOverlay = final: prev: {
        custom = {
          lsp-format-nvim = prev.vimUtils.buildVimPlugin {
            name = "lsp-format.nvim";
            src = inputs.lsp-format-nvim;
          };
        };
      };
    in {
      homeConfigurations.${username} = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          inherit system;
          overlays = [vim-extra-plugins.overlay customOverlay];
        };
        
        # Specify the path to your home configuration here
        configuration = import ./home.nix;
      
        inherit system username;

        homeDirectory = "/home/${username}";
        stateVersion = "21.11";
      };
    };
}
