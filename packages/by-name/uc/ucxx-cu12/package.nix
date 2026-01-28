{
  lib,
  buildPythonPackage,
  fetchPypi,
  pythonOlder,
  libucxx-cu12,
  numba-cuda,
  numpy,
  nvidia-ml-py,
  rmm-cu12,
}:
buildPythonPackage rec {
  pname = "ucxx-cu12";
  version = "0.46.0";
  format = "wheel";

  disabled = pythonOlder "3.10";

  src = fetchPypi {
    pname = "ucxx_cu12";
    inherit version;
    format = "wheel";
    dist = "cp312";
    python = "cp312";
    abi = "cp312";
    platform = "manylinux_2_27_x86_64.manylinux_2_28_x86_64";
    hash = "sha256-Nx49vNTBKhKqOElIXbG5/OkywRxMIr6qM6YUn+RPs9Q=";
  };

  dependencies = [
    libucxx-cu12
    numba-cuda
    numpy
    nvidia-ml-py
    rmm-cu12
  ];

  # Skip tests - requires CUDA runtime
  doCheck = false;

  # pythonImportsCheck = ["ucxx"];  # Skip - requires CUDA runtime

  meta = {
    description = "Python bindings for UCXX unified communication framework";
    homepage = "https://github.com/rapidsai/ucxx";
    license = lib.licenses.bsd3;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    maintainers = [ ];
  };
}
