{
  lib,
  buildPythonPackage,
  fetchPypi,
}:
buildPythonPackage rec {
  pname = "logging_exceptions";
  version = "0.1.8";
  format = "setuptools";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-CQG1SnV69CiNObEun4qKvglLhs+3OcBCipB73Rezdj4=";
  };

  pythonImportsCheck = [ "logging_exceptions" ];

  meta = with lib; {
    description = "Self-logging exceptions with conditional output";
    homepage = "https://pypi.org/project/logging-exceptions/";
    license = licenses.mit;
    maintainers = [ ];
  };
}
