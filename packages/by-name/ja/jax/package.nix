{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  wheel,
  jaxlib,
  ml-dtypes,
  numpy,
  opt-einsum,
  scipy,
  pytestCheckHook,
}:
buildPythonPackage rec {
  pname = "jax";
  version = "0.4.34";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "jax-ml";
    repo = "jax";
    rev = "refs/tags/jax-v${version}";
    hash = "sha256-f49YECYVkb5NpG/5GSSVW3D3J0Lruq2gI62iiXSOHkw=";
  };

  build-system = [
    setuptools
    wheel
  ];

  dependencies = [
    jaxlib
    ml-dtypes
    numpy
    opt-einsum
    scipy
  ];

  # Force release version (not dev version)
  env.JAX_RELEASE = "1";

  pythonImportsCheck = [ "jax" ];

  # Tests require GPU/TPU
  doCheck = false;

  nativeCheckInputs = [
    pytestCheckHook
  ];

  meta = {
    description = "Composable transformations of Python+NumPy programs: differentiate, vectorize, JIT to GPU/TPU, and more";
    homepage = "https://github.com/jax-ml/jax";
    changelog = "https://github.com/jax-ml/jax/releases/tag/jax-v${version}";
    license = lib.licenses.asl20;
  };
}
