{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
  numba,
  # CUDA 12 dependencies (will be optional extras)
  cuda-python,
}:
buildPythonPackage rec {
  pname = "numba-cuda";
  version = "0.19.1";
  pyproject = true;

  src = fetchPypi {
    pname = "numba_cuda";
    inherit version;
    hash = "sha256-GBYAyoy9xZhMO0GYiA9xApsRbf3gOXvO72Zv+DCnLJA=";
  };

  build-system = [ setuptools ];

  dependencies = [
    numba
    cuda-python # CUDA bindings for numba.cuda
  ];

  pythonImportsCheck = [ "numba_cuda" ];

  # Skip tests - they require CUDA hardware
  doCheck = false;

  meta = {
    description = "CUDA target for Numba - GPU acceleration support";
    homepage = "https://github.com/numba/numba-cuda";
    license = lib.licenses.bsd2;
    maintainers = [ ];
  };
}
