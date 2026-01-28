{
  lib,
  buildPythonPackage,
  fetchPypi,
  pythonOlder,
  cuda-python,
  libraft-cu12,
  numpy,
  rmm-cu12,
}:
buildPythonPackage rec {
  pname = "pylibraft-cu12";
  version = "25.10.0";
  format = "wheel";

  disabled = pythonOlder "3.10";

  src = fetchPypi {
    pname = "pylibraft_cu12";
    inherit version;
    format = "wheel";
    dist = "cp312";
    python = "cp312";
    abi = "cp312";
    platform = "manylinux_2_24_x86_64.manylinux_2_28_x86_64";
    hash = "sha256-6U5pMv8I5N+ypl5U5sZBZLIErBNzGUE3t3hzueefxJ4=";
  };

  dependencies = [
    cuda-python
    libraft-cu12
    numpy
    rmm-cu12
  ];

  # Skip tests - requires CUDA runtime
  doCheck = false;

  # Skip imports check - requires CUDA runtime
  # pythonImportsCheck = ["pylibraft"];

  meta = {
    description = "Python bindings for RAPIDS RAFT library";
    homepage = "https://github.com/rapidsai/raft";
    license = lib.licenses.asl20;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    maintainers = [ ];
  };
}
