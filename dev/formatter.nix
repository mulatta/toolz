{inputs, ...}: {
  imports = [inputs.treefmt-nix.flakeModule];
  perSystem = {
    treefmt = {
      # Used to find the project root
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

      settings.global.excludes = [
        "*.lock"
        ".gitignore"
        "packages/nextflow/deps.json"
      ];
    };
  };
}
