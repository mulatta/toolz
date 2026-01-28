{
  perSystem =
    {
      config,
      pkgs,
      ...
    }:
    {
      devShells.default =
        pkgs.mkShellNoCC {
          buildInputs = with pkgs; [
            nixVersions.latest
            gitMinimal
            jujutsu
            gitingest
            cachix
          ];
        }
        // pkgs.lib.optionalAttrs pkgs.stdenv.isLinux {
          # AlphaFold3 development environment with GPU support
          devShells.alphafold3 =
            let
              alphafold3Pkg = config.packages.alphafold3;
              python = config.packages.python312.withPackages (ps: [
                ps.alphafold3
                ps.ipython
                ps.jupyter
              ]);
            in
            pkgs.mkShellNoCC {
              buildInputs = [
                alphafold3Pkg # Provides HMMER tools and run_alphafold.py
                python
              ];
              shellHook = alphafold3Pkg.mkShellHook python;
            };
        };
    };
}
