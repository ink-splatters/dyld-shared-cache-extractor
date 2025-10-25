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
        inherit (pkgs) cmake ninja;

        inherit (pkgs.llvmPackages_latest) clang bintools stdenv;
        commonAttrs = {
          nativeBuildInputs = with pkgs; [
            clang
            bintools
            cmake
            ninja
          ];
        };

        cmakeFlags = [
          "CMAKE_C_FLAGS=-O3 -mcpu=native -pipe"
          "CMAKE_EXE_LINKER_FLAGS=-fuse-ld=lld"
        ];
      in {
        devShells.default = pkgs.mkShell.override {inherit stdenv;} commonAttrs;
        packages.default = stdenv.mkDerivation (commonAttrs
          // rec {
            name = "dyld-cache-extractor";
            src = builtins.path {
              inherit name;
              path = ./.;
            };
          });
        formatter = pkgs.alejandra;
      });
    });
}
