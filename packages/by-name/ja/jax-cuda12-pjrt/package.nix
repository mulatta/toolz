{
  buildPythonPackage,
  fetchPypi,
  lib,
  autoPatchelfHook,
  stdenv,
  jax,
}:
buildPythonPackage rec {
  pname = "jax-cuda12-pjrt";
  version = "0.4.34";
  format = "wheel";

  src = fetchPypi {
    pname = "jax_cuda12_pjrt";
    inherit version format;
    dist = "py3";
    python = "py3";
    abi = "none";
    platform = "manylinux2014_x86_64";
    hash = "sha256-DHzJj5Ysx/yOCl6mMxtCoM7lFvIC8cMBn2qlzZUwzKA=";
  };

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];
  buildInputs = [ (lib.getLib stdenv.cc.cc) ];

  dependencies = [ jax ];

  pythonImportsCheck = [ "jax_plugins.xla_cuda12" ];

  meta = {
    description = "JAX XLA PJRT Plugin for CUDA 12";
    homepage = "https://github.com/google/jax";
    license = lib.licenses.asl20;
    platforms = [ "x86_64-linux" ];
    maintainers = [ ];
  };
}
