{
  lib,
  buildPythonPackage,
  fetchPypi,
  pythonOlder,
  autoPatchelfHook,
  stdenv,
  # Dependencies
  numpy,
}:
buildPythonPackage rec {
  pname = "pyarrow";
  version = "22.0.0";
  format = "wheel";

  disabled = pythonOlder "3.9";

  src = fetchPypi {
    inherit pname version;
    format = "wheel";
    dist = "cp312";
    python = "cp312";
    abi = "cp312";
    platform = "manylinux_2_28_x86_64";
    hash = "sha256-xseRsJxX7XahiwPyYxdTpJYO77vKgPhG2ouu/GSR/P4=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [
    stdenv.cc.cc.lib
  ];

  dependencies = [
    numpy
  ];

  # Don't strip binaries
  dontStrip = true;

  # Skip tests - binary wheel
  doCheck = false;

  pythonImportsCheck = [
    "pyarrow"
    "pyarrow.orc" # Verify ORC support
  ];

  meta = {
    description = "Python library for Apache Arrow with ORC support (from PyPI wheel)";
    homepage = "https://arrow.apache.org/";
    license = lib.licenses.asl20;
    platforms = [ "x86_64-linux" ];
    maintainers = [ ];
  };
}
