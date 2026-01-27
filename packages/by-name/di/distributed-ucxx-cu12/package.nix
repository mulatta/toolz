{
  lib,
  buildPythonPackage,
  fetchPypi,
  pythonOlder,
  numba-cuda,
  pyyaml,
  rapids-dask-dependency,
  ucxx-cu12,
}:
buildPythonPackage rec {
  pname = "distributed-ucxx-cu12";
  version = "0.46.0";
  format = "wheel";

  disabled = pythonOlder "3.10";

  src = fetchPypi {
    pname = "distributed_ucxx_cu12";
    inherit version;
    format = "wheel";
    dist = "py3";
    python = "py3";
    hash = "sha256-0PvwUamG2oCOFe4/W5+D5p5RjrANTPfn9lDGCmKr7ZY=";
  };

  dependencies = [
    numba-cuda
    pyyaml
    rapids-dask-dependency
    ucxx-cu12
  ];

  # Skip tests - requires distributed cluster
  doCheck = false;

  pythonImportsCheck = [ "distributed_ucxx" ];

  meta = {
    description = "Distributed UCXX communication backend for Dask";
    homepage = "https://github.com/rapidsai/ucxx";
    license = lib.licenses.bsd3;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    maintainers = [ ];
  };
}
