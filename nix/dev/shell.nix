{
  perSystem = {
    config,
    pkgs,
    ...
  }: let
    inherit (config) pre-commit commonArgs stdenv;
  in {
    devShells.default =
      (pkgs.mkShell.override {inherit (config) stdenv;} {
        packages =
          pre-commit.settings.enabledPackages
          ++ commonArgs.nativeBuildInputs;

        shellHook = ''
          ${pre-commit.installationScript}
        '';
      })
      // builtins.removeAttrs commonArgs ["nativeBuildInputs"];
  };
}
