# This flake was initially generated by fh, the CLI for FlakeHub (version 0.1.9)
{
  description = "Project Template";

  inputs = {
    flake-schemas.url = "https://flakehub.com/f/DeterminateSystems/flake-schemas/*.tar.gz";
    utility-flake.url = "https://flakehub.com/f/atomic-studio-org/Utility-Flake-Library/*.tar.gz";
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/*.tar.gz";
  };

  outputs = { self, flake-schemas, nixpkgs, utility-flake }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" ];
      forEachSupportedSystem = f: nixpkgs.lib.genAttrs supportedSystems (system: f {
        pkgs = import nixpkgs { inherit system; };
      });
    in
    {
      schemas = flake-schemas.schemas;

      formatter = forEachSupportedSystem ({ pkgs }: pkgs.nixpkgs-fmt);

      checks = forEachSupportedSystem ({ pkgs }: {
        inherit (utility-flake.checks.${pkgs.system}) pre-commit-check;
      });

      packages = forEachSupportedSystem ({ pkgs }: rec {
        default = studio;
        studio = pkgs.stdenvNoCC.mkDerivation rec {
          pname = "studio";
          name = "studio";
          src = pkgs.lib.cleanSource ./.;

          buildInputs = with pkgs; [ podman distrobox ];

          buildCommand = ''
            	    mkdir -p $out/bin $out/libexec
            	    cp $src/src/${pname} $out/bin
            	    substituteInPlace $out/bin/${pname} --replace './libexec' "$out/libexec"
            	    cp -r $src/src/libexec/* $out/libexec
            	  '';
        };
        inherit (utility-flake.packages.${pkgs.system}) cosign-generate;
      });

      devShells = forEachSupportedSystem ({ pkgs }: {
        default = pkgs.mkShell {
          packages = utility-flake.lib.${pkgs.system}.devShellPackages ++ (with pkgs; [ earthly go-task melange apko ]);
        };
      });
    };
}
