{
  lib,
  buildPythonPackage,
  fetchPypi,
  autoPatchelfHook,
  stdenv,
  zlib,
  rapids-logger,
}:
buildPythonPackage rec {
  pname = "librmm-cu12";
  version = "25.10.0";
  format = "wheel";

  src = fetchPypi {
    pname = "librmm_cu12";
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
    hash = "sha256-4S6XAIACVi9rYdEWj02EJnelgCVgBmaab2bYcNq0t2Q=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [
    zlib
    rapids-logger
  ];

  dependencies = [
    rapids-logger
  ];

  # Add rapids-logger lib64 directory to autoPatchelf search path
  preFixup = ''
    addAutoPatchelfSearchPath ${rapids-logger}/lib/python3.12/site-packages/rapids_logger/lib64
  '';

  # Don't strip binaries
  dontStrip = true;

  # Skip tests - binary wheel with CUDA dependencies
  doCheck = false;

  pythonImportsCheck = [ "librmm" ];

  meta = {
    description = "RAPIDS Memory Manager (RMM) - GPU memory allocation library";
    homepage = "https://github.com/rapidsai/rmm";
    license = lib.licenses.asl20;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    maintainers = [ ];
  };
}
