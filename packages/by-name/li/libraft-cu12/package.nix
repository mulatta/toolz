{
  lib,
  buildPythonPackage,
  fetchPypi,
  pythonOlder,
  autoPatchelfHook,
  stdenv,
  # Dependencies
  librmm-cu12,
  nvidia-nccl-cu12,
  rapids-logger,
}:
buildPythonPackage rec {
  pname = "libraft-cu12";
  version = "25.10.0";
  format = "wheel";

  disabled = pythonOlder "3.10";

  src = fetchPypi {
    pname = "libraft_cu12";
    inherit version;
    format = "wheel";
    dist = "py3";
    python = "py3";
    abi = "none";
    platform =
      if stdenv.hostPlatform.isAarch64 then
        "manylinux_2_24_aarch64.manylinux_2_28_aarch64"
      else
        "manylinux_2_24_x86_64.manylinux_2_28_x86_64";
    hash = "sha256-wbSCz918t+mNtH2gill8yn0G61sRcRGP3IwAvvXhdCs=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [
    stdenv.cc.cc.lib
  ];

  # Ignore missing CUDA libraries - they're provided by CUDA runtime
  autoPatchelfIgnoreMissingDeps = [
    "libcublas.so.12"
    "libcublasLt.so.12"
    "libcusolver.so.11"
    "libcusparse.so.12"
    "libcurand.so.10"
    "libnvJitLink.so.12"
  ];

  dependencies = [
    librmm-cu12
    nvidia-nccl-cu12
    rapids-logger
  ];

  # Add rapids-logger lib64 directory to autoPatchelf search path
  preFixup = ''
    addAutoPatchelfSearchPath ${rapids-logger}/lib/python3.12/site-packages/rapids_logger/lib64
    addAutoPatchelfSearchPath ${librmm-cu12}/lib/python3.12/site-packages/librmm/lib64
  '';

  # Don't strip binaries
  dontStrip = true;

  # Skip tests - binary wheel with CUDA dependencies
  doCheck = false;

  # Skip imports check - requires CUDA runtime
  # pythonImportsCheck = ["libraft"];

  meta = {
    description = "RAPIDS RAFT library for GPU algorithms";
    homepage = "https://github.com/rapidsai/raft";
    license = lib.licenses.asl20;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    maintainers = [ ];
    # NOTE: Depends on nvidia-nccl-cu12 which is unfree
    # Set NIXPKGS_ALLOW_UNFREE=1 or allowUnfree=true to build
  };
}
