{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  pkg-config,
  zstd,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "openzl";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "facebook";
    repo = "openzl";
    rev = "v${finalAttrs.version}";
    hash = "sha256-umP/T3qkP7vjQeNpkdnvuGPnQ8XdXHvvXtVrJ9lQswQ=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    zstd.dev
  ];

  # Provide zstd source structure to satisfy CMake's add_subdirectory
  postUnpack = ''
    mkdir -p source/deps

    cp -r ${zstd.src}/* source/deps/zstd

    chmod -R u+w source/deps/zstd
  '';

  preConfigure = ''
    export SKIP_BUILDDEPS_CHECK=1
    export GIT=true
    export CURL=true
  '';

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=Release"
    "-DOPENZL_BUILD_MODE=opt"
    "-DOPENZL_BUILD_TESTS=OFF"
    "-DOPENZL_BUILD_BENCHMARKS=OFF"
    "-DZSTD_LIBRARY=${zstd}/lib/libzstd.a"
    "-DZSTD_INCLUDE_DIR=${zstd}/include"
  ];

  makeFlags = [ "zli" ];

  enableParallelBuilding = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin

    install -Dm755 cli/zli $out/bin/zli

    runHook postInstall
  '';

  doCheck = false;

  meta = with lib; {
    description = "Format-aware compression framework with high compression ratios and speed";
    longDescription = ''
      OpenZL delivers high compression ratios while preserving high speed.
      It generates specialized compressors optimized for specific data formats.
    '';
    homepage = "https://openzl.org";
    changelog = "https://github.com/facebook/openzl/releases";
    license = licenses.bsd3;
    maintainers = [ ];
    platforms = platforms.unix;
    mainProgram = "zli";
  };
})
