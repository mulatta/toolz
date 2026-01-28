{
  lib,
  fetchFromGitHub,
  makeWrapper,
  maven,
  jdk11,
  # Runtime dependencies for JavaFX
  gtk3,
  glib,
  libGL,
  xorg,
  pango,
  cairo,
  gdk-pixbuf,
  freetype,
  fontconfig,
}:
let
  jdk = jdk11;
  runtimeLibs = lib.makeLibraryPath [
    gtk3
    glib
    libGL
    xorg.libX11
    xorg.libXtst
    xorg.libXxf86vm
    pango
    cairo
    gdk-pixbuf
    freetype
    fontconfig
  ];
in
maven.buildMavenPackage rec {
  pname = "aptasuite";
  version = "0.9.8";

  src = fetchFromGitHub {
    owner = "drivenbyentropy";
    repo = "aptasuite";
    rev = "v${version}";
    hash = "sha256-xWfJDsLfAr1b20+YMcue5A19XJ1VuXAUt89jMbeLmYc=";
  };

  mvnHash = "sha256-PFXQ+VIoZsiBum6K/7GRw6230ghnPXpYj/zJpvNiZkw=";

  mvnJdk = jdk;
  mvnParameters = "-DskipTests -Djgitver.skip=true";

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/java/aptasuite
    cp target/aptasuite-*.jar $out/share/java/aptasuite/aptasuite.jar
    cp -r target/dependency $out/share/java/aptasuite/lib

    mkdir -p $out/bin
    makeWrapper ${jdk}/bin/java $out/bin/aptasuite \
      --add-flags "-jar $out/share/java/aptasuite/aptasuite.jar" \
      --prefix LD_LIBRARY_PATH : "${runtimeLibs}"

    runHook postInstall
  '';

  meta = with lib; {
    description = "Full-featured bioinformatics framework for HT-SELEX aptamer analysis (CLI + GUI)";
    homepage = "https://github.com/drivenbyentropy/aptasuite";
    license = licenses.gpl3Plus;
    platforms = platforms.unix;
    mainProgram = "aptasuite";
  };
}
