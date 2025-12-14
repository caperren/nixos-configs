{ inputs, ... }:
{
  home-manager = {
    useGlobalPkgs = true;
    backupFileExtension = "bkp";
    sharedModules = [
      inputs.sops-nix.homeManagerModules.sops
    ];
  };

}
