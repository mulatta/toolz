{
  lib,
  symlinkJoin,
  makeWrapper,
  pkgs,
  python3Packages,
  pythonOverlayFunc,
  hmmer,
}:
let
  alphafold3-with-pickles = python3Packages.alphafold3;

  cudaModuleNames = [
    "cuda_runtime"
    "cublas"
    "cudnn"
    "cusparse"
    "cusolver"
    "cufft"
    "cuda_cupti"
    "nccl"
    "nvjitlink"
  ];

  python3WithOverlay = pkgs.python3.override {
    packageOverrides = pythonOverlayFunc;
  };
  python-with-alphafold3 = python3WithOverlay.withPackages (ps: [ ps.alphafold3 ]);
  cudaLibsPath = lib.concatMapStringsSep ":" (
    name: "${python-with-alphafold3}/${python-with-alphafold3.sitePackages}/nvidia/${name}/lib"
  ) cudaModuleNames;
in
symlinkJoin {
  name = "alphafold3-${alphafold3-with-pickles.version}";
  paths = [
    alphafold3-with-pickles
    hmmer
  ];

  passthru = {
    # GPU environment setup: alphafold3.mkShellHook python
    mkShellHook =
      python:
      let
        cudaLibsPath' = lib.concatMapStringsSep ":" (
          name: "${python}/${python3Packages.python.sitePackages}/nvidia/${name}/lib"
        ) cudaModuleNames;
        libcifppDataDir = "${python}/${python3Packages.python.sitePackages}/share/libcifpp";
      in
      ''
        export LD_LIBRARY_PATH="${pkgs.addDriverRunpath.driverLink}/lib:${cudaLibsPath'}:''${LD_LIBRARY_PATH:-}"
        export LIBCIFPP_DATA_DIR="${libcifppDataDir}"
        export TRITON_PTXAS_PATH="${pkgs.cudaPackages.cuda_nvcc}/bin/ptxas"
        export XLA_FLAGS="''${XLA_FLAGS:+$XLA_FLAGS }--xla_gpu_cuda_data_dir=${pkgs.cudaPackages.cuda_nvcc}"
      '';

    pythonPackage = python3Packages.alphafold3;
    pythonEnv = python-with-alphafold3;
  };

  meta = {
    description = "AlphaFold 3 structure prediction with pre-generated pickle files";
    longDescription = ''
      AlphaFold 3 predicts biomolecular structures and interactions.

      Includes: CCD pickles, HMMER tools, CUDA 12.x support.
      Requires: CUDA GPU, model weights from DeepMind (https://github.com/google-deepmind/alphafold3)
    '';
    mainProgram = "run_alphafold.py";
    inherit (alphafold3-with-pickles.meta)
      homepage
      changelog
      license
      platforms
      ;
  };

  nativeBuildInputs = [ makeWrapper ];
  postBuild = ''
    # Preserve Python package lib directory
    if [ -d ${alphafold3-with-pickles}/lib ]; then
      rm -rf $out/lib
      ln -s ${alphafold3-with-pickles}/lib $out/lib
    fi

    # Create wrappers with official script names for compatibility with upstream documentation
    makeWrapper ${python-with-alphafold3}/bin/python $out/bin/run_alphafold.py \
      --prefix LD_LIBRARY_PATH : "${pkgs.addDriverRunpath.driverLink}/lib:${cudaLibsPath}" \
      --set TRITON_PTXAS_PATH "${pkgs.cudaPackages.cuda_nvcc}/bin/ptxas" \
      --set XLA_FLAGS "--xla_gpu_cuda_data_dir=${pkgs.cudaPackages.cuda_nvcc}" \
      --add-flags "${alphafold3-with-pickles.base.src}/run_alphafold.py"

    makeWrapper ${python-with-alphafold3}/bin/python $out/bin/run_alphafold_data_test.py \
      --prefix LD_LIBRARY_PATH : "${pkgs.addDriverRunpath.driverLink}/lib:${cudaLibsPath}" \
      --set TRITON_PTXAS_PATH "${pkgs.cudaPackages.cuda_nvcc}/bin/ptxas" \
      --set XLA_FLAGS "--xla_gpu_cuda_data_dir=${pkgs.cudaPackages.cuda_nvcc}" \
      --add-flags "${alphafold3-with-pickles.base.src}/run_alphafold_data_test.py"

    makeWrapper ${python-with-alphafold3}/bin/python $out/bin/run_alphafold_test.py \
      --prefix LD_LIBRARY_PATH : "${pkgs.addDriverRunpath.driverLink}/lib:${cudaLibsPath}" \
      --set TRITON_PTXAS_PATH "${pkgs.cudaPackages.cuda_nvcc}/bin/ptxas" \
      --set XLA_FLAGS "--xla_gpu_cuda_data_dir=${pkgs.cudaPackages.cuda_nvcc}" \
      --add-flags "${alphafold3-with-pickles.base.src}/run_alphafold_test.py"
  '';
}
