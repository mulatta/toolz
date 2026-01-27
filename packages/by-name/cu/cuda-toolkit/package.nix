{
  lib,
  buildPythonPackage,
  fetchPypi,
  pythonOlder,
  # NVIDIA CUDA packages (for extras)
  nvidia-cublas-cu12,
  nvidia-cuda-nvcc-cu12,
  nvidia-cuda-runtime-cu12,
  nvidia-cufft-cu12,
  nvidia-cusolver-cu12,
  nvidia-cusparse-cu12,
}:
buildPythonPackage rec {
  pname = "cuda-toolkit";
  version = "13.0.1";
  format = "wheel";

  disabled = pythonOlder "3.8";

  src = fetchPypi {
    pname = "cuda_toolkit";
    inherit version;
    format = "wheel";
    dist = "py2.py3";
    python = "py2.py3";
    hash = "sha256-/HY0JMX13eXIZTWHd5KNI6oYoBZdOAmAvTp5IXYYj/o=";
  };

  # Provide common CUDA toolkit components
  dependencies = [
    nvidia-cublas-cu12
    nvidia-cuda-nvcc-cu12
    nvidia-cuda-runtime-cu12
    nvidia-cufft-cu12
    nvidia-cusolver-cu12
    nvidia-cusparse-cu12
  ];

  # Metapackage - no tests
  doCheck = false;

  # No imports check - metapackage
  # pythonImportsCheck = [];

  meta = {
    description = "NVIDIA CUDA Toolkit metapackage for selective component installation";
    homepage = "https://pypi.org/project/cuda-toolkit/";
    license = lib.licenses.unfree;
    platforms = lib.platforms.linux;
    maintainers = [ ];
  };
}
