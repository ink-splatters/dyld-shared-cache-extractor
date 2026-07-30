{lib, ...}: {
  perSystem = {pkgs, ...}: let
    inherit (pkgs.llvmPackages) stdenv libcxx clang bintools;
    inherit (pkgs) meson ninja;
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
            meson
            ninja
            clang
            bintools
          ];

          preConfigure = ''
            mesonFlagsArray=(
              -Dcpp_args="-O3 -mcpu=native -flto -pipe"
              -Dcpp_link_args="-L${libcxx}/lib -fuse-ld=lld"
            );
          '';

          enableParallelBuilding = true;

          NIX_ENFORCE_NO_NATIVE = 0;
          hardeningDisable = ["all"];
        };
      };
    };
  };
}
