{
  lib,
  buildPythonPackage,
  fetchPypi,
  autoPatchelfHook,
  stdenv,
  zlib,
}:
buildPythonPackage rec {
  pname = "libkvikio-cu12";
  version = "25.10.0";
  format = "wheel";

  src = fetchPypi {
    pname = "libkvikio_cu12";
    inherit version;
    format = "wheel";
    dist = "py3";
    python = "py3";
    abi = "none";
    platform =
      if stdenv.hostPlatform.isAarch64 then "manylinux_2_28_aarch64" else "manylinux_2_28_x86_64";
    hash = "sha256-XKn9xuh/JhbBTPV02DjZrDUh8MdoVGnxkR9kXdeLG6g=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [
    zlib
  ];

  # Don't strip binaries
  dontStrip = true;

  # Skip tests - binary wheel with CUDA dependencies
  doCheck = false;

  pythonImportsCheck = [ "libkvikio" ];

  meta = {
    description = "High performance file IO library with GPUDirect Storage (GDS) support";
    homepage = "https://github.com/rapidsai/kvikio";
    license = lib.licenses.asl20;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    maintainers = [ ];
  };
}
