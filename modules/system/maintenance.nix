# Single place to set flags that can be used for reconfiguring systems when maintenance is required
{ lib, ... }:
{
  options."perren.cloud".maintenance.nfs = lib.mkOption {
    type = lib.types.bool;
    readOnly = true;
    default = false;
  };

  options."perren.cloud".maintenance.postgres = lib.mkOption {
    type = lib.types.bool;
    readOnly = true;
    default = false;
  };
}
