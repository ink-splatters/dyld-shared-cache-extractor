{
  inputs = {
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} ({lib, ...}: let
      flakeModules.default = import ./nix/flake-module.nix;
    in {
      imports = [
        flakeModules.default
        flake-parts.flakeModules.partitions
      ];

      config = {
        systems = ["aarch64-darwin"];

        partitionedAttrs = {
          apps = "dev";
          checks = "dev";
          devShells = "dev";
          formatter = "dev";
        };
        partitions.dev = {
          # directory containing inputs-only flake.nix
          extraInputsFlake = ./nix/dev;
          module = {
            imports = [./nix/dev];
          };
        };
        perSystem = {config, ...}: {
          config.packages.default = config.packages.dyld-shared-cache-extractor;
        };

        flake = {
          inherit flakeModules;
        };
      };
      options = {
        src = lib.mkOption {
          default = builtins.path {
            path = ./.;
            name = "dyld-shared-cache-extractor";
          };
        };
      };
    });
}
