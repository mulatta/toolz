{
  lib,
  buildPythonPackage,
  fetchPypi,
  # Build dependencies
  hatchling,
  # Python dependencies
  markdown,
  pyyaml,
  pygments,
}:
buildPythonPackage rec {
  pname = "pymdown-extensions";
  version = "10.17.1";
  pyproject = true;

  src = fetchPypi {
    pname = "pymdown_extensions";
    inherit version;
    hash = "sha256-YNBf5V5/taHkdA/FdfrK0g3G7jp0jo09NrpEFC51zgM=";
  };

  build-system = [ hatchling ];

  dependencies = [
    markdown
    pyyaml
    pygments
  ];

  pythonImportsCheck = [ "pymdownx" ];

  meta = with lib; {
    description = "Extension pack for Python Markdown";
    homepage = "https://github.com/facelessuser/pymdown-extensions";
    license = licenses.mit;
    maintainers = [ ];
  };
}
