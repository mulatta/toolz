{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  fetchurl,
  fetchPypi,
  # Build
  cmake,
  ninja,
  scikit-build-core,
  pybind11,
  gzip,
  bash,
  # C++ dependencies
  abseil-cpp,
  pybind11-abseil,
  libcifpp,
  dssp,
  zlib,
  boost,
  # Runtime binaries
  hmmer,
  # Python dependencies
  absl-py,
  dm-tree,
  numpy,
  pillow,
  rdkit,
  scipy,
  triton,
  tqdm,
  zstandard,
  # CUDA libraries
  nvidia-cuda-runtime-cu12,
  nvidia-cublas-cu12,
  nvidia-cudnn-cu12,
  nvidia-cusparse-cu12,
  nvidia-cusolver-cu12,
  nvidia-cufft-cu12,
  nvidia-cuda-cupti-cu12,
  nvidia-nccl-cu12,
  nvidia-nvjitlink-cu12,
  # Build dependencies for local JAX packages
  setuptools,
  wheel,
  ml-dtypes,
  opt-einsum,
  flatbuffers,
  autoPatchelfHook,
  stdenv,
  python,
  hatchling,
  setuptools-scm,
  typing-extensions,
  # For chex and dm-haiku overrides
  chex,
  dm-haiku,
  jmp,
  jax-cuda12-pjrt,
  jax-cuda12-plugin,
  jax-triton,
}:
let
  # Local JAX ecosystem for AlphaFold3 (version 0.4.34)
  # NOTE: Not exposed globally to avoid conflicts with nixpkgs JAX 0.6.0
  # Local typeguard 2.13.3 (required by jaxtyping 0.2.34)
  typeguard-local = buildPythonPackage rec {
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
    dependencies = [ typing-extensions ];
    env.SETUPTOOLS_SCM_PRETEND_VERSION = version;
    pythonImportsCheck = [ "typeguard" ];
    doCheck = false;
  };

  # Local jaxlib 0.4.34 (prebuilt wheel)
  # NOTE: dist parameter must be set to PyPI's hash-based path for platform-specific wheels
  jaxlib-local =
    let
      inherit (python) pythonVersion;

      srcs = {
        "3.10-x86_64-linux" = fetchPypi {
          pname = "jaxlib";
          version = "0.4.34";
          format = "wheel";
          dist = "e4/b0/a5bd34643c070e50829beec217189eab1acdfea334df1f9ddb4e5f8bec0f";
          python = "cp310";
          abi = "cp310";
          platform = "manylinux2014_x86_64";
          hash = "sha256-2A5mSIVUbm1RbnJh/j0VnQpHq/V/vugpnzc2chg9wtI=";
        };
        "3.11-x86_64-linux" = fetchPypi {
          pname = "jaxlib";
          version = "0.4.34";
          format = "wheel";
          dist = "c7/d0/6bc81c0b1d507f403e6085ce76a429e6d7f94749d742199252e299dd1424";
          python = "cp311";
          abi = "cp311";
          platform = "manylinux2014_x86_64";
          hash = "sha256-O8/jpDpkqaMo+KPKoQzXe8jbEz9X8F3VL6w2Oyq1v18=";
        };
        "3.12-x86_64-linux" = fetchPypi {
          pname = "jaxlib";
          version = "0.4.34";
          format = "wheel";
          dist = "e7/0d/4faf839e3c8ce2a5b615df64427be3e870899c72c0ebfb5859348150aba1";
          python = "cp312";
          abi = "cp312";
          platform = "manylinux2014_x86_64";
          hash = "sha256-SCcukDT/ho1DKM8AVaB4gv0r6T9Z37YoOvfeSR+dEpA=";
        };
      };
    in
    buildPythonPackage {
      pname = "jaxlib";
      version = "0.4.34";
      format = "wheel";

      src =
        srcs."${pythonVersion}-${stdenv.hostPlatform.system}"
          or (throw "jaxlib 0.4.34 is not supported on ${stdenv.hostPlatform.system} with Python ${pythonVersion}");

      nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];
      buildInputs = [ (lib.getLib stdenv.cc.cc) ];
      dependencies = [
        absl-py
        flatbuffers
        ml-dtypes
        scipy
      ];
      pythonImportsCheck = [ "jaxlib" ];
    };

  # Local jax 0.4.34 (source build)
  jax-local = buildPythonPackage rec {
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
      jaxlib-local
      ml-dtypes
      numpy
      opt-einsum
      scipy
    ];
    env.JAX_RELEASE = "1";
    pythonImportsCheck = [ "jax" ];
    doCheck = false;
  };

  # Local jaxtyping 0.2.34 (with local typeguard)
  jaxtyping-local = buildPythonPackage rec {
    pname = "jaxtyping";
    version = "0.2.34";
    pyproject = true;

    src = fetchFromGitHub {
      owner = "patrick-kidger";
      repo = "jaxtyping";
      rev = "refs/tags/v${version}";
      hash = "sha256-zkB8/+0PmBKDFhj9dd8QZ5Euglm+W3BBUM4dwFUYYW8=";
    };

    build-system = [ hatchling ];
    dependencies = [
      typeguard-local
      typing-extensions
    ];
    pythonImportsCheck = [ "jaxtyping" ];
    doCheck = false;
  };

  # Override chex to use local JAX
  chex-local = chex.override {
    jax = jax-local;
    jaxlib = jaxlib-local;
  };

  # Override jmp to use local JAX
  jmp-local = jmp.override {
    jax = jax-local;
    jaxlib = jaxlib-local;
  };

  # Override dm-haiku to use local JAX and jmp
  dm-haiku-local = dm-haiku.override {
    jaxlib = jaxlib-local;
    jmp = jmp-local;
  };

  # Override jax-cuda12-pjrt to use local JAX
  jax-cuda12-pjrt-local = jax-cuda12-pjrt.override {
    jax = jax-local;
  };

  # Override jax-cuda12-plugin to use local jax-cuda12-pjrt
  jax-cuda12-plugin-local = jax-cuda12-plugin.override {
    jax-cuda12-pjrt = jax-cuda12-pjrt-local;
  };

  # Override jax-triton to use local jax and jax-cuda12-plugin
  jax-triton-local = jax-triton.override {
    jax = jax-local;
    jaxlib = jaxlib-local;
    jax-cuda12-plugin = jax-cuda12-plugin-local;
  };

  # PDB snapshot (2025-01-01) for reproducibility
  componentsCif = fetchurl {
    url = "https://pdbsnapshots.s3-us-west-2.amazonaws.com/20250101/pub/pdb/data/monomers/components.cif.gz";
    hash = "sha256-2bJpHBYaZiKF13HXKWZen6YqA4tJeBy31zu+HrlC+Fw=";
  };
