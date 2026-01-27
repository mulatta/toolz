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
stdenv.mkDerivation {
  pname = "edirect";
  version = "24.2";

  src = fetchurl {
    url = "https://ftp.ncbi.nlm.nih.gov/entrez/entrezdirect/edirect.tar.gz";
    sha256 = "sha256-z7Z+/wqxUwyAl83buY44iwCbt5oRcDP563k0W+SN6Gk=";
  };

  nativeBuildInputs = [
    makeWrapper
    autoPatchelfHook
  ];

  buildInputs = [
    perl
    python3
  ];

  sourceRoot = "edirect";

  postUnpack =
    let
      platform =
        if stdenv.isLinux then
          "Linux"
        else if stdenv.isDarwin && stdenv.isx86_64 then
          "Darwin"
        else if stdenv.isDarwin && stdenv.isAarch64 then
          "Silicon"
        else
          throw "Unsupported platform";

      xtractBin = fetchurl {
        url = "https://ftp.ncbi.nlm.nih.gov/entrez/entrezdirect/xtract.${platform}.gz";
        sha256 = "sha256-L8xHH5ciUCJkKlRE7EKG46paLA0xaBpslfpOT6FI7FI=";
      };

      rchiveBin = fetchurl {
        url = "https://ftp.ncbi.nlm.nih.gov/entrez/entrezdirect/rchive.${platform}.gz";
        sha256 = "sha256-D4+pnM1r5shmf/wgaoX8Rbk4K2xBVrMj/UHnPGqTjFk=";
      };

      transmuteBin = fetchurl {
        url = "https://ftp.ncbi.nlm.nih.gov/entrez/entrezdirect/transmute.${platform}.gz";
        sha256 = "sha256-bgbxyJ8GzEG/IgBu1HPeYSlSlYB7Ci5Uz5NAhEUsm1c=";
      };
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
