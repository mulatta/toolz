{
  lib,
  stdenv,
  buildFHSEnv,
  fetchurl,
  writeShellScript,
  perl,
  python3,
  jdk11,
  zlib,
  bzip2,
  gfortran,
  pcre2,
}:
let
  version = "5.76-107.0";

  interproscan-unwrapped = stdenv.mkDerivation {
    pname = "interproscan-unwrapped";
    inherit version;

    src = fetchurl {
      url = "https://ftp.ebi.ac.uk/pub/software/unix/iprscan/5/${version}/interproscan-${version}-64-bit.tar.gz";
      hash = "sha256-SKf2p3dRT4RPJj2sWQgFC/8AwoE0EnGAglgabQbrXdc=";
    };

    sourceRoot = ".";

    dontStrip = true;
    dontPatchELF = true;
    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      runHook preInstall

      cd interproscan-${version}

      mkdir -p $out/share/interproscan
      cp -r ./* $out/share/interproscan/
      chmod -R u+w $out/share/interproscan

      # Make scripts executable
      find $out/share/interproscan -type f -name "*.sh" -exec chmod +x {} \;
      find $out/share/interproscan -type f -name "*.pl" -exec chmod +x {} \;
      find $out/share/interproscan -type f -name "*.py" -exec chmod +x {} \;
      find $out/share/interproscan/bin -type f -exec chmod +x {} \;

      # Remove LevelDB LOCK files (runtime artifacts that prevent database access)
      find $out/share/interproscan -name "LOCK" -type f -delete

      runHook postInstall
    '';

    meta = {
      description = "InterProScan - unwrapped distribution";
      platforms = [ "x86_64-linux" ];
    };
  };

  runScript = writeShellScript "interproscan-run" ''
    export JAVA_HOME="${jdk11}"
    export INTERPROSCAN_HOME="${interproscan-unwrapped}/share/interproscan"
    export PATH="${jdk11}/bin:${interproscan-unwrapped}/share/interproscan/bin:$PATH"

    # Save original working directory for output files
    ORIG_PWD="$PWD"

    # Create a writable temp directory if not already set
    if [[ -z "$INTERPROSCAN_TEMP" ]]; then
      INTERPROSCAN_TEMP="''${TMPDIR:-/tmp}/interproscan-$$"
      mkdir -p "$INTERPROSCAN_TEMP"
      trap "rm -rf '$INTERPROSCAN_TEMP'" EXIT
    fi

    # Run from original directory so relative paths work correctly
    exec "${interproscan-unwrapped}/share/interproscan/interproscan.sh" \
      -T "$INTERPROSCAN_TEMP" \
      -u "$ORIG_PWD" \
      "$@"
  '';
in
buildFHSEnv {
  name = "interproscan";
  inherit (interproscan-unwrapped) version;

  targetPkgs =
    pkgs: with pkgs; [
      # Core runtime
      bash
      coreutils
      gnugrep
      gnused
      gawk
      findutils
      gzip
      gnutar

      # InterProScan requirements
      jdk11
      perl
      python3

      # Libraries needed by bundled binaries
      stdenv.cc.cc.lib
      zlib
      bzip2
      pcre2
      gfortran.cc.lib

      # Additional libraries that might be needed
      libgcc
      glibc
    ];

  inherit runScript;

  extraInstallCommands = ''
    # Create setup script for HMM indexing (run once after installation)
    mkdir -p $out/bin
    cat > $out/bin/interproscan-setup <<EOF
    #!/usr/bin/env bash
    echo "Indexing HMM models for InterProScan..."
    echo "This may take several minutes on first run."
    exec "$out/bin/interproscan" -c "
      cd ${interproscan-unwrapped}/share/interproscan
      export PATH=${interproscan-unwrapped}/share/interproscan/bin/hmmer/hmmer3/3.3:\\\$PATH
      python3 setup.py -f interproscan.properties
    "
    EOF
    chmod +x $out/bin/interproscan-setup
  '';

  meta = with lib; {
    description = "Protein sequence analysis and classification";
    longDescription = ''
      InterProScan is a comprehensive tool that combines different protein
      signature recognition methods into one resource.

      This package uses buildFHSEnv to provide a standard Linux environment
      for the bundled pre-compiled binaries and scripts that assume FHS paths.

      Note: HMM models need to be indexed on first use. Run:
        interproscan-setup
      Or the indexing will happen automatically on first interproscan run.
    '';
    homepage = "https://www.ebi.ac.uk/interpro/";
    license = licenses.asl20;
    mainProgram = "interproscan";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
  };
}
