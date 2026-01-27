{
  lib,
  buildPythonPackage,
  fetchPypi,
  autoPatchelfHook,
  stdenv,
  libcudf-cu12,
  rmm-cu12,
}:
buildPythonPackage rec {
  pname = "pylibcudf-cu12";
  version = "25.10.0";
  format = "wheel";

  src = fetchPypi {
    pname = "pylibcudf_cu12";
    inherit version;
    format = "wheel";
    dist = "cp312";
    python = "cp312";
    abi = "cp312";
    platform =
      if stdenv.hostPlatform.isAarch64 then
        "manylinux_2_24_aarch64.manylinux_2_28_aarch64"
      else
        "manylinux_2_24_x86_64.manylinux_2_28_x86_64";
    hash = "sha256-WJqkdpyRkKOHKzQXD7bCbQ9ngoFA+I0gBI3PZ+cxzUc=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [
    libcudf-cu12
  ];

  dependencies = [
    libcudf-cu12
    rmm-cu12
  ];

  # Add libcudf lib64 directory to autoPatchelf search path
  preFixup = ''
    addAutoPatchelfSearchPath ${libcudf-cu12}/lib/python3.12/site-packages/libcudf/lib64
  '';

  # Don't strip binaries
  dontStrip = true;

  # Skip tests - binary wheel with CUDA dependencies
  doCheck = false;

  # Skip imports check - requires CUDA runtime
  # pythonImportsCheck = ["pylibcudf"];

  meta = {
    description = "Python bindings for libcudf - GPU-accelerated dataframe operations";
    homepage = "https://github.com/rapidsai/cudf";
    license = lib.licenses.asl20;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    maintainers = [ ];
  };
}
