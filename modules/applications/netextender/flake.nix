# TODO: This was hacked together until it worked...Clean it up before merging
{
  description = "SonicWall NetExtender Flake";

  outputs =
    { self, nixpkgs, ... }:
    let
      systems = [ "x86_64-linux" ];
      neVersion = "10.3.0-21";
      neUrl = "https://software.sonicwall.com/NetExtender/NetExtender-linux-amd64-${neVersion}.tar.gz";

      # ✅ Define the overlay function directly
      overlay = final: prev: {
        netextender = prev.stdenv.mkDerivation rec {
          pname = "netextender";
          version = neVersion;
          src = prev.fetchurl {
            url = neUrl;
            sha256 = "sha256-pnF/KRQMAcPnTj0Ni+sKKkw+H72WHf2iYVkWsWNCndc=";
          };

          nativeBuildInputs = [
            prev.autoPatchelfHook
            prev.makeWrapper
          ];
          buildInputs = [
            prev.openssl_3
            prev.zlib
            prev.gtk2
            prev.pango
            prev.cairo
            prev.xorg.libX11
          ];

          unpackPhase = "tar -xzf $src";
          installPhase = ''
            mkdir -p $out/bin
            BIN_CLI=$(find . -type f -iname nxcli -perm -111 | head -n1)
            BIN_SVC=$(find . -type f -iname neservice -perm -111 | head -n1)
            install -Dm755 "$BIN_CLI" $out/bin/nxcli
            install -Dm755 "$BIN_SVC" $out/bin/neservice
            ln -sf nxcli $out/bin/netextender
            ln -sf neservice $out/bin/nxservice
            for exe in nxcli neservice; do
              wrapProgram $out/bin/$exe \
                --prefix LD_LIBRARY_PATH : ${prev.lib.makeLibraryPath buildInputs}
            done
          '';
        };
      };
    in
    {
      overlays = {
        x86_64-linux = overlay;
      };

      packages = {
        x86_64-linux =
          let
            pkgs = import nixpkgs {
              system = "x86_64-linux";
              overlays = [ overlay ];
            };
          in
          {
            default = pkgs.netextender;
            netextender = pkgs.netextender;
          };
      };
    };
}
