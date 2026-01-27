{
  lib,
  stdenv,
  buildPythonPackage,
  fetchPypi,
  pythonOlder,
  autoPatchelfHook,
  cuda-pathfinder,
}:
buildPythonPackage rec {
  pname = "cuda-bindings";
  version = "12.9.2";
  format = "wheel";

  disabled = pythonOlder "3.9";

  src = fetchPypi {
    pname = "cuda_bindings";
    inherit version;
    format = "wheel";
    dist = "cp312";
    python = "cp312";
    abi = "cp312";
    platform = "manylinux_2_24_x86_64.manylinux_2_28_x86_64";
    hash = "sha256-2ertesmOThumFhdrKR8/MJ8gr2pqeaNNp3OaqdvgYKc=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [
    stdenv.cc.cc.lib
  ];

  dependencies = [
    cuda-pathfinder
  ];

  # Skip tests - requires CUDA toolkit
  doCheck = false;

  # Skip imports check - requires CUDA runtime
  # pythonImportsCheck = ["cuda.bindings"];

  meta = {
    description = "Low-level CUDA C API interfaces for Python";
    homepage = "https://pypi.org/project/cuda-bindings/";
    license = lib.licenses.asl20;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    maintainers = [ ];
  };
}
