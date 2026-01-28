{
  lib,
  stdenv,
  fetchFromGitHub,
  zlib,
  git,
}:
stdenv.mkDerivation rec {
  pname = "kmc";
  version = "3.2.4";

  src = fetchFromGitHub {
    owner = "refresh-bio";
    repo = "KMC";
    rev = "v${version}";
    sha256 = "sha256-n1sHV/vVsZIFWfVX7KTxtFxQWO9H7VKs0xLXDpL03+E=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    git
  ];

  buildInputs = [
    zlib
  ];

  dontConfigure = true;
  enableParallelBuilding = true;

  postPatch = ''
    substituteInPlace Makefile \
      --replace '-static' ' ' \
      --replace '-Wl,--whole-archive -lpthread -Wl,--no-whole-archive' '-lpthread'

    substituteInPlace Makefile \
      --replace '3rd_party/cloudflare/libz.a' '-lz'

    sed -i '/cd 3rd_party\/cloudflare/d' Makefile
    sed -i 's/all: kmc kmc_dump kmc_tools py_kmc_api/all: kmc kmc_dump kmc_tools/' Makefile
  '';

  NIX_LDFLAGS = "-L${zlib}/lib";
  NIX_CFLAGS_COMPILE = "-I${zlib}/include";

  buildFlags = [
    "kmc"
    "kmc_dump"
    "kmc_tools"
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    install -m755 bin/kmc $out/bin/
    install -m755 bin/kmc_dump $out/bin/
    install -m755 bin/kmc_tools $out/bin/

    mkdir -p $out/lib
    install -m644 bin/libkmc_core.a $out/lib/

    mkdir -p $out/include/kmc
    if [ -d include ]; then
      cp -r include/* $out/include/kmc/ 2>/dev/null || true
    fi
    if [ -d kmc_api ]; then
      cp kmc_api/*.h $out/include/kmc/ 2>/dev/null || true
    fi

    runHook postInstall
  '';

  meta = with lib; {
    description = "Disk-based k-mer counter for DNA sequences";
    longDescription = ''
      KMC is a disk-based program for counting k-mers from (possibly gzipped)
      FASTQ/FASTA files. The KMC 3 algorithm is significantly faster and more
      memory-efficient than other k-mer counting tools.

      Includes three main programs:
      - kmc: Main k-mer counting program
      - kmc_dump: Dumps k-mers from database
      - kmc_tools: Tools for manipulating KMC databases
    '';
    homepage = "https://github.com/refresh-bio/KMC";
    changelog = "https://github.com/refresh-bio/KMC/releases/tag/v${version}";
    license = licenses.gpl3Only;
    maintainers = [ ];
    platforms = platforms.unix;
    mainProgram = "kmc";
  };
}
