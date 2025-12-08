{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
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
      nixosConfigurations.cap-clust-01 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/cap-clust-01/configuration.nix
          inputs.home-manager.nixosModules.default
        ];
      };
      nixosConfigurations.cap-clust-02 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/cap-clust-02/configuration.nix
          inputs.home-manager.nixosModules.default
        ];
      };
      nixosConfigurations.cap-clust-03 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/cap-clust-03/configuration.nix
          inputs.home-manager.nixosModules.default
        ];
      };
      nixosConfigurations.cap-clust-04 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/cap-clust-04/configuration.nix
          inputs.home-manager.nixosModules.default
        ];
      };
      nixosConfigurations.cap-clust-05 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/cap-clust-05/configuration.nix
          inputs.home-manager.nixosModules.default
        ];
      };
      nixosConfigurations.cap-clust-06 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/cap-clust-06/configuration.nix
          inputs.home-manager.nixosModules.default
        ];
      };
      nixosConfigurations.cap-clust-07 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/cap-clust-07/configuration.nix
          inputs.home-manager.nixosModules.default
        ];
      };
      nixosConfigurations.cap-clust-08 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/cap-clust-08/configuration.nix
          inputs.home-manager.nixosModules.default
        ];
      };
      nixosConfigurations.cap-clust-09 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/cap-clust-09/configuration.nix
          inputs.home-manager.nixosModules.default
        ];
      };

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
