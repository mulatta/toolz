{
  lib,
  buildPythonPackage,
  fetchPypi,
  pythonOlder,
  dask,
  distributed,
}:
buildPythonPackage rec {
  pname = "rapids-dask-dependency";
  version = "25.10.0";
  format = "wheel";

  disabled = pythonOlder "3.10";

  src = fetchPypi {
    pname = "rapids_dask_dependency";
    inherit version;
    format = "wheel";
    dist = "py3";
    python = "py3";
    hash = "sha256-C7uplftoWjHmwbUIAK9HpMz9+NpvN9dkC1EonZzlpJk=";
  };

  # Pin specific versions of dask and distributed
  dependencies = [
    dask
    distributed
  ];

  # Metapackage - no tests
  doCheck = false;

  # No imports check - metapackage
  # pythonImportsCheck = [];

  meta = {
    description = "Metapackage encoding dask and distributed requirements for RAPIDS";
    homepage = "https://github.com/rapidsai";
    license = lib.licenses.asl20;
    platforms = lib.platforms.all;
    maintainers = [ ];
  };
}
