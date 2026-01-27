{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
  numpy,
  scipy,
  pandas,
  networkx,
  biopython,
  appdirs,
  logging-exceptions,
  cython,
  matplotlib,
  beautifulsoup4,
  scikit-learn,
}:
buildPythonPackage rec {
  pname = "forgi";
  version = "2.2.3";
  format = "setuptools";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-yHpFWxvfkfkcFGJ3ftoyzhND+xSbaIpAbfPXzry3eeo=";
  };

  nativeBuildInputs = [
    setuptools
    cython
    numpy
  ];

  propagatedBuildInputs = [
    numpy
    scipy
    pandas
    networkx
    biopython
    appdirs
    logging-exceptions
    cython
    matplotlib
    beautifulsoup4
    scikit-learn
  ];

  pythonImportsCheck = [ "forgi" ];

  meta = with lib; {
    description = "RNA Graph Library";
    homepage = "http://www.tbi.univie.ac.at/~pkerp/forgi/";
    license = licenses.gpl3Only;
    maintainers = [ ];
  };
}
