{
  lib,
  buildPythonPackage,
  fetchPypi,
  pythonOlder,
  numpy,
  cuda-bindings,
}:
buildPythonPackage rec {
  pname = "cuda-core";
  version = "0.3.0";
  format = "wheel";

  disabled = pythonOlder "3.9";

  src = fetchPypi {
    pname = "cuda_core";
    inherit version;
    format = "wheel";
    dist = "cp312";
    python = "cp312";
    abi = "cp312";
    platform = "manylinux_2_17_x86_64.manylinux2014_x86_64";
    hash = "sha256-xMOHwPYAEApkzFwgF51/KgEdY869rU1gWrll6xCtgOM=";
  };

  dependencies = [
    numpy
    cuda-bindings
  ];

  # Skip tests - requires CUDA toolkit
  doCheck = false;

  # Skip imports check - requires CUDA runtime
  # pythonImportsCheck = ["cuda.core"];

  meta = {
    description = "Pythonic CUDA runtime access and parallel algorithms";
    homepage = "https://pypi.org/project/cuda-core/";
    license = lib.licenses.asl20;
    platforms = lib.platforms.linux;
    maintainers = [ ];
  };
}
