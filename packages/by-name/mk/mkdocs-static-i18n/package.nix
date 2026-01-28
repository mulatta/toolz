{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  hatchling,
  mkdocs,
  pythonOlder,
}:
buildPythonPackage rec {
  pname = "mkdocs-static-i18n";
  version = "1.3.0";
  pyproject = true;

  disabled = pythonOlder "3.8";

  src = fetchFromGitHub {
    owner = "ultrabug";
    repo = "mkdocs-static-i18n";
    rev = version;
    hash = "sha256-+fcwo3wLtOCopfTTsyfJbh5SR8F+XO24WOShUq0awy4=";
  };

  build-system = [
    hatchling
  ];

  dependencies = [
    mkdocs
  ];

  # No tests in the repository
  doCheck = false;

  pythonImportsCheck = [
    "mkdocs_static_i18n"
  ];

  meta = {
    description = "MkDocs i18n plugin using static translation markdown files";
    homepage = "https://github.com/ultrabug/mkdocs-static-i18n";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
