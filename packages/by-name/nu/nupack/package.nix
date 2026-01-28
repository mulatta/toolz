{
  lib,
  buildPythonPackage,
  python,
  numpy,
  scipy,
  pandas,
  pyyaml,
  requireFile,
  unzip,
  autoPatchelfHook,
  stdenv,
}:
let
  inherit (stdenv) isLinux cc;
  inherit (stdenv.hostPlatform) system;

  version = "4.0.2.0";
  pythonVersion = lib.replaceStrings [ "." ] [ "" ] python.pythonVersion;

  wheelPlatformMap = {
    "x86_64-linux" = "linux_x86_64";
    "aarch64-linux" = "linux_aarch64";
    "aarch64-darwin" = "macosx_11_0_arm64";
    "x86_64-darwin" = "macosx_12_0_x86_64";
  };

  wheelPlatform = wheelPlatformMap.${system} or (throw "Unsupported platform: ${system}");
  wheelName = "nupack-${version}-cp${pythonVersion}-cp${pythonVersion}-${wheelPlatform}.whl";
in
buildPythonPackage {
  pname = "nupack";
  inherit version;
  format = "wheel";

  src = requireFile {
    name = "nupack-${version}.zip";
    hash = "sha256-4y/PqyqRsm+TKwMRMbLSCqkPKvndoCFMjkiq7QTSzVU=";
    message = ''
      Please download NUPACK ${version} from https://nupack.org/downloads
      and add it with:
        nix-store --add-fixed sha256 nupack-${version}.zip
    '';
  };

  nativeBuildInputs = [ unzip ] ++ lib.optionals isLinux [ autoPatchelfHook ];

  buildInputs = lib.optionals isLinux [ cc.cc.lib ];

  propagatedBuildInputs = [
    numpy
    scipy
    pandas
    pyyaml
  ];

  unpackPhase = ''
    echo "Python version: ${pythonVersion}"
    echo "Platform: ${system}"
    echo "Target wheel: ${wheelName}"

    unzip -q $src

    wheelPath="nupack-${version}/package/${wheelName}"

    if [ ! -f "$wheelPath" ]; then
      echo "Error: Wheel file not found: $wheelPath"
      echo "Available wheels:"
      ls -1 nupack-${version}/package/*.whl
      exit 1
    fi

    mkdir -p dist
    cp "$wheelPath" dist/${wheelName}

    echo "Wheel copied to dist/${wheelName}"
  '';

  dontBuild = true;
  dontConfigure = true;
  doCheck = false;

  pythonImportsCheck = [ "nupack" ];

  meta = with lib; {
    description = "NUPACK - Nucleic acid analysis Python package";
    homepage = "https://nupack.org";
    license = licenses.unfreeRedistributable;
    platforms = platforms.linux ++ platforms.darwin;
  };
}
