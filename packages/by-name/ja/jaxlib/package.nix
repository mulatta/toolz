{
  absl-py,
  autoPatchelfHook,
  buildPythonPackage,
  fetchPypi,
  flatbuffers,
  lib,
  ml-dtypes,
  python,
  scipy,
  stdenv,
}:
let
  version = "0.4.34";
  inherit (python) pythonVersion;

  srcs =
    let
      getSrcFromPypi =
        {
          platform,
          dist,
          hash,
        }:
        fetchPypi {
          inherit
            version
            platform
            dist
            hash
            ;
          pname = "jaxlib";
          format = "wheel";
          python = dist;
          abi = dist;
        };
    in
    {
      "3.10-x86_64-linux" = getSrcFromPypi {
        platform = "manylinux2014_x86_64";
        dist = "cp310";
        hash = "sha256-2A5mSIVUbm1RbnJh/j0VnQpHq/V/vugpnzc2chg9wtI=";
      };
      "3.10-aarch64-linux" = getSrcFromPypi {
        platform = "manylinux2014_aarch64";
        dist = "cp310";
        hash = "sha256-PlgMnJMzkwOZm7u4hwtjJM3hXt5TSRcNwWa/Vkb9LMw=";
      };
      "3.10-aarch64-darwin" = getSrcFromPypi {
        platform = "macosx_11_0_arm64";
        dist = "cp310";
        hash = "sha256-RdcaLOPraiFSVXonuRt98dfVo/ozjQm9x9MgMiIZ3eA=";
      };

      "3.11-x86_64-linux" = getSrcFromPypi {
        platform = "manylinux2014_x86_64";
        dist = "cp311";
        hash = "sha256-O8/jpDpkqaMo+KPKoQzXe8jbEz9X8F3VL6w2Oyq1v18=";
      };
      "3.11-aarch64-linux" = getSrcFromPypi {
        platform = "manylinux2014_aarch64";
        dist = "cp311";
        hash = "sha256-Vx7wJYg1VIZRFZaabSjpQabpJOa0frtoQUpOKqxL/rA=";
      };
      "3.11-aarch64-darwin" = getSrcFromPypi {
        platform = "macosx_11_0_arm64";
        dist = "cp311";
        hash = "sha256-yT2tCp1B+vmfHZ9vL7qrUL+y6FSFhGt7nqM1bvc+qqg=";
      };

      "3.12-x86_64-linux" = getSrcFromPypi {
        platform = "manylinux2014_x86_64";
        dist = "cp312";
        hash = "sha256-SCcukDT/ho1DKM8AVaB4gv0r6T9Z37YoOvfeSR+dEpA=";
      };
      "3.12-aarch64-linux" = getSrcFromPypi {
        platform = "manylinux2014_aarch64";
        dist = "cp312";
        hash = "sha256-GjB3HYX3f5urbPY0RV+l+j+jRYeGDtuYfV7ouW7gO8U=";
      };
      "3.12-aarch64-darwin" = getSrcFromPypi {
        platform = "macosx_11_0_arm64";
        dist = "cp312";
        hash = "sha256-CW8Mo0nUH6aS0fL5r6u6HMn0Cn1PeldPiPru/k3ys/Q=";
      };
    };
in
buildPythonPackage {
  pname = "jaxlib";
  inherit version;
  format = "wheel";

  src =
    srcs."${pythonVersion}-${stdenv.hostPlatform.system}"
      or (throw "jaxlib ${version} is not supported on ${stdenv.hostPlatform.system} with Python ${pythonVersion}");

  # Prebuilt wheels are dynamically linked against things that nix can't find.
  # Run `autoPatchelfHook` to automagically fix them.
  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];
  # Dynamic link dependencies
  buildInputs = [ (lib.getLib stdenv.cc.cc) ];

  dependencies = [
    absl-py
    flatbuffers
    ml-dtypes
    scipy
  ];

  pythonImportsCheck = [ "jaxlib" ];

  meta = {
    description = "XLA library for JAX (prebuilt wheel from PyPI)";
    homepage = "https://github.com/google/jax";
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    license = lib.licenses.asl20;
    platforms = lib.platforms.unix;
  };
}
