{
  description = "Standalone Home Manager config for tux (Caelestia Shell + sunshine)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-parts.url = "git+https://github.com/hercules-ci/flake-parts?rev=f7c1a2d347e4c52d5fb8d10cb4d94b5884e546fb";

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.flake-parts.follows = "flake-parts";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    caelestia-shell = {
      url = "github:caelestia-dots/shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      caelestia-shell,
      home-manager,
      nixvim,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      homeConfigurations."tux" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          caelestia-shell.homeManagerModules.default
          nixvim.homeModules.nixvim
          ./home.nix
        ];
      };
    };
}
