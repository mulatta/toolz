{
  lib,
  stdenv,
  fetchurl,
  pkg-config,
  htslib,
  swig,
  python3,
  ruby,
  perl,
  withPython ? true,
  withRuby ? false,
  withPerl ? false,
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
  ]
  ++ lib.optionals (withPython || withRuby || withPerl) [
    swig
  ];

  buildInputs = [
    htslib
  ]
  ++ lib.optionals withPython [
    python3
  ]
  ++ lib.optionals withRuby [
    ruby
  ]
  ++ lib.optionals withPerl [
    perl
  ];

  enableParallelBuilding = true;

  configureFlags = [
    (lib.enableFeature (withPython || withRuby || withPerl) "swig")
    (lib.enableFeature withPython "python-binding")
    (lib.enableFeature withRuby "ruby-binding")
    (lib.enableFeature withPerl "perl-binding")
  ];

  doCheck = true;

  checkTarget = "check";

  postInstall = lib.optionalString withPython ''
    if [ -d $out/lib/python*/site-packages ]; then
      echo "Python binding installed successfully"
    fi
  '';

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

      This version includes language bindings for:
      ${lib.optionalString withPython "- Python\n"}
      ${lib.optionalString withRuby "- Ruby\n"}
      ${lib.optionalString withPerl "- Perl\n"}
    '';
    homepage = "https://github.com/gmarcais/Jellyfish";
    changelog = "https://github.com/gmarcais/Jellyfish/releases/tag/v${version}";
    license = with licenses; [
      bsd3
      gpl3Only
    ]; # Dual license
    maintainers = [ ];
    platforms = platforms.unix;
    mainProgram = "jellyfish";
  };
}
