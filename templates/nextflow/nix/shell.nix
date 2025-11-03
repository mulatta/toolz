{
  perSystem = {
    config,
    pkgs,
    ...
  }: let
    pythonPackages = ps:
      with ps; [
        altair
        biopython
        ipykernel
        matplotlib
        polars
        seaborn
        jupyter
        pyarrow
        nupack
        papermill
      ];

    kernelPython = pkgs.python3.withPackages pythonPackages;

    jupyterKernel = pkgs.runCommand "PROJ_NAME-kernel-spec" {} ''
      mkdir -p $out/kernels/PROJ_NAME-nix
      cat > $out/kernels/selex-nix/kernel.json << EOF
      {
        "display_name": "PROJ_NAME Jupyter (Nix)",
        "language": "python",
        "argv": [
          "${kernelPython}/bin/python",
          "-m",
          "ipykernel_launcher",
          "-f",
          "{connection_file}"
        ]
      }
      EOF
    '';

    deps = with pkgs;
      [
        bashInteractive
        coreutils
        gnutar
        fastp
        multiqc
        cutadapt
        seqkit
        sops
      ]
      ++ [kernelPython];
  in {
    devShells.default = pkgs.mkShellNoCC {
      packages = deps ++ [config.packages.workflow];

      shellHook = ''
        export JUPYTER_PATH="${jupyterKernel}:''${JUPYTER_PATH:-}"
      '';
    };

    _module.args.deps = deps;
  };
}
