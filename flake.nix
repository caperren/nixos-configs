{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      nixos-hardware,
      ...
    }@inputs:
    {

      nixosConfigurations.cap-slim7 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit inputs;
        };
        modules = [
          ./hosts/cap-slim7/configuration.nix
          inputs.home-manager.nixosModules.default
          nixos-hardware.nixosModules.lenovo-legion-16arha7
        ];
      };

      nixosConfigurations.cap-nr200p = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/cap-nr200p/configuration.nix
          inputs.home-manager.nixosModules.default
        ];
      };
    };
}
