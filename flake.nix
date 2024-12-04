{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    #nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
#    { self, nixpkgs, nixos-hardware, ... }@inputs:
    { self, nixpkgs, ... }@inputs:
    {
      nixosConfigurations.default = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs;
        };
        modules = [
          ./hosts/cap-slim7/configuration.nix
          ./modules/nixos/hyprland-amd.nix
          inputs.home-manager.nixosModules.default
         #  nixos-hardware.nixosModules.lenovo-legion-16arha7
        ];
      };
    };
}
