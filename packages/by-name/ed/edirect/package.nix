{
  lib,
  stdenv,
  fetchurl,
  perl,
  python3,
  makeWrapper,
  curl,
  wget,
  which,
  gzip,
  autoPatchelfHook,
}:
let
  version = "25.0.20260124";
  baseUrl = "https://ftp.ncbi.nlm.nih.gov/entrez/entrezdirect/versions/${version}";

  platform =
    if stdenv.isLinux then
      "Linux"
    else if stdenv.isDarwin && stdenv.isx86_64 then
      "Darwin"
    else if stdenv.isDarwin && stdenv.isAarch64 then
      "Silicon"
    else
      throw "Unsupported platform";

  binHashes = {
    xtract = {
      Linux = "sha256-lL6Ha1E7acZkp2qaz1Prcmtd6aDUzgT0cxsv0lATaT4=";
      Darwin = "sha256-9e0oB4/WH3PzSwMrZT7VNpB5THjTaL7Su5WEDjEKyew=";
      Silicon = "sha256-kmEcvbomPnOL+Jh6XJngyfRAE03aTZIEUrvJ8Def7Lc=";
    };
    rchive = {
      Linux = "sha256-HRUBrX9p9Zm0X18F1d4hI812dB79dXmD6bnEt8iYWo4=";
      Darwin = "sha256-9lfuTDm8keIfw9SCG6ShPqgV/BASjuLIna0igwyALio=";
      Silicon = "sha256-8t5PJQaLYb6DyxRC2SCteDLS34kf/pzU80pXCaOM/U0=";
    };
    transmute = {
      Linux = "sha256-pC6QJIeufmPgvBPSSkuAxcIVkMPdMs9rBs/QBeBN9CA=";
      Darwin = "sha256-lLv3c9+Y5Z+UEJ4Le2hfVYxkb2rqI/c3qJL33xkN3PE=";
      Silicon = "sha256-zRgivL1U7TSDTKWk/oeh87BeDQSy1GKW5a9lLfsR5RI=";
    };
  };

  fetchBin =
    name:
    fetchurl {
      url = "${baseUrl}/${name}.${platform}.gz";
      sha256 = binHashes.${name}.${platform};
    };
in
stdenv.mkDerivation {
  pname = "edirect";
  inherit version;

  src = fetchurl {
    url = "${baseUrl}/edirect.tar.gz";
    sha256 = "sha256-sUobkER6My5ZuKfXhKf4Q6A2xnpkNGlDfkCOuotd+X4=";
  };

  nativeBuildInputs = [
    makeWrapper
  ]
  ++ lib.optionals stdenv.isLinux [
    autoPatchelfHook
  ];

  buildInputs = [
    perl
    python3
  ];

  sourceRoot = "edirect";

  postUnpack =
    let
      xtractBin = fetchBin "xtract";
      rchiveBin = fetchBin "rchive";
      transmuteBin = fetchBin "transmute";
    in
    ''

      ${gzip}/bin/gunzip -c ${xtractBin} > edirect/xtract
      ${gzip}/bin/gunzip -c ${rchiveBin} > edirect/rchive
      ${gzip}/bin/gunzip -c ${transmuteBin} > edirect/transmute

      chmod +x edirect/xtract edirect/rchive edirect/transmute
    '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    mkdir -p $out/share/edirect

    cp -r . $out/share/edirect/

    ln -s $out/share/edirect/xtract $out/bin/xtract
    ln -s $out/share/edirect/rchive $out/bin/rchive
    ln -s $out/share/edirect/transmute $out/bin/transmute

    for script in esearch efetch elink efilter einfo epost esummary nquire; do
      if [ -f "$out/share/edirect/$script" ]; then
        makeWrapper "$out/share/edirect/$script" "$out/bin/$script" \
          --prefix PATH : "${
            lib.makeBinPath [
              curl
              wget
              which
            ]
          }" \
          --prefix PERL5LIB : "$out/share/edirect" \
          --set EDIRECT_PUBMED_MASTER "$out/share/edirect"
      fi
    done

    if [ -f "$out/share/edirect/edirect.py" ]; then
      makeWrapper "${python3}/bin/python3" "$out/bin/edirect-python" \
        --add-flags "$out/share/edirect/edirect.py" \
        --prefix PATH : "$out/bin"
    fi

    runHook postInstall
  '';

  meta = with lib; {
    description = "NCBI Entrez Direct E-utilities on the Unix command line";
    longDescription = ''
      Entrez Direct (EDirect) provides access to the NCBI's suite of
      interconnected databases from a Unix terminal window. Functions
      take search terms from command-line arguments. Individual operations
      are connected with Unix pipes to construct multi-step queries.
    '';
    homepage = "https://www.ncbi.nlm.nih.gov/books/NBK179288/";
    license = licenses.publicDomain;
    platforms = platforms.unix;
    mainProgram = "esearch";
  };
}
