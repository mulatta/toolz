{
  lib,
  stdenv,
  fetchFromGitHub,
  perl,
  makeWrapper,
  perlPackages,
}:
stdenv.mkDerivation rec {
  pname = "fastaptamer";
  version = "1.0.16";

  src = fetchFromGitHub {
    owner = "FASTAptamer";
    repo = "FASTAptamer";
    rev = "v${version}";
    hash = "sha256-9E0+0EPPRhiUs9ULnzugPwu+APrqpDUizdJM97AWFqw=";
  };

  nativeBuildInputs = [ makeWrapper ];

  buildInputs = [ perl ];

  propagatedBuildInputs = with perlPackages; [
    TextLevenshteinXS
  ];

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin

    for script in fastaptamer_*; do
      if [ -f "$script" ] && [ -x "$script" ]; then
        cp "$script" $out/bin/
        wrapProgram $out/bin/$script \
          --prefix PERL5LIB : "${with perlPackages; makePerlPath [ ]}"
      fi
    done

    mkdir -p $out/share/doc/fastaptamer
    if [ -f LICENSE.txt ]; then
      cp LICENSE.txt $out/share/doc/fastaptamer/
    fi
    if [ -f README ]; then
      cp README $out/share/doc/fastaptamer/
    fi

    runHook postInstall
  '';

  meta = with lib; {
    description = "Bioinformatic toolkit for high-throughput sequence analysis of combinatorial selections";
    longDescription = ''
      FASTAptamer is a toolkit for analyzing high throughput sequencing data
      from combinatorial selections such as aptamer and ribozyme discovery,
      phage display, in vivo mutagenesis selection and other DNA-encoded libraries.

      The toolkit includes:
      - FASTAptamer-Count: Converts FASTQ to ranked FASTA
      - FASTAptamer-Compare: Statistical comparison of two populations
      - FASTAptamer-Cluster: Clusters sequences by edit distance
      - FASTAptamer-Enrich: Calculates fold-enrichment values
      - FASTAptamer-Search: Searches for sequence patterns
    '';
    homepage = "https://github.com/FASTAptamer/FASTAptamer";
    license = licenses.gpl3Only;
    maintainers = [ ];
    platforms = platforms.unix;
    mainProgram = "fastaptamer_count";
  };
}
