{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    # ...
  };

  outputs =
    { self, nixpkgs, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };

      py = pkgs.python311;
      ps = py.pkgs;

      comictagger = ps.buildPythonApplication rec {
        pname = "comictagger";
        version = "1.5.5";

        src = ps.fetchPypi {
          inherit pname version;
          hash = "sha256-f/SS6mo5zIcNBN/FRMhRPMNOeB1BIqBhsAogjsmdjB0=";
        };

        pyproject = true;
        nativeBuildInputs = with ps; [
          pkgs.qt5.wrapQtAppsHook
          setuptools-scm
          wheel
        ];

        propagatedBuildInputs = with ps; [
          pkgs.qt5.qtwayland
          beautifulsoup4
          importlib-metadata
          natsort
          pillow
          requests
          pathvalidate
          pycountry
          py7zr
          pyqt5
          pybcj
          rapidfuzz
          rarfile
          text2digits
          wordninja
        ];

        pythonImportsCheck = [
          "comicapi"
          "comictaggerlib"
        ];
      };

    in
    {
      packages.${system}.comictagger = comictagger;

      apps.${system}.comictagger = {
        type = "app";
        program = "${comictagger}/bin/comictagger";
      };
    };
}
