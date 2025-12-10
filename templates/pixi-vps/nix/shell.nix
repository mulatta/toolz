{
  perSystem = {pkgs, ...}: {
    devShells.default = pkgs.mkShell {
      packages = [
        pkgs.pixi
      ];

      shellHook = ''
        if [[ ! -f "$ROOT/pixi.toml" ]]; then
          (cd "$ROOT" && pixi init)
        fi

        eval "$(pixi shell-hook)"
      '';
    };
  };
}
