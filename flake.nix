{
  description = "Description for the project";

  inputs = {
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    systems.url = "github:nix-systems/default-darwin";
  };
  nixConfig = {
    extra-substituters = [
      "https://aarch64-darwin.cachix.org"
    ];
    extra-trusted-public-keys = [
      "aarch64-darwin.cachix.org-1:mEz8A1jcJveehs/ZbZUEjXZ65Aukk9bg2kmb0zL9XDA="
    ];
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} (let
      systems = import inputs.systems;
    in {
      inherit systems;
      perSystem = {
        config,
        self',
        inputs',
        pkgs,
        system,
        ...
      }: (let
        inherit (pkgs.llvmPackages_latest) clang bintools stdenv;
        commonArgs = {
          nativeBuildInputs = with pkgs;
            [
              meson
              ninja
            ]
            ++ [
              clang
              bintools
            ];

          CFLAGS = "-O3 -mcpu=native -pipe";
          LDFLAGS = "-fuse-ld=lld";
          NIX_ENFORCE_NO_NATIVE = 0;
          hardeningDisable = ["all"];
        };
      in {
        devShells.default = pkgs.mkShell.override {inherit stdenv;} commonArgs;
        packages.default = stdenv.mkDerivation (commonArgs
          // rec {
            name = "dyld-shared-cache-extractor";
            src = builtins.path {
              inherit name;
              path = ./.;
            };
            installPhase = ''
              mkdir $out
              mv ${name} $out/
            '';
          });
        formatter = pkgs.alejandra;
      });
    });
}
