{
  lib,
  buildPythonPackage,
  fetchPypi,
  autoPatchelfHook,
  stdenv,
  zlib,
  rapids-logger,
  libkvikio-cu12,
  librmm-cu12,
}:
buildPythonPackage rec {
  pname = "libcudf-cu12";
  version = "25.10.0";
  format = "wheel";

  src = fetchPypi {
    pname = "libcudf_cu12";
    inherit version;
    format = "wheel";
    dist = "py3";
    python = "py3";
    abi = "none";
    platform =
      if stdenv.hostPlatform.isAarch64 then "manylinux_2_28_aarch64" else "manylinux_2_28_x86_64";
    hash = "sha256-/H3kP9Af9PVnxASXvmk14iZktJz7mLMaeDST57mw/I4=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [
    zlib
    rapids-logger
    libkvikio-cu12
    librmm-cu12
  ];

  dependencies = [
    rapids-logger
    libkvikio-cu12
    librmm-cu12
  ];

  # Add lib64 directories to autoPatchelf search path
  preFixup = ''
    addAutoPatchelfSearchPath ${rapids-logger}/lib/python3.12/site-packages/rapids_logger/lib64
    addAutoPatchelfSearchPath ${libkvikio-cu12}/lib/python3.12/site-packages/libkvikio/lib64
    addAutoPatchelfSearchPath ${librmm-cu12}/lib/python3.12/site-packages/librmm/lib64
  '';

  # Don't strip binaries - they're already stripped and stripping can break them
  dontStrip = true;

  # Skip tests - this is a binary wheel with CUDA dependencies
  doCheck = false;

  pythonImportsCheck = [ "libcudf" ];

  meta = {
    description = "C++ library for cuDF - GPU-accelerated dataframe operations";
    homepage = "https://github.com/rapidsai/cudf";
    license = lib.licenses.asl20;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    maintainers = [ ];
  };
}
