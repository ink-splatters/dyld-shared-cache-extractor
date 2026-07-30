top: {
  imports = [
    ./common.nix
  ];

  perSystem = {config, ...}: {
    packages.dyld-shared-cache-extractor = config.stdenv.mkDerivation (finalAttrs: ({
        name = "dyld-shared-cache-extractor";
        inherit (top.config) src;
        installPhase = ''
          mkdir $out
          mv ${finalAttrs.name} $out/
        '';
      }
      // config.commonArgs));
  };
}
