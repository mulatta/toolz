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
  cudaPackages ? { },
}:
let
  inherit (lib) optionals;
in
stdenv.mkDerivation rec {
  pname = "foldseek";
  version = "10-941cd33";

  src = fetchFromGitHub {
    owner = "steineggerlab";
    repo = "foldseek";
    rev = version;
    hash = "sha256-CAwdpzsnHE9Rs1I97FGhP+lYtssGqZvxj288xV+/AYg=";
    fetchSubmodules = true;
  };

  postPatch = ''
    # Fix shebang for xxdi.pl Perl scripts used in build
    patchShebangs lib/mmseqs/cmake/xxdi.pl
    patchShebangs cmake/xxdi.pl
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
    cargo
    rustc
    perl
  ]
  ++ optionals cudaSupport [
    cudaPackages.cuda_nvcc
  ];

  buildInputs = [
    zlib
    bzip2
    llvmPackages.openmp
  ]
  ++ optionals cudaSupport [
    cudaPackages.cuda_cudart
    cudaPackages.libcublas
  ];

  cmakeFlags =
    optionals stdenv.hostPlatform.isx86_64 [
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
    platforms = if cudaSupport then lib.platforms.linux else lib.platforms.unix;
    mainProgram = "foldseek";
  };
}