in
buildPythonPackage rec {
  pname = "alphafold3";
  version = "3.0.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "google-deepmind";
    repo = "alphafold3";
    rev = "v${version}";
    hash = "sha256-5kUTsQkdYVtMN8CasL5+xwBIfBKs2A36MCIg9Bo3kG0=";
  };

  patches = [
    # Check LIBCIFPP_DATA_DIR before site.getsitepackages() for withPackages support
    ./libcifpp-env-var-first.patch
    # Replace CMake FetchContent with system dependencies
    ./cmake-use-system-deps.patch
  ];

  # CMake needs these environment variables (patch file uses them)
  env = {
    PYBIND11_ABSEIL_PATH = "${pybind11-abseil}";
  };

  postInstall = ''
    # Install database fetching script
    install -Dm755 $src/fetch_databases.sh $out/bin/fetch_databases.sh
    substituteInPlace $out/bin/fetch_databases.sh \
      --replace-fail '#!/bin/bash' '#!${bash}/bin/bash'
  '';

  nativeBuildInputs = [
    cmake
    ninja
    scikit-build-core
    pybind11
    gzip
    # CMake config packages must be in nativeBuildInputs for find_package to work
    libcifpp
    dssp
  ];

  buildInputs = [
    abseil-cpp
    pybind11-abseil
    libcifpp
    dssp
    zlib
    boost
  ];

  # HMMER is needed for sequence alignment but not propagated by withPackages
  # Users should include HMMER in their environment (e.g., via devShell or CLI package)
  propagatedBuildInputs = [ hmmer ];

  dependencies = [
    absl-py
    chex-local # Override to use local JAX 0.4.34
    dm-haiku-local # Override to use local JAX 0.4.34
    dm-tree
    jax-local # Local JAX 0.4.34
    jaxlib-local # Local jaxlib 0.4.34
    jax-cuda12-plugin-local # Override to use local JAX 0.4.34
    jax-triton-local # Override to use local jax-cuda12-plugin
    jaxtyping-local # Local jaxtyping 0.2.34 with typeguard 2.13.3
    numpy
    pillow
    rdkit
    scipy
    triton
    tqdm
    zstandard
    nvidia-cuda-runtime-cu12
    nvidia-cublas-cu12
    nvidia-cudnn-cu12
    nvidia-cusparse-cu12
    nvidia-cusolver-cu12
    nvidia-cufft-cu12
    nvidia-cuda-cupti-cu12
    nvidia-nccl-cu12
    nvidia-nvjitlink-cu12
  ];

  dontUseCmakeConfigure = true;
  dontCheckRuntimeDeps = true; # rdkit is available via dependencies

  pythonImportsCheck = [ "alphafold3" ];
  doCheck = false; # Tests require model weights

  passthru = {
    inherit componentsCif; # For pickle generation in python-packages.nix
  };

  meta = {
    description = "Accurate structure prediction of biomolecular interactions with AlphaFold 3";
    longDescription = ''
      AlphaFold 3 predicts the structure and interactions of biological molecules.
      Model parameters must be obtained separately from Google DeepMind.
      Requires CUDA 12.x GPU for inference.
    '';
    homepage = "https://github.com/google-deepmind/alphafold3";
    changelog = "https://github.com/google-deepmind/alphafold3/releases/tag/v${version}";
    license = lib.licenses.cc-by-nc-sa-40;
    platforms = [ "x86_64-linux" ]; # jaxlib 0.4.34 wheels only available for x86_64
  };
}
