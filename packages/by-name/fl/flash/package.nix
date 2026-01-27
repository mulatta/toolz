{
  lib,
  stdenv,
  fetchurl,
  zlib,
}:
stdenv.mkDerivation rec {
  pname = "FLASH";
  version = "1.2.11";

  src = fetchurl {
    url = "mirror://sourceforge/flashpage/FLASH-${version}.tar.gz";
    sha256 = "sha256-aFym9/7doHQ02O4DxTb0djOFZxxFCcW7SL6zBV/SNqw=";
  };

  buildInputs = [ zlib ];

  makeFlags = [
    "CC=${stdenv.cc.targetPrefix}cc"
  ];

  installPhase = ''
    runHook preInstall

    install -Dm755 flash $out/bin/flash

    for doc in README README.md; do
      if [ -f "$doc" ]; then
        install -Dm644 "$doc" $out/share/doc/${pname}/"$doc"
      fi
    done

    runHook postInstall
  '';

  doCheck = true;
  checkPhase = ''
    runHook preCheck

    ./flash --version 2>/dev/null || ./flash -h 2>/dev/null || true

    runHook postCheck
  '';

  meta = with lib; {
    description = "Fast Length Adjustment of SHort reads - A tool for merging paired-end reads";
    longDescription = ''
      FLASH (Fast Length Adjustment of SHort reads) is a very fast and accurate
      software tool to merge paired-end reads from next-generation sequencing
      experiments. FLASH is designed to merge pairs of reads when the original
      DNA fragments are shorter than twice the length of reads.
    '';
    homepage = "https://ccb.jhu.edu/software/FLASH/";
    downloadPage = "https://sourceforge.net/projects/flashpage/";
    license = licenses.gpl3Plus;
    platforms = platforms.unix;
    mainProgram = "flash";
  };
}
