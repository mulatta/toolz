{
  lib,
  buildPythonPackage,
  fetchurl,
  pythonOlder,
  autoPatchelfHook,
  addDriverRunpath,
  stdenv,
  cudaPackages_12,
  cuda-compat,
  cudf-cu12,
  dask-cuda,
  dask-cudf-cu12,
  libcugraph-cu12,
  libraft-cu12,
  librmm-cu12,
  pylibcudf-cu12,
  pylibcugraph-cu12,
  pylibraft-cu12,
  raft-dask-cu12,
  rapids-dask-dependency,
  rapids-logger,
  rmm-cu12,
  ucxx-cu12,
  cuda-python,
  cupy,
  fsspec,
  numba,
  numpy,
}:
buildPythonPackage rec {
  pname = "cugraph-cu12";
  version = "25.10.0";
  format = "wheel";

  disabled = pythonOlder "3.10";

  # NOTE: Wheels are hosted on NVIDIA's PyPI, not standard PyPI
  src = fetchurl {
    url = "https://pypi.nvidia.com/cugraph-cu12/cugraph_cu12-${version}-cp312-cp312-manylinux_2_24_x86_64.manylinux_2_28_x86_64.whl";
    hash = "sha256-cWbSmxoA68gKxroH+9nzqVer4XiEvg77bMUeeL7TYWE=";
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

  # Propagate CUDA compatibility wrapper for runtime (cupy, numba dlopen)
  # Provides standard .so symlinks to Nix .alt.so CUDA libraries
  propagatedBuildInputs = [
    cuda-compat
  ];

  # Ignore NVIDIA driver libraries - provided at runtime by NVIDIA drivers
  # CUDA Toolkit libraries are handled via buildInputs above
  # RAPIDS libraries are handled via preFixup below
  autoPatchelfIgnoreMissingDeps = [
    "libcuda.so.1"
    "libnvidia-ml.so.1"
    "libcugraph.so"
    "libcugraph_c.so"
    "librmm.so"
    "librapids_logger.so"
  ];

  dependencies = [
    # RAPIDS
    cudf-cu12
    dask-cuda
    dask-cudf-cu12
    libcugraph-cu12
    pylibcudf-cu12
    pylibcugraph-cu12
    pylibraft-cu12
    raft-dask-cu12
    rapids-dask-dependency
    rapids-logger
    rmm-cu12
    ucxx-cu12
    # Python packages
    cuda-python
    cupy
    fsspec
    numba
    numpy
  ];

  # Add library search paths for RAPIDS dependencies
  preFixup = ''
    addAutoPatchelfSearchPath ${libcugraph-cu12}/lib/python3.12/site-packages/libcugraph/lib64
    addAutoPatchelfSearchPath ${librmm-cu12}/lib/python3.12/site-packages/librmm/lib64
    addAutoPatchelfSearchPath ${libraft-cu12}/lib/python3.12/site-packages/libraft/lib64
    addAutoPatchelfSearchPath ${rapids-logger}/lib/python3.12/site-packages/rapids_logger/lib64
  '';

  # Don't strip binaries
  dontStrip = true;

  # Skip tests - requires CUDA runtime
  doCheck = false;

  # Skip imports check - requires CUDA runtime
  # pythonImportsCheck = ["cugraph"];

  meta = {
    description = "cuGraph - GPU-accelerated graph analytics (CUDA 12)";
    homepage = "https://github.com/rapidsai/cugraph";
    license = lib.licenses.asl20;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    maintainers = [ ];
  };
}
