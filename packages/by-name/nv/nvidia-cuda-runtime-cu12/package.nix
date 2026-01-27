{
  buildPythonPackage,
  fetchPypi,
  lib,
  autoPatchelfHook,
  stdenv,
}:
buildPythonPackage rec {
  pname = "nvidia-cuda-runtime-cu12";
  version = "12.6.77";
  format = "wheel";

  src = fetchPypi {
    pname = "nvidia_cuda_runtime_cu12";
    inherit version format;
    dist = "py3";
    python = "py3";
    abi = "none";
    platform = "manylinux2014_x86_64";
    hash = "sha256-qE0V1eHaQW3Ud0y0Lt9elUo+YMyUVpjcHVvgIyHETcg=";
  };

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];
  buildInputs = [ (lib.getLib stdenv.cc.cc) ];

  # Remove namespace __init__.py to prevent collisions (PEP 420 implicit namespace)
  postInstall = ''
    rm -f $out/lib/python*/site-packages/nvidia/__init__.py
    rm -rf $out/lib/python*/site-packages/nvidia/__pycache__
  '';

  pythonImportsCheck = [ "nvidia.cuda_runtime" ];

  meta = {
    description = "CUDA Runtime native Libraries";
    homepage = "https://developer.nvidia.com/cuda-toolkit";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
    maintainers = [ ];
  };
}
