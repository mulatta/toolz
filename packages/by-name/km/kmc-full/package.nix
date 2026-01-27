{
  lib,
  stdenv,
  fetchFromGitHub,
  zlib,
  git,
  python3,
  withPython ? true,
}:
stdenv.mkDerivation rec {
  pname = "kmc${lib.optionalString withPython "-python"}";
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
  ]
  ++ lib.optionals withPython [
    python3
    python3.pkgs.pybind11
  ];

  buildInputs = [
    zlib
  ]
  ++ lib.optionals withPython [
    python3
  ];

  dontConfigure = true;
  enableParallelBuilding = true;

  postPatch = ''
    substituteInPlace Makefile \
      --replace-fail '-static' ' ' \
      --replace-fail '-Wl,--whole-archive -lpthread -Wl,--no-whole-archive' '-lpthread'

    substituteInPlace Makefile \
      --replace-fail '3rd_party/cloudflare/libz.a' '-lz'

    sed -i '/cd 3rd_party\/cloudflare/d' Makefile

    ${lib.optionalString withPython ''
      substituteInPlace Makefile \
        --replace-fail '$(PY_KMC_API_DIR)/libs/pybind11/include' \
                           '${python3.pkgs.pybind11}/include' \
        --replace-fail '`python3 -c "import sysconfig;print(sysconfig.get_paths()['"'"'include'"'"'])"`' \
                       '${python3}/include/python${lib.versions.majorMinor python3.version}' \
        --replace-fail '`python3-config --extension-suffix`' \
                       '.so'
    ''}
  '';

  NIX_LDFLAGS = "-L${zlib}/lib";
  NIX_CFLAGS_COMPILE = "-I${zlib}/include";

  preBuild = lib.optionalString withPython ''
    export PATH="${python3}/bin:$PATH"
  '';

  buildFlags = [
    "kmc"
    "kmc_dump"
    "kmc_tools"
  ]
  ++ lib.optionals withPython [ "py_kmc_api" ];

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

    ${lib.optionalString withPython ''
      mkdir -p $out/${python3.sitePackages}

      if compgen -G "bin/py_kmc_api*.so" > /dev/null; then
        cp bin/py_kmc_api*.so $out/${python3.sitePackages}/
      fi

      if [ -d py_kmc_api ]; then
        for pyfile in py_kmc_api/*.py; do
          [ -f "$pyfile" ] && cp "$pyfile" $out/${python3.sitePackages}/ || true
        done
      fi
    ''}

    runHook postInstall
  '';

  meta = with lib; {
    description = "Disk-based k-mer counter for DNA sequences";
    longDescription = ''
      KMC is a disk-based program for counting k-mers from (possibly gzipped)
      FASTQ/FASTA files. The KMC 3 algorithm is significantly faster and more
      memory-efficient than other k-mer counting tools.

      This version includes:
      - kmc: Main k-mer counting program
      - kmc_dump: Dumps k-mers from database
      - kmc_tools: Tools for manipulating KMC databases
      ${lib.optionalString withPython "- py_kmc_api: Python wrapper for KMC API"}
    '';
    homepage = "https://github.com/refresh-bio/KMC";
    changelog = "https://github.com/refresh-bio/KMC/releases/tag/v${version}";
    license = licenses.gpl3Only;
    maintainers = [ ];
    platforms = platforms.unix;
    mainProgram = "kmc";
  };
}
