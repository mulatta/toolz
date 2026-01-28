{
  lib,
  buildPythonPackage,
  fetchPypi,
  pythonOlder,
  autoPatchelfHook,
  stdenv,
}:
buildPythonPackage rec {
  pname = "libucx-cu12";
  version = "1.17.0";
  format = "wheel";

  disabled = pythonOlder "3.9";

  src = fetchPypi {
    pname = "libucx_cu12";
    inherit version;
    format = "wheel";
    dist = "py3";
    python = "py3";
    abi = "none";
    platform =
      if stdenv.hostPlatform.isAarch64 then "manylinux_2_28_aarch64" else "manylinux_2_28_x86_64";
    hash = "sha256-JCtrdWjjVGt69+UbkaDg9llRvHycioJDEiAjG5PYAr8=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [
    stdenv.cc.cc.lib
  ];

  # Ignore CUDA runtime libraries - provided at runtime by NVIDIA drivers
  autoPatchelfIgnoreMissingDeps = [
    "libcuda.so.1"
    "libnvidia-ml.so.1"
  ];

  # No Python dependencies

  # Don't strip binaries
  dontStrip = true;

  # Skip tests - binary wheel
  doCheck = false;

  # pythonImportsCheck = ["libucx"];

  meta = {
    description = "Unified Communication X (UCX) library for CUDA 12";
    homepage = "https://github.com/openucx/ucx";
    license = lib.licenses.bsd3;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    maintainers = [ ];
  };
}
