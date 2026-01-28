{
  lib,
  buildPythonPackage,
  fetchPypi,
  pythonOlder,
  cuda-bindings,
}:
buildPythonPackage rec {
  pname = "cuda-python";
  version = "12.9.2";
  format = "wheel";

  disabled = pythonOlder "3.9";

  src = fetchPypi {
    pname = "cuda_python";
    inherit version;
    format = "wheel";
    dist = "py3";
    python = "py3";
    hash = "sha256-tQTXc9bxWJSGFD4OSYRoD3j0a6ZybOKpV6wyiXMFJko=";
  };

  dependencies = [
    cuda-bindings
  ];

  # Skip tests - requires CUDA runtime
  doCheck = false;

  # Skip imports check - requires CUDA runtime
  # pythonImportsCheck = ["cuda"];

  meta = {
    description = "Python interface for NVIDIA's CUDA platform";
    homepage = "https://nvidia.github.io/cuda-python/";
    license = lib.licenses.asl20;
    platforms = lib.platforms.linux;
    maintainers = [ ];
  };
}
