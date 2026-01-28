{
  buildPythonPackage,
  fetchPypi,
  lib,
  autoPatchelfHook,
  stdenv,
  jax-cuda12-pjrt,
  nvidia-cublas-cu12,
  nvidia-cuda-cupti-cu12,
  nvidia-cuda-nvcc-cu12,
  nvidia-cuda-runtime-cu12,
  nvidia-cudnn-cu12,
  nvidia-cufft-cu12,
  nvidia-cusolver-cu12,
  nvidia-cusparse-cu12,
  nvidia-nccl-cu12,
  nvidia-nvjitlink-cu12,
}:
buildPythonPackage rec {
  pname = "jax-cuda12-plugin";
  version = "0.4.34";
  format = "wheel";

  src = fetchPypi {
    pname = "jax_cuda12_plugin";
    inherit version format;
    dist = "cp312";
    python = "cp312";
    abi = "cp312";
    platform = "manylinux2014_x86_64";
    hash = "sha256-25iLe6UGNIOpNt2/Fi8E0bRBLg1kNA8ReIx7vId+ikM=";
  };

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];
  buildInputs = [ (lib.getLib stdenv.cc.cc) ];

  dependencies = [
    jax-cuda12-pjrt
    nvidia-cublas-cu12
    nvidia-cuda-cupti-cu12
    nvidia-cuda-nvcc-cu12
    nvidia-cuda-runtime-cu12
    nvidia-cudnn-cu12
    nvidia-cufft-cu12
    nvidia-cusolver-cu12
    nvidia-cusparse-cu12
    nvidia-nccl-cu12
    nvidia-nvjitlink-cu12
  ];

  pythonImportsCheck = [ "jax_cuda12_plugin" ];

  meta = {
    description = "JAX Plugin for CUDA 12 (with-cuda extra)";
    homepage = "https://github.com/google/jax";
    license = lib.licenses.asl20;
    platforms = [ "x86_64-linux" ];
    maintainers = [ ];
  };
}
