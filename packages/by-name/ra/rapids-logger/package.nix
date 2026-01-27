{
  lib,
  buildPythonPackage,
  fetchPypi,
  pythonOlder,
  autoPatchelfHook,
  stdenv,
}:
buildPythonPackage rec {
  pname = "rapids-logger";
  version = "0.1.19";
  format = "wheel";

  disabled = pythonOlder "3.10";

  src = fetchPypi {
    pname = "rapids_logger";
    inherit version;
    format = "wheel";
    dist = "py3";
    python = "py3";
    abi = "none";
    platform =
      if stdenv.hostPlatform.isAarch64 then
        "manylinux_2_26_aarch64.manylinux_2_28_aarch64"
      else
        "manylinux_2_27_x86_64.manylinux_2_28_x86_64";
    hash = "sha256-Z5e+tKDWh0ZYlE3cOKEkUFnNMKxjBPHh8rfYwj233Rg=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [
    stdenv.cc.cc.lib
  ];

  # No Python dependencies

  # Skip tests - binary wheel
  doCheck = false;

  # Skip imports check - C++ library
  # pythonImportsCheck = ["rapids_logger"];

  meta = {
    description = "Logging framework for RAPIDS built around spdlog";
    homepage = "https://github.com/rapidsai/rapids-logger";
    license = lib.licenses.asl20;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    maintainers = [ ];
  };
}
