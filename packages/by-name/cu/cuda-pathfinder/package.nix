{
  lib,
  buildPythonPackage,
  fetchPypi,
  pythonOlder,
}:
buildPythonPackage rec {
  pname = "cuda-pathfinder";
  version = "1.1.0";
  format = "wheel";

  disabled = pythonOlder "3.9";

  src = fetchPypi {
    pname = "cuda_pathfinder";
    inherit version;
    format = "wheel";
    dist = "py3";
    python = "py3";
    hash = "sha256-Pmb+Cvjq0g7KJeB30uDLLcwCfUKX1VCnT5mgIR5hB5k=";
  };

  # No runtime dependencies

  # Skip tests - requires CUDA toolkit
  doCheck = false;

  pythonImportsCheck = [ "cuda.pathfinder" ];

  meta = {
    description = "Pathfinder for CUDA components";
    homepage = "https://pypi.org/project/cuda-pathfinder/";
    license = lib.licenses.asl20;
    platforms = lib.platforms.linux;
    maintainers = [ ];
  };
}
