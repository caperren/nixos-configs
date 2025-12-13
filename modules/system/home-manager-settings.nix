{ inputs, ... }:
{
  home-manager.useGlobalPkgs = true;
  home-manager.backupFileExtension = "bkp";
  home-manager.sharedModules = [
    inputs.sops-nix.homeManagerModules.sops
  ];
}
