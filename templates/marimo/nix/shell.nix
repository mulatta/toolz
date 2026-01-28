{
  perSystem =
    {
      pkgs,
      lib,
      python,
      workspace,
      pythonSet,
      ...
    }:
    let
      # Production virtual environment (non-editable)
      virtualenv = pythonSet.mkVirtualEnv "PROJ_NAME-env" workspace.deps.all;
    in
    {
      devShells = {
        # Impure: Development shell with uv for flexible package management
        impure = pkgs.mkShell {
          packages = [
            python
            pkgs.uv
          ];

          env = {
            UV_PYTHON_DOWNLOADS = "never";
            # Required for packages with native extensions (numpy, etc.)
            LD_LIBRARY_PATH = lib.makeLibraryPath [
              pkgs.stdenv.cc.cc
              pkgs.zlib
            ];
          };

          shellHook = ''
            if [[ ! -d ".venv" ]]; then
              uv venv --quiet
            fi
            source .venv/bin/activate
            if [[ ! -f "uv.lock" ]] || [[ "pyproject.toml" -nt "uv.lock" ]]; then
              uv lock --quiet
            fi
            uv sync --quiet
          '';
        };

        # Pure: Nix-managed shell for CI/deployment (requires uv.lock to exist)
        pure = pkgs.mkShell {
          packages = [
            virtualenv
            pkgs.uv
          ];

          env = {
            UV_NO_SYNC = "1";
            UV_PYTHON = python.interpreter;
            UV_PYTHON_DOWNLOADS = "never";
          };

          shellHook = ''
            unset PYTHONPATH
            export VIRTUAL_ENV="${virtualenv}"
          '';
        };
      };
    };
}
