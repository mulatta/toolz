{
  lib,
  buildPythonPackage,
  fetchPypi,
  # Runtime dependencies
  packaging,
  tomli,
}:
buildPythonPackage rec {
  pname = "rapids-build-backend";
  version = "0.4.1";
  format = "wheel";

  src = fetchPypi {
    inherit version;
    pname = "rapids_build_backend";
    format = "wheel";
    dist = "py3";
    python = "py3";
    hash = "sha256-dmhA5e26N/dJFlep2xU64NmvZ6P58XzSKQdJvWJkFlc=";
  };

  dependencies = [
    packaging
    tomli
  ];

  pythonImportsCheck = [ "rapids_build_backend" ];

  # Tests require git repository
  doCheck = false;

  meta = {
    description = "Build backend for RAPIDS projects";
    homepage = "https://github.com/rapidsai/rapids-build-backend";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
}
