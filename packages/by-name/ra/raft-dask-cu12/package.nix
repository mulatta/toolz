{
  lib,
  buildPythonPackage,
  fetchurl,
  pythonOlder,
  autoPatchelfHook,
  stdenv,
  dask-cuda,
  distributed-ucxx-cu12,
  libraft-cu12,
  librmm-cu12,
  libucx-cu12,
  nvidia-nccl-cu12,
  pylibraft-cu12,
  rapids-dask-dependency,
  rapids-logger,
}:
buildPythonPackage rec {
  pname = "raft-dask-cu12";
  version = "25.10.0";
  format = "wheel";

  disabled = pythonOlder "3.10";

  # NOTE: Wheels are hosted on NVIDIA's PyPI, not standard PyPI
  src = fetchurl {
    url = "https://pypi.nvidia.com/raft-dask-cu12/raft_dask_cu12-${version}-cp312-cp312-manylinux_2_24_x86_64.manylinux_2_28_x86_64.whl";
    hash = "sha256-5WF12kr5UpUec88A0YY7djcgGmDSDontdV/PebNOlCo=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [
    stdenv.cc.cc.lib
  ];

  dependencies = [
    dask-cuda
    distributed-ucxx-cu12
    libraft-cu12
    librmm-cu12
    libucx-cu12
    nvidia-nccl-cu12
    pylibraft-cu12
    rapids-dask-dependency
    rapids-logger
  ];

  # Add library search paths for NCCL, RMM, UCX, and RAPIDS logger
  preFixup = ''
    addAutoPatchelfSearchPath ${nvidia-nccl-cu12}/lib/python3.12/site-packages/nvidia/nccl/lib
    addAutoPatchelfSearchPath ${librmm-cu12}/lib/python3.12/site-packages/librmm/lib64
    addAutoPatchelfSearchPath ${libucx-cu12}/lib/python3.12/site-packages/libucx/lib
    addAutoPatchelfSearchPath ${rapids-logger}/lib/python3.12/site-packages/rapids_logger/lib64
  '';

  # Don't strip binaries
  dontStrip = true;

  # Skip tests - requires CUDA runtime and Dask cluster
  doCheck = false;

  pythonImportsCheck = [ "raft_dask" ];

  meta = {
    description = "Distributed RAFT algorithms for Dask";
    homepage = "https://github.com/rapidsai/raft";
    license = lib.licenses.asl20;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    maintainers = [ ];
  };
}
