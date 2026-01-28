{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
  setuptools-scm,
  zlib-ng,
  isal,
  importlib-metadata,
  pythonOlder,
  stdenv,
}:
buildPythonPackage rec {
  pname = "xopen";
  version = "2.0.2";
  format = "pyproject";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-8Z2D3kcPWoFyXfAUAYDscdGYMRodfa1I9UZ7StXfYVQ=";
  };

  nativeBuildInputs = [
    setuptools
    setuptools-scm
  ];

  buildInputs = [ zlib-ng ];

  propagatedBuildInputs =
    lib.optionals stdenv.isLinux [ isal ] ++ lib.optionals (pythonOlder "3.10") [ importlib-metadata ];

  dontCheckRuntimeDeps = true;
  pythonImportsCheck = [ "xopen" ];

  meta = with lib; {
    description = "Open compressed files transparently";
    homepage = "https://github.com/pycompression/xopen";
    license = licenses.mit;
    platforms = platforms.unix;
  };
}
