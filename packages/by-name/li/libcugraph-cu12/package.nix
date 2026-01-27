{
  lib,
  buildPythonPackage,
  fetchurl,
  pythonOlder,
  autoPatchelfHook,
  addDriverRunpath,
  stdenv,
  cudaPackages_12,
  libraft-cu12,
  librmm-cu12,
  rapids-logger,
}:
buildPythonPackage rec {
  pname = "libcugraph-cu12";
  version = "25.10.0";
  format = "wheel";

  disabled = pythonOlder "3.10";

  # NOTE: Wheels are hosted on NVIDIA's PyPI, not standard PyPI
  src = fetchurl {
    url = "https://pypi.nvidia.com/libcugraph-cu12/libcugraph_cu12-${version}-py3-none-manylinux_2_27_x86_64.manylinux_2_28_x86_64.whl";
    hash = "sha256-cbAUmcKC4v6QZj16LSUFfXMMFu9zc67yr2FjNxIqA9U=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    addDriverRunpath
  ];

  buildInputs = [
    stdenv.cc.cc.lib
    # CUDA Toolkit libraries for runtime
    cudaPackages_12.libcublas
    cudaPackages_12.libcusolver
    cudaPackages_12.libcusparse
    cudaPackages_12.libcurand
    cudaPackages_12.libnvjitlink
    cudaPackages_12.cuda_cudart
  ];

  # Ignore NVIDIA driver libraries - provided at runtime by NVIDIA drivers
  autoPatchelfIgnoreMissingDeps = [
    "libcuda.so.1"
    "libnvidia-ml.so.1"
  ];

  dependencies = [
    libraft-cu12
    librmm-cu12
    rapids-logger
  ];

  # Add library search paths for RAPIDS dependencies
  preFixup = ''
    addAutoPatchelfSearchPath ${libraft-cu12}/lib/python3.12/site-packages/libraft/lib64
    addAutoPatchelfSearchPath ${librmm-cu12}/lib/python3.12/site-packages/librmm/lib64
    addAutoPatchelfSearchPath ${rapids-logger}/lib/python3.12/site-packages/rapids_logger/lib64
  '';

  # Don't strip binaries
  dontStrip = true;

  # Skip tests - binary wheel with CUDA dependencies
  doCheck = false;

  # pythonImportsCheck = ["libcugraph"];  # Skip - requires CUDA runtime

  meta = {
    description = "cuGraph GPU graph analytics core library";
    homepage = "https://github.com/rapidsai/cugraph";
    license = lib.licenses.asl20;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    maintainers = [ ];
  };
}
