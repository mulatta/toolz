{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  hatchling,
  setuptools,
  setuptools-scm,
  typing-extensions,
}:
let
  # Local typeguard to satisfy exact version requirement (==2.13.3)
  # NOTE: Not exposed globally to avoid conflicts with nixpkgs typeguard 4.x
  typeguard-2_13_3 = buildPythonPackage rec {
    pname = "typeguard";
    version = "2.13.3";
    pyproject = true;

    src = fetchFromGitHub {
      owner = "agronholm";
      repo = "typeguard";
      rev = "refs/tags/${version}";
      hash = "sha256-+WbfS+qzc2vFpYQ0PFME9UhZn9yL7qjdCxTV8cLivNk=";
    };

    build-system = [
      setuptools
      setuptools-scm
    ];

    dependencies = [
      typing-extensions
    ];

    env.SETUPTOOLS_SCM_PRETEND_VERSION = version;
    pythonImportsCheck = [ "typeguard" ];
    doCheck = false;

    meta = {
      description = "Run-time type checker for Python (pinned for jaxtyping compatibility)";
      homepage = "https://github.com/agronholm/typeguard";
      license = lib.licenses.mit;
    };
  };
in
buildPythonPackage rec {
  pname = "jaxtyping";
  version = "0.2.34";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "patrick-kidger";
    repo = "jaxtyping";
    rev = "refs/tags/v${version}";
    hash = "sha256-zkB8/+0PmBKDFhj9dd8QZ5Euglm+W3BBUM4dwFUYYW8=";
  };

  build-system = [
    hatchling
  ];

  dependencies = [
    typeguard-2_13_3
  ];

  pythonImportsCheck = [ "jaxtyping" ];

  # Tests require JAX and other heavy dependencies
  doCheck = false;

  meta = {
    description = "Type annotations and runtime checking for shape and dtype of JAX arrays";
    homepage = "https://github.com/patrick-kidger/jaxtyping";
    license = lib.licenses.mit;
  };
}
