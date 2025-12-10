{
  perSystem = {
    workspace,
    pythonSet,
    ...
  }: {
    packages = {
      # Default package: virtual environment with default dependencies only
      default = pythonSet.mkVirtualEnv "PROJ_NAME-env" workspace.deps.default;

      # Full package: virtual environment with all dependencies (including optional)
      full = pythonSet.mkVirtualEnv "PROJ_NAME-full-env" workspace.deps.all;
    };
  };
}
