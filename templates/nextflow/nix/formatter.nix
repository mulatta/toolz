{inputs, ...}: {
  imports = [inputs.treefmt-nix.flakeModule];
  perSystem = {pkgs, ...}: {
    treefmt = {
      projectRootFile = ".git/config";

      programs = {
        # Nix formatters & linters
        alejandra.enable = true;
        deadnix.enable = true;
        statix.enable = true;

        # Python formatters & linters
        ruff-check.enable = true;
        ruff-format.enable = true;

        # Shell formatters & linter
        shellcheck.enable = true;
        shfmt.enable = true;

        # Other formatters
        keep-sorted.enable = true;
        typos.enable = true;
        yamlfmt.enable = true;
        taplo.enable = true;
      };

      settings.formatter.nextflow = {
        command = "${pkgs.nextflow}/bin/nextflow";
        options = ["lint" "-format"];
        includes = ["*.nf" "nextflow.config"];
      };

      settings.global.excludes = [
        "*.lock"
        ".gitignore"
        ".secrets.yaml"
        "data/**"
        "results/**"
        "work/**"
        "outputs/**"
      ];
    };
  };
}
