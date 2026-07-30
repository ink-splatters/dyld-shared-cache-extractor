top: {
  imports = [
    ./common.nix
  ];

  perSystem = {config, ...}: {
    packages.dyld-shared-cache-extractor = config.stdenv.mkDerivation (finalAttrs: ({
        pname = "dyld-shared-cache-extractor";
        inherit (top.config) src version;
        installPhase = ''
          mkdir $out
          mv ${finalAttrs.pname} $out/
        '';
      }
      // config.commonArgs));
  };
}
