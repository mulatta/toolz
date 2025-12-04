{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  pkg-config,
  cargo,
  rustc,
  perl,
  zlib,
  bzip2,
  llvmPackages,
  config,
  cudaSupport ? config.cudaSupport or false,
  cudaPackages ? {},
}: let
  inherit (lib) optionals;
in
  stdenv.mkDerivation rec {
    pname = "foldseek";
    version = "10-941cd33";

    src = fetchFromGitHub {
      owner = "steineggerlab";
      repo = "foldseek";
      rev = version;
      hash = "sha256-tZ0oeYPlTXvr/NR7djEvdbuF2K2bMGKC+9FFgsZgY38=";
      # All submodules have update=none and one (kompute) has empty URL
      # which breaks fetchSubmodules - they're not needed for the build
    };

    postPatch = ''
      # Fix shebang for xxdi.pl Perl scripts used in build
      patchShebangs lib/mmseqs/cmake/xxdi.pl
      patchShebangs cmake/xxdi.pl

      # Remove deprecated CMP0060 policy that newer CMake doesn't support
      substituteInPlace CMakeLists.txt \
        --replace-fail 'cmake_policy(SET CMP0060 OLD)' '# cmake_policy(SET CMP0060 OLD) # removed - deprecated'
    '';

    nativeBuildInputs =
      [
        cmake
        pkg-config
        cargo
        rustc
        perl
      ]
      ++ optionals cudaSupport [
        cudaPackages.cuda_nvcc
      ];

    buildInputs =
      [
        zlib
        bzip2
        llvmPackages.openmp
      ]
      ++ optionals cudaSupport [
        cudaPackages.cuda_cudart
        cudaPackages.libcublas
      ];

    cmakeFlags =
      [
        # lib/mmseqs has old cmake_minimum_required, fix compatibility
        "-DCMAKE_POLICY_VERSION_MINIMUM=3.5"
      ]
      ++ optionals stdenv.hostPlatform.isx86_64 [
        "-DHAVE_AVX2=1"
      ]
      ++ optionals stdenv.hostPlatform.isAarch64 [
        "-DHAVE_ARM8=1"
      ]
      ++ optionals cudaSupport [
        "-DENABLE_CUDA=1"
        "-DCMAKE_CUDA_ARCHITECTURES=75;80;86;89;90"
      ];

    passthru = {
      inherit cudaSupport;
    };

    meta = {
      description = "Fast and sensitive protein structure search";
      homepage = "https://github.com/steineggerlab/foldseek";
      license = lib.licenses.gpl3Plus;
      platforms =
        if cudaSupport
        then lib.platforms.linux
        else lib.platforms.unix;
      mainProgram = "foldseek";
    };
  }
