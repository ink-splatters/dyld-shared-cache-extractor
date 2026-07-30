top: {
  imports = [
    ./common.nix
  ];

  perSystem = {config, ...}: {
    packages.dyld-shared-cache-extractor = config.stdenv.mkDerivation ({
        name = "dyld-shared-cache-extractor";
        inherit (top.config) src;
      }
      // config.commonArgs);
  };
}
