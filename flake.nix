{
  description = "A flake for developing and building my personal website";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  # info for theme: https://www.getzola.org/themes/blow/
  inputs.terminimal = {
    url = "github:pawroman/zola-theme-terminimal";
    flake = false;
  };
  inputs.codinfox = {
    url = "github:svavs/codinfox-zola";
    flake = false;
  };
  inputs.deepthought = {
    url = "github:ratanshreshtha/deepthought";
    flake = false;
  };

  outputs = { self, nixpkgs, flake-utils, terminimal, codinfox, deepthought }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        theme = deepthought;
        pkgs = nixpkgs.legacyPackages.${system};
        themeName = ((builtins.fromTOML (builtins.readFile "${theme}/theme.toml")).name);
      in
      {
        packages.website = pkgs.stdenv.mkDerivation rec {
          pname = "static-website";
          version = "2022-02-07";
          src = ./.;
          nativeBuildInputs = with pkgs; [ zola ];
          configurePhase = ''
          mkdir -p "themes/${themeName}"
          cp -r ${theme}/* "themes/${themeName}"
          '';
          buildPhase = "zola build";
          installPhase = "cp -r public $out";
        };
        defaultPackage = self.packages.${system}.website;
        devShell = pkgs.mkShell {
          packages = with pkgs; [
            zola
          ];
          shellHook = ''
            mkdir -p themes
            ln -sn "${theme}" "themes/${themeName}"
          '';
        };
      }
    );
}
