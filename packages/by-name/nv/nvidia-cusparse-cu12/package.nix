{
  buildPythonPackage,
  fetchPypi,
  lib,
  autoPatchelfHook,
  stdenv,
  nvidia-nvjitlink-cu12,
}:
buildPythonPackage rec {
  pname = "nvidia-cusparse-cu12";
  version = "12.5.4.2";
  format = "wheel";

  src = fetchPypi {
    pname = "nvidia_cusparse_cu12";
    inherit version format;
    dist = "py3";
    python = "py3";
    abi = "none";
    platform = "manylinux2014_x86_64";
    hash = "sha256-I3SaZXEZGiFct00c2/9KhuexnxIAwHGz/PhEpb6iOi8=";
  };

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];
  buildInputs = [
    (lib.getLib stdenv.cc.cc)
    nvidia-nvjitlink-cu12
  ];

  dependencies = [ nvidia-nvjitlink-cu12 ];

  # Remove namespace __init__.py to prevent collisions (PEP 420 implicit namespace)
  postInstall = ''
    rm -f $out/lib/python*/site-packages/nvidia/__init__.py
    rm -rf $out/lib/python*/site-packages/nvidia/__pycache__
  '';

  # autoPatchelfHook needs to find libnvJitLink.so.12 in nested site-packages directory
  postFixup = ''
    addAutoPatchelfSearchPath "${nvidia-nvjitlink-cu12}/${nvidia-nvjitlink-cu12.pythonModule.sitePackages}/nvidia/nvjitlink/lib"
  '';

  pythonImportsCheck = [ "nvidia.cusparse" ];

  meta = {
    description = "CUSPARSE native runtime libraries";
    homepage = "https://developer.nvidia.com/cusparse";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
    maintainers = [ ];
  };
}
