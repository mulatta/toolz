{
  lib,
  stdenv,
  fetchurl,
  jre,
  makeWrapper,
}:
stdenv.mkDerivation rec {
  pname = "bbtools";
  version = "39.36";

  src = fetchurl {
    url = "mirror://sourceforge/bbmap/BBMap_${version}.tar.gz";
    sha256 = "sha256-9eh7QJ+lj+o1I0MXfSCMDANTbPlWnLgCpwBtt1Sm+Zs=";
  };

  sourceRoot = "bbmap";

  nativeBuildInputs = [ makeWrapper ];

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/libexec/bbtools
    cp -r . $out/libexec/bbtools

    mkdir -p $out/bin
    for script in $out/libexec/bbtools/*.sh; do
      if [ -f "$script" ]; then
        chmod +x "$script"
        name=$(basename "$script")
        makeWrapper "$script" "$out/bin/$name" \
          --set JAVA_HOME "${jre}" \
          --prefix PATH : "${lib.makeBinPath [ jre ]}"
      fi
    done

    runHook postInstall
  '';

  meta = with lib; {
    description = "BBTools suite for DNA/RNA sequence analysis";
    longDescription = ''
      BBTools is a suite of fast, multithreaded bioinformatics tools designed
      for analysis of DNA and RNA sequence data. It includes tools for read
      quality assessment, adapter trimming, contamination filtering, alignment,
      and various other sequence manipulation tasks.
    '';
    homepage = "https://jgi.doe.gov/data-and-tools/bbtools/";
    downloadPage = "https://sourceforge.net/projects/bbmap/";
    changelog = "https://sourceforge.net/projects/bbmap/files/";
    license = licenses.bsd3;
    platforms = platforms.unix;
    maintainers = with maintainers; [
    ];
    mainProgram = "bbmerge.sh";
  };
}
