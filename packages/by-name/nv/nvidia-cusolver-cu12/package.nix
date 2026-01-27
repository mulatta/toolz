{
  buildPythonPackage,
  fetchPypi,
  lib,
  autoPatchelfHook,
  stdenv,
  nvidia-cublas-cu12,
  nvidia-cusparse-cu12,
  nvidia-nvjitlink-cu12,
}:
buildPythonPackage rec {
  pname = "nvidia-cusolver-cu12";
  version = "11.7.1.2";
  format = "wheel";

  src = fetchPypi {
    pname = "nvidia_cusolver_cu12";
    inherit version format;
    dist = "py3";
    python = "py3";
    abi = "none";
    platform = "manylinux2014_x86_64";
    hash = "sha256-bPKPF/ZBB6DE14Ar5f9VN7ITC/wRLyXVow3yJwWMoOY=";
  };

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];
  buildInputs = [
    (lib.getLib stdenv.cc.cc)
    nvidia-cublas-cu12
    nvidia-cusparse-cu12
    nvidia-nvjitlink-cu12
  ];

  dependencies = [
    nvidia-cublas-cu12
    nvidia-cusparse-cu12
    nvidia-nvjitlink-cu12
  ];

  # Remove namespace __init__.py to prevent collisions (PEP 420 implicit namespace)
  postInstall = ''
    rm -f $out/lib/python*/site-packages/nvidia/__init__.py
    rm -rf $out/lib/python*/site-packages/nvidia/__pycache__
  '';

  # autoPatchelfHook needs to find NVIDIA libraries in nested site-packages directories
  postFixup = ''
    addAutoPatchelfSearchPath "${nvidia-cublas-cu12}/${nvidia-cublas-cu12.pythonModule.sitePackages}/nvidia/cublas/lib"
    addAutoPatchelfSearchPath "${nvidia-cusparse-cu12}/${nvidia-cusparse-cu12.pythonModule.sitePackages}/nvidia/cusparse/lib"
    addAutoPatchelfSearchPath "${nvidia-nvjitlink-cu12}/${nvidia-nvjitlink-cu12.pythonModule.sitePackages}/nvidia/nvjitlink/lib"
  '';

  pythonImportsCheck = [ "nvidia.cusolver" ];

  meta = {
    description = "CUSOLVER native runtime libraries";
    homepage = "https://developer.nvidia.com/cusolver";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
    maintainers = [ ];
  };
}
