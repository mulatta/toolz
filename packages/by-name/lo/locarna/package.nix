{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  pkg-config,
  viennarna,
  perl,
  makeWrapper,
  gmp,
  mpfr,
  gsl,
}:
let
  # Override viennarna to disable LTO and enable shared libraries
  viennarna-no-lto = viennarna.overrideAttrs (oldAttrs: {
    # Disable LTO to avoid symbol mangling issues
    env = (oldAttrs.env or { }) // {
      NIX_CFLAGS_COMPILE = toString (
        lib.toList (oldAttrs.env.NIX_CFLAGS_COMPILE or "")
        ++ [
          "-fno-lto"
          "-ffat-lto-objects"
        ]
      );
    };
  });
in
stdenv.mkDerivation rec {
  pname = "locarna";
  version = "2.0.1";

  src = fetchFromGitHub {
    owner = "s-will";
    repo = "LocARNA";
    rev = "v${version}";
    sha256 = "sha256-yoy70lfpXvIiKjT16zovabzGOPTcm8nWKdhKQ4vv6Ks=";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
    makeWrapper
  ];

  buildInputs = [
    viennarna-no-lto
    perl
    gmp
    mpfr
    gsl
  ];

  configureFlags = [
    "--with-vrna=${viennarna-no-lto}"
    "--enable-shared"
    "--disable-static"
    "--disable-doxygen-doc"
  ];

  # C++14 is required and disable LTO to match ViennaRNA
  NIX_CFLAGS_COMPILE = [
    "-std=c++14"
    "-fno-lto"
    "-ffat-lto-objects"
  ];

  # Ensure Vienna RNA library is used
  preConfigure = ''
    export LIBS="-lRNA"
    export LDFLAGS="-L${viennarna-no-lto}/lib $LDFLAGS"
  '';

  # Disable documentation build
  postConfigure = ''
    # Disable Doc directory build to avoid missing man page errors
    sed -i '/^SUBDIRS/s/Doc//' Makefile
    sed -i '/^DIST_SUBDIRS/s/Doc//' Makefile || true
  '';

  enableParallelBuilding = true;

  # Don't check for /build/ references since libtool adds them and we'll clean them up
  noAuditTmpdir = true;

  postInstall = ''
    # Wrap Perl scripts to ensure they can find required modules and binaries
    for script in $out/bin/*; do
      if [ -f "$script" ] && file "$script" | grep -q "Perl script"; then
        wrapProgram "$script" \
          --prefix PATH : ${
            lib.makeBinPath [
              viennarna-no-lto
              perl
            ]
          } \
          --prefix PATH : $out/bin
      fi
    done
  '';

  # Fix RPATH after the standard fixup phase to ensure binaries can find libLocARNA
  postFixup = ''
    # Fix RPATH in all ELF binaries and shared libraries
    for binary in $out/bin/* $out/lib/*.so*; do
      if [ -f "$binary" ] && file "$binary" 2>/dev/null | grep -q "ELF"; then
        # Get current RPATH
        oldRpath=$(patchelf --print-rpath "$binary" 2>/dev/null || echo "")

        # Remove /build/ paths but keep valid Nix store paths
        cleanRpath=$(echo "$oldRpath" | tr ':' '\n' | grep -v "/build/" | tr '\n' ':' | sed 's/:$//')

        # Build complete RPATH with all required libraries
        newRpath="${
          lib.makeLibraryPath [
            viennarna-no-lto
            gsl
            gmp
            mpfr
            stdenv.cc.cc.lib
          ]
        }:$out/lib"

        # Add any existing valid paths that aren't duplicates
        if [ -n "$cleanRpath" ]; then
          newRpath="$newRpath:$cleanRpath"
        fi

        # Remove duplicate entries while preserving order
        newRpath=$(echo "$newRpath" | tr ':' '\n' | awk '!seen[$0]++' | tr '\n' ':' | sed 's/:$//')

        # Set the new RPATH
        patchelf --set-rpath "$newRpath" "$binary" 2>/dev/null || true
      fi
    done
  '';

  meta = with lib; {
    description = "LocARNA - Fast and accurate alignment of RNA structures";
    longDescription = ''
      LocARNA is a tool for RNA sequence and structure alignment.
      It implements a variant of Sankoff's algorithm for simultaneous
      alignment and folding of RNAs, providing efficient computation
      of pairwise and multiple alignments.

      The main tool mlocarna is particularly useful for aligning
      sequences in the twilight zone (<60% sequence identity).
    '';
    homepage = "https://github.com/s-will/LocARNA";
    license = licenses.gpl3Plus;
    platforms = platforms.unix;
    maintainers = [ ];
  };
}
