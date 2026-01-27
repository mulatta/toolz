{
  buildPythonPackage,
  fetchPypi,
  lib,
  autoPatchelfHook,
  stdenv,
  nvidia-cublas-cu12,
  zlib,
}:
buildPythonPackage rec {
  pname = "nvidia-cudnn-cu12";
  version = "9.5.1.17";
  format = "wheel";

  src = fetchPypi {
    pname = "nvidia_cudnn_cu12";
    inherit version format;
    dist = "py3";
    python = "py3";
    abi = "none";
    platform = "manylinux_2_28_x86_64";
    hash = "sha256-MKw4afbbF9Fw4OVW3WzF7uAmR6vDHKhWY01aQPgsFbI=";
  };

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];
  buildInputs = [
    (lib.getLib stdenv.cc.cc)
    zlib
  ];

  dependencies = [ nvidia-cublas-cu12 ];

  # Remove namespace __init__.py to prevent collisions (PEP 420 implicit namespace)
  postInstall = ''
    rm -f $out/lib/python*/site-packages/nvidia/__init__.py
    rm -rf $out/lib/python*/site-packages/nvidia/__pycache__
  '';

  pythonImportsCheck = [ "nvidia.cudnn" ];

  meta = {
    description = "NVIDIA cuDNN deep learning library";
    homepage = "https://developer.nvidia.com/cudnn";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
    maintainers = [ ];
  };
}
