{
  description = "dyld-shared-cache-extractor";

  inputs = {
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        nixpkgs-stable.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };
  };

  nixConfig = {
    extra-substituters = "https://cachix.cachix.org";
    extra-trusted-public-keys =
      "cachix.cachix.org-1:eWNHQldwUO7G2VkjpnjDbWwy4KQ/HNxht7H4SSoMckM=";
  };

  outputs = { nixpkgs, flake-utils, pre-commit-hooks, self, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        inherit (pkgs) llvmPackages mkShell lib;
        inherit (llvmPackages) stdenv;

      in {

        checks = {
          pre-commit-check = pre-commit-hooks.lib.${system}.run {
            src = ../.;
            hooks = {
              # clang-format.enable = true;
              # clang-tidy.enable = true;
              deadnix.enable = true;
              markdownlint.enable = true;
              nil.enable = true;
              nixfmt.enable = true;
              statix.enable = true;
            };

            # settings.markdownlint.config = {
            #   MD034 = false;
            #   MD013.line_length = 200;
            # };

            tools = pkgs;

          };
        };

        formatter = pkgs.nixfmt;

        devShells.default = mkShell.override { inherit stdenv; } {

          inherit (self.packages.${system}.defaut) CFLAGS nativeBuildInputs;

          shellHook = self.checks.${system}.pre-commit-check.shellHook + ''
            export PS1="\n\[\033[01;36m\]‹ 𐲚YⲖ𐲚 𐑕ꡘ𐒰ᚱ⼹𐲚 ꓚ𐒰ꓚꡘE 📤 \\$ \[\033[00m\]"
            echo -e "\nto install pre-commit hooks:\n\x1b[1;37mnix develop .#install-hooks\x1b[00m"
          '';
        };

        install-hooks = mkShell {
          inherit (self.checks.${system}.pre-commit-check) shellHook;
        };

        packages.default = stdenv.mkDerivation {

          CFLAGS = "-O3" + lib.optionalString ("${system}" == "aarch64-darwin")
            " -mcpu=apple-m1";

          src = ./.;

          nativeBuildInputs = with pkgs; [ cmake ninja ];

          buildPhase = ''
            mkdir build
            cmake -GNinja -DCMAKE_BUILD_TYPE=Release -S . -B build
            cmake --build build
          '';

          installPhase = ''
            mkdir -p $out
            cmake --install build --prefix=$out
          '';

          enableParallelBuilding = true;

        };
      });
}
