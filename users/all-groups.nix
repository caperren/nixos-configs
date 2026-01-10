{ config, pkgs, ... }:
{
  # Reference for non-manually generated groups
  # gid=1(wheel)
  # gid=100(users)

  # Group with r/w access to all nas shares
  users.groups.nas-caperren.gid = 200;

  # Group with r/w permissions to the media share
  users.groups.nas-media-management.gid = 201;

  # Group with r permissions to the media share
  users.groups.nas-media-view.gid = 202;

  # Group with r/w permissions to the ad share
  users.groups.nas-ad-management.gid = 203;

  # Group with r permissions to the ad share
  users.groups.nas-ad-view.gid = 204;
}
