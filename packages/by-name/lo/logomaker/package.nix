{
  lib,
  buildPythonPackage,
  fetchPypi,
  hatchling,
  numpy,
  matplotlib,
  pandas,
}:
buildPythonPackage rec {
  pname = "logomaker";
  version = "0.8.7";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-Y3g85uJESdbx8BzinErhuR9uVLwZjl2kCtGPzQ78MwI=";
  };

  build-system = [hatchling];

  dependencies = [
    numpy
    matplotlib
    pandas
  ];

  pythonImportsCheck = ["logomaker"];

  meta = {
    description = "Python library for creating sequence logos";
    homepage = "https://github.com/jbkinney/logomaker";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
  };
}
