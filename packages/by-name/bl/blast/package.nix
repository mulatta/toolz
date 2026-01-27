{
  lib,
  stdenv,
  buildPackages,
  fetchurl,
  zlib,
  bzip2,
  perl,
  cpio,
  gawk,
  coreutils,
  curl,
  wget,
  findutils,
  gnutar,
  gzip,
  google-cloud-sdk,
  makeWrapper,
}:
stdenv.mkDerivation rec {
  pname = "blast";
  version = "2.14.1";

  src = fetchurl {
    url = "https://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/${version}/ncbi-blast-${version}+-src.tar.gz";
    sha256 = "sha256-cSwtvfD7E8wcLU9O9d0c5LBsO1fpbf6o8j5umfWxZQ4=";
  };

  sourceRoot = "ncbi-blast-${version}+-src/c++";

  configureFlags = [
    "--with-flat-makefile"
    "--without-makefile-auto-update"
    "--with-dll"
  ];

  makeFlags = [ "all_projects=app/" ];

  preConfigure = ''
    export NCBICXX_RECONF_POLICY=warn
    export PWD=$(pwd)
    export HOME=$PWD

    unset AR

    for awks in scripts/common/impl/is_log_interesting.awk \
        scripts/common/impl/report_duplicates.awk; do
        substituteInPlace $awks \
              --replace-fail "/usr/bin/awk" "${gawk}/bin/awk"
    done

    for mk in src/build-system/Makefile.meta.in \
        src/build-system/helpers/run_with_lock.c ; do
        substituteInPlace $mk \
        --replace-fail "/bin/rm" "${coreutils}/bin/rm"
    done

    for mk in src/build-system/Makefile.meta.gmake=no \
        src/build-system/Makefile.meta_l \
        src/build-system/Makefile.meta_r \
        src/build-system/Makefile.requirements \
        src/build-system/Makefile.rules_with_autodep.in; do
        substituteInPlace $mk \
            --replace-fail "/bin/echo" "${coreutils}/bin/echo"
    done

    for mk in src/build-system/Makefile.meta_p \
        src/build-system/Makefile.rules_with_autodep.in \
        src/build-system/Makefile.protobuf.in ; do
        substituteInPlace $mk \
            --replace-fail "/bin/mv" "${coreutils}/bin/mv"
    done

    substituteInPlace src/build-system/configure \
        --replace-fail "/bin/pwd" "${coreutils}/bin/pwd" \
        --replace-fail "/bin/ln" "${coreutils}/bin/ln"

    substituteInPlace src/build-system/configure.ac \
        --replace-fail "/bin/pwd" "${coreutils}/bin/pwd" \
        --replace-fail "/bin/ln" "${coreutils}/bin/ln"

    substituteInPlace src/build-system/Makefile.meta_l \
        --replace-fail "/bin/date" "${coreutils}/bin/date"
  '';

  depsBuildBuild = [ buildPackages.stdenv.cc ];

  nativeBuildInputs = [
    cpio
    perl
    makeWrapper
  ];

  buildInputs = [
    coreutils
    perl
    gawk
    zlib
    bzip2
    curl
    wget
    findutils
    gnutar
    gzip
  ];

  strictDeps = true;

  hardeningDisable = [ "format" ];

  postInstall = ''
    substituteInPlace $out/bin/get_species_taxids.sh \
        --replace-fail "/bin/rm" "${coreutils}/bin/rm"

    if [ -f $out/bin/update_blastdb.pl ]; then
      substituteInPlace $out/bin/update_blastdb.pl \
        --replace-fail '/usr/bin/xargs' '${findutils}/bin/xargs' \
        --replace-fail 'foreach (qw(/usr/local/bin /usr/bin))' \
                  'foreach (qw(${curl}/bin ${wget}/bin /usr/local/bin /usr/bin))' \
        --replace-fail 'local $ENV{PATH} = "/bin:/usr/bin";' \
                  'local $ENV{PATH} = "${
                    lib.makeBinPath [
                      gnutar
                      gzip
                      coreutils
                    ]
                  }:$ENV{PATH}";'

      wrapProgram $out/bin/update_blastdb.pl \
        --prefix PATH : ${
          lib.makeBinPath [
            curl
            wget
            findutils
            gnutar
            gzip
            coreutils
            google-cloud-sdk
          ]
        }

      chmod +x $out/bin/update_blastdb.pl
    fi
  '';

  patches = [ ./no_slash_bin.patch ];

  enableParallelBuilding = true;

  doCheck = false;

  meta = with lib; {
    description = "NCBI BLAST with fully self-contained update_blastdb.pl";
    homepage = "https://blast.ncbi.nlm.nih.gov/Blast.cgi";
    license = licenses.publicDomain;
    platforms = platforms.linux;
    maintainers = with maintainers; [ luispedro ];
  };
}
