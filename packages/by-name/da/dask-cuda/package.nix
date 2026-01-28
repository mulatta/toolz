{
  lib,
  buildPythonPackage,
  fetchPypi,
  pythonOlder,
  click,
  cuda-core,
  numba-cuda,
  numpy,
  nvidia-ml-py,
  pandas,
  rapids-dask-dependency,
  zict,
}:
buildPythonPackage rec {
  pname = "dask-cuda";
  version = "25.10.0";
  format = "wheel";

  disabled = pythonOlder "3.10";

  src = fetchPypi {
    pname = "dask_cuda";
    inherit version;
    format = "wheel";
    dist = "py3";
    python = "py3";
    hash = "sha256-/F9XdSVFQc18oN8ysVC71xTnb3BWGHveD2DPERlhOvc=";
  };

  dependencies = [
    click
    cuda-core
    numba-cuda
    numpy
    nvidia-ml-py
    pandas
    rapids-dask-dependency
    zict
  ];

  # Skip tests - requires CUDA runtime and Dask cluster
  doCheck = false;

  # pythonImportsCheck = ["dask_cuda"];  # Skip - requires CUDA runtime

  meta = {
    description = "CUDA support for Dask distributed computing";
    homepage = "https://github.com/rapidsai/dask-cuda";
    license = lib.licenses.asl20;
    platforms = lib.platforms.linux;
    maintainers = [ ];
  };
}
