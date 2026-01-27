{
  lib,
  stdenv,
  fetchzip,
  autoPatchelfHook,
}:
stdenv.mkDerivation rec {
  pname = "ncbi-dataformat";
  version = "18.10.2";

  src =
    if stdenv.isLinux && stdenv.isx86_64 then
      fetchzip {
        url = "https://github.com/ncbi/datasets/releases/download/v${version}/linux-amd64.cli.package.zip";
        sha256 = "sha256-0F/WyG76bc50MFC3wBXa+yxjsAkY2Sw0BLAM9lAl9n4=";
        stripRoot = false;
      }
    else if stdenv.isDarwin && stdenv.isx86_64 then
      fetchzip {
        url = "https://github.com/ncbi/datasets/releases/download/v${version}/darwin-amd64.cli.package.zip";
        sha256 = "sha256-F8qqci56CKik82uXTg3Nqzfy5VByoJICikb8R/K2Q7o=";
        stripRoot = false;
      }
    else if stdenv.isDarwin && stdenv.isAarch64 then
      fetchzip {
        url = "https://github.com/ncbi/datasets/releases/download/v${version}/darwin-arm64.cli.package.zip";
        sha256 = "sha256-rBrXK8GVMhtpHQ5o2T3tRKXvOcnzrraBb1gyxlYsQOA=";
        stripRoot = false;
      }
    else if stdenv.isLinux && stdenv.isAarch64 then
      fetchzip {
        url = "https://github.com/ncbi/datasets/releases/download/v${version}/linux-arm64.cli.package.zip";
        sha256 = "sha256-xTarEH5O1Fv/eE4SWTj6Pg4/55IJDDMAaEenfeIWVAk=";
        stripRoot = false;
      }
    else
      throw "Unsupported platform";

  nativeBuildInputs = lib.optionals stdenv.isLinux [
    autoPatchelfHook
  ];

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin

    install -Dm755 $src/dataformat $out/bin/dataformat

    runHook postInstall
  '';

  meta = with lib; {
    description = "NCBI Datasets dataformat tool for converting metadata formats";
    longDescription = ''
      The NCBI Datasets command-line tools consist of dataformat.
      Use datasets to download biological sequence data across all domains of life from NCBI.
      Use dataformat to convert metadata from JSON Lines format to other formats.
    '';
    homepage = "https://www.ncbi.nlm.nih.gov/datasets/docs/v2/";
    changelog = "https://github.com/ncbi/datasets/releases";
    license = licenses.publicDomain;
    platforms = platforms.unix;
    mainProgram = "dataformat";
  };
}
