{
  lib,
  buildPythonPackage,
  fetchurl,
  pythonOlder,
  autoPatchelfHook,
  stdenv,
  # Dependencies
  cupy,
  libcugraph-cu12,
  numpy,
  pylibraft-cu12,
  rmm-cu12,
}:
buildPythonPackage rec {
  pname = "pylibcugraph-cu12";
  version = "25.10.0";
  format = "wheel";

  disabled = pythonOlder "3.10";

  # NOTE: Wheels are hosted on NVIDIA's PyPI, not standard PyPI
  src = fetchurl {
    url = "https://pypi.nvidia.com/pylibcugraph-cu12/pylibcugraph_cu12-${version}-cp312-cp312-manylinux_2_24_x86_64.manylinux_2_28_x86_64.whl";
    hash = "sha256-uSevV8cUocx3RHNY3iMXlasE/FrHdL+Pp+SFcKWsec0=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [
    stdenv.cc.cc.lib
  ];

  # Ignore CUDA runtime libraries - provided at runtime by NVIDIA drivers
  # Also ignore RAPIDS libraries that should be found via RPATH
  autoPatchelfIgnoreMissingDeps = [
    "libcublas.so.12"
    "libcublasLt.so.12"
    "libcusolver.so.11"
    "libcusparse.so.12"
    "libcurand.so.10"
    "libnvJitLink.so.12"
    "libcuda.so.1"
    "libnvidia-ml.so.1"
    "libcugraph.so"
    "libcugraph_c.so"
    "librmm.so"
    "librapids_logger.so"
  ];

  dependencies = [
    cupy # cupy-cuda12x
    libcugraph-cu12
    numpy
    pylibraft-cu12
    rmm-cu12
  ];

  # Add library search paths for RAPIDS dependencies
  preFixup = ''
    addAutoPatchelfSearchPath ${libcugraph-cu12}/lib/python3.12/site-packages/libcugraph/lib64
  '';

  # Don't strip binaries
  dontStrip = true;

  # Skip tests - requires CUDA runtime
  doCheck = false;

  # pythonImportsCheck = ["pylibcugraph"];  # Skip - requires CUDA runtime

  meta = {
    description = "Python bindings for cuGraph GPU graph analytics";
    homepage = "https://github.com/rapidsai/cugraph";
    license = lib.licenses.asl20;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    maintainers = [ ];
  };
}
