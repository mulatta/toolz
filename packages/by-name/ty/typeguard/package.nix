{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  setuptools-scm,
  typing-extensions,
}:
buildPythonPackage rec {
  pname = "typeguard";
  version = "2.13.3";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "agronholm";
    repo = "typeguard";
    rev = "refs/tags/${version}";
    hash = "sha256-+WbfS+qzc2vFpYQ0PFME9UhZn9yL7qjdCxTV8cLivNk=";
  };

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    typing-extensions
  ];

  env.SETUPTOOLS_SCM_PRETEND_VERSION = version;

  pythonImportsCheck = [ "typeguard" ];

  # Tests require additional dependencies
  doCheck = false;

  meta = {
    description = "Run-time type checker for Python";
    homepage = "https://github.com/agronholm/typeguard";
    changelog = "https://typeguard.readthedocs.io/en/latest/versionhistory.html";
    license = lib.licenses.mit;
  };
}
