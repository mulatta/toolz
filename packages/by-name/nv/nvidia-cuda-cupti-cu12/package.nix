{
  buildPythonPackage,
  fetchPypi,
  lib,
  autoPatchelfHook,
  stdenv,
}:
buildPythonPackage rec {
  pname = "nvidia-cuda-cupti-cu12";
  version = "12.6.80";
  format = "wheel";

  src = fetchPypi {
    pname = "nvidia_cuda_cupti_cu12";
    inherit version format;
    dist = "py3";
    python = "py3";
    abi = "none";
    platform = "manylinux2014_x86_64";
    hash = "sha256-o+/2zfzGpMNduWigb8rbBhy8fW3eVIYJqUH/hwG5i3M=";
  };

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];
  buildInputs = [ (lib.getLib stdenv.cc.cc) ];

  # Remove namespace __init__.py to prevent collisions (PEP 420 implicit namespace)
  postInstall = ''
    rm -f $out/lib/python*/site-packages/nvidia/__init__.py
    rm -rf $out/lib/python*/site-packages/nvidia/__pycache__
  '';

  pythonImportsCheck = [ "nvidia.cuda_cupti" ];

  meta = {
    description = "CUDA Profiling Tools Interface";
    homepage = "https://developer.nvidia.com/cuda-toolkit";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
    maintainers = [ ];
  };
}
