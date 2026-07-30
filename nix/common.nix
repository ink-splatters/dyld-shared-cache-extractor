{lib, ...}: {
  perSystem = {pkgs, ...}: let
    inherit (pkgs.llvmPackages) stdenv libcxx clang bintools;
    inherit (pkgs) cmakeMinimal ninja;
  in {
    options = {
      stdenv = lib.mkOption {
        type = lib.types.attrs;
        default = stdenv;
      };
      commonArgs = lib.mkOption {
        type = lib.types.attrs;
        default = {
          nativeBuildInputs = [
            cmakeMinimal
            ninja
            clang
            bintools
          ];

          preConfigure = ''
            cmakeFlagsArray+=(
              "-GNinja"
              "-DCMAKE_BUILD_TYPE=Release"
              "-DCMAKE_CXX_FLAGS=-O3 -mcpu=native -flto=thin -pipe"
              "-DCMAKE_EXE_LINKER_FLAGS=-flto=thin -fuse-ld=lld -L${libcxx}/lib"
             )
          '';
          enableParallelBuilding = true;

          NIX_ENFORCE_NO_NATIVE = 0;
          hardeningDisable = ["all"];
        };
      };
    };
  };
}
