{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "capr";
  version = "1.1.1-unstable-2024-01-15";

  src = fetchFromGitHub {
    owner = "fukunagatsu";
    repo = "CapR";
    rev = "23769feb6a9b18c8b49b4a6d46ea4d2a1f978b0c";
    hash = "sha256-w2U4i1djQseHPFK+YRd7hAvy75XfZFlJ/sZLWocVyqY=";
  };

  buildPhase = ''
    runHook preBuild
    $CXX -O3 -o CapR main.cpp CapR.cpp fastafile_reader.cpp
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 CapR -t $out/bin
    runHook postInstall
  '';

  meta = {
    description = "RNA secondary structural context probability calculator";
    homepage = "https://github.com/fukunagatsu/CapR";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
    mainProgram = "CapR";
  };
}
