{
  lib,
  buildPythonPackage,
  fetchPypi,
  pythonOlder,
  autoPatchelfHook,
  stdenv,
  librmm-cu12,
  libucx-cu12,
}:
buildPythonPackage rec {
  pname = "libucxx-cu12";
  version = "0.46.0";
  format = "wheel";

  disabled = pythonOlder "3.10";

  src = fetchPypi {
    pname = "libucxx_cu12";
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
    hash = "sha256-2/l1lUGZo/pkHaI/vtN439ucMMZAHsb495FLxcCviik=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [
    stdenv.cc.cc.lib
  ];

  dependencies = [
    librmm-cu12
    libucx-cu12
  ];

  # Add lib64 directories to autoPatchelf search path
  preFixup = ''
    addAutoPatchelfSearchPath ${librmm-cu12}/lib/python3.12/site-packages/librmm/lib64
    addAutoPatchelfSearchPath ${libucx-cu12}/lib/python3.12/site-packages/libucx/lib
  '';

  # Don't strip binaries
  dontStrip = true;

  # Skip tests - binary wheel
  doCheck = false;

  pythonImportsCheck = [ "libucxx" ];

  meta = {
    description = "UCXX unified communication framework library for CUDA 12";
    homepage = "https://github.com/rapidsai/ucxx";
    license = lib.licenses.bsd3;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    maintainers = [ ];
  };
}
