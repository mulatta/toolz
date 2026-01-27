{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
  pyparsing,
}:
buildPythonPackage rec {
  pname = "pyclibrary";
  version = "0.2.2";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-mQL//jYbuG9Xq2KqQZXsTdOCtjxcaJK+bZeE7Ao1dfc=";
  };

  build-system = [ setuptools ];

  dependencies = [ pyparsing ];

  pythonImportsCheck = [ "pyclibrary" ];

  # No tests in PyPI sdist
  doCheck = false;

  meta = {
    description = "Python interface to C libraries using ctypes";
    homepage = "https://github.com/MatthieuDartiailh/pyclibrary";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
