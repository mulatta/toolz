{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
  setuptools-scm,
  cython,
  xopen,
}:
let
  cython_latest = cython.overrideAttrs (_old: rec {
    version = "3.1.4";
    src = fetchPypi {
      pname = "cython";
      inherit version;
      hash = "sha256-mu/v6DEzHi1mqzF5mBTq5ND4otJGy6qqFNG+Ke93doM=";
    };
  });
in
buildPythonPackage rec {
  pname = "dnaio";
  version = "1.2.4";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-p1cDEfKeizweo5pg9Xt7r42tjyUIWVxY1CeMVXFGMWY=";
  };

  nativeBuildInputs = [ cython_latest ];

  build-system = [
    setuptools
    setuptools-scm
    cython_latest
  ];

  dependencies = [ xopen ];

  env.SETUPTOOLS_SCM_PRETEND_VERSION = version;

  pythonImportsCheck = [ "dnaio" ];

  meta = {
    description = "Read and write FASTA and FASTQ files efficiently";
    homepage = "https://github.com/marcelm/dnaio";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
  };
}
