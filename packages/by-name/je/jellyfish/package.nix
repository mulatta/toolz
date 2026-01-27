{
  lib,
  stdenv,
  fetchurl,
  pkg-config,
  htslib,
}:
stdenv.mkDerivation rec {
  pname = "jellyfish";
  version = "2.3.1";

  src = fetchurl {
    url = "https://github.com/gmarcais/Jellyfish/releases/download/v${version}/jellyfish-${version}.tar.gz";
    sha256 = "sha256-7gMrVyV5SMoPBhCIMJkmdXLJGmNe7L2Irl2JdMJDD80=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    htslib
  ];

  enableParallelBuilding = true;

  configureFlags = [
    "--enable-all-binding=no"
  ];

  doCheck = true;

  meta = with lib; {
    description = "Fast, memory-efficient counting of k-mers in DNA sequences";
    longDescription = ''
      Jellyfish is a tool for fast, memory-efficient counting of k-mers in DNA.
      A k-mer is a substring of length k, and counting the occurrences of all
      such substrings is a central step in many analyses of DNA sequence.
      Jellyfish can count k-mers using an order of magnitude less memory and
      an order of magnitude faster than other k-mer counting packages by using
      an efficient encoding of a hash table and by exploiting the compare-and-swap
      CPU instruction to increase parallelism.
    '';
    homepage = "https://github.com/gmarcais/Jellyfish";
    changelog = "https://github.com/gmarcais/Jellyfish/releases/tag/v${version}";
    license = with licenses; [
      bsd3
      gpl3Only
    ];
    platforms = platforms.unix;
    mainProgram = "jellyfish";
  };
}
