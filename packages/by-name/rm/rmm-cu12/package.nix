{
  lib,
  buildPythonPackage,
  fetchPypi,
  pythonOlder,
  cuda-python,
  librmm-cu12,
  numpy,
}:
buildPythonPackage rec {
  pname = "rmm-cu12";
  version = "25.10.0";
  format = "wheel";

  disabled = pythonOlder "3.10";

  src = fetchPypi {
    pname = "rmm_cu12";
    inherit version;
    format = "wheel";
    dist = "cp312";
    python = "cp312";
    abi = "cp312";
    platform = "manylinux_2_24_x86_64.manylinux_2_28_x86_64";
    hash = "sha256-ANJzKquamY2v2rlQMGTI/sau+Lyo5kVjdHfldKqx6C8=";
  };

  dependencies = [
    cuda-python
    librmm-cu12
    numpy
  ];

  # Skip tests - requires CUDA runtime
  doCheck = false;

  # Skip imports check - requires CUDA runtime
  # pythonImportsCheck = ["rmm"];

  meta = {
    description = "RAPIDS Memory Manager for GPU memory allocation";
    homepage = "https://github.com/rapidsai/rmm";
    license = lib.licenses.asl20;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    maintainers = [ ];
  };
}
