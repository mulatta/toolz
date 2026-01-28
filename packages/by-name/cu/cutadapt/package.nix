{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
  setuptools-scm,
  cython,
  xopen,
  dnaio,
  isal,
  stdenv,
}:
buildPythonPackage rec {
  pname = "cutadapt";
  version = "5.1";

  format = "pyproject";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-a8djRcCkX2toDLEWTkjrH4GBXHZOxHEoSrYjTGZTuTc=";
  };

  nativeBuildInputs = [
    setuptools
    setuptools-scm
    cython
  ];

  propagatedBuildInputs = [
    xopen
    dnaio
  ]
  ++ lib.optionals stdenv.isLinux [
    isal
  ];

  SETUPTOOLS_SCM_PRETEND_VERSION = version;

  pythonImportsCheck = [ "cutadapt" ];

  meta = with lib; {
    description = "Tool to remove adapter sequences from sequencing reads";
    homepage = "https://github.com/marcelm/cutadapt";
    license = licenses.mit;
    mainProgram = "cutadapt";
  };
}
