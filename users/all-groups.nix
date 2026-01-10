{ config, pkgs, ... }:
{
  # Reference for non-manually generated groups
  # gid=1(wheel)
  # gid=100(users)

  users.groups = {
    # Group with r/w access to all nas shares
    nas-caperren = {
      gid = 200;
      isSystemGroup = true;
    };

    # Group with r/w permissions to the media share
    nas-media-management = {
      gid = 201;
      isSystemGroup = true;
    };

    # Group with r permissions to the media share
    nas-media-view = {
      gid = 202;
      isSystemGroup = true;
    };

    # Group with r/w permissions to the ad share
    nas-ad-management = {
      gid = 203;
      isSystemGroup = true;
    };

    # Group with r permissions to the ad share
    nas-ad-view = {
      gid = 204;
      isSystemGroup = true;
    };
  };
}
