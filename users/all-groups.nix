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

  # Group with r/w permissions to the ad share
  users.groups.nas-komga-management.gid = 205;

  # Group with r permissions to the ad share
  users.groups.nas-komga-view.gid = 206;

  # Group with r/w permissions to the gitea share
  users.groups.nas-gitea-management.gid = 207;

  # Group with r/w permissions to the rclone share
  users.groups.nas-rclone-management.gid = 208;

  # Group with r/w permissions to the immich share
  users.groups.nas-immich-management.gid = 209;

  # Group with r/w permissions to the ollama share
  users.groups.nas-ollama-management.gid = 210;
}
