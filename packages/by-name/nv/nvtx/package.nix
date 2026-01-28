{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
  cython,
}:
buildPythonPackage rec {
  pname = "nvtx";
  version = "0.2.13";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-nbe6E1Fo4U4fA4hmEAv47ULT4AtATpvHtigO46+Ci5I=";
  };

  build-system = [
    setuptools
    cython
  ];

  # Patch to remove strict Cython version requirement
  postPatch = ''
    # Try different config files
    for file in setup.py setup.cfg pyproject.toml; do
      if [ -f "$file" ]; then
        substituteInPlace "$file" \
          --replace-warn "Cython==3.0.11" "Cython>=3.0"
      fi
    done
  '';

  pythonImportsCheck = [ "nvtx" ];

  meta = {
    description = "Python code annotation library for NVIDIA Nsight Systems profiling";
    homepage = "https://github.com/NVIDIA/NVTX";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
}
