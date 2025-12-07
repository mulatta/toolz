{
  lib,
  callPackage,
  stdenv,
  pkgs,
  pythonOverlayFunc,
  python3PackagesExtended,
}: let
  byNamePackage = import ./by-name.nix;
in
  {
    # Cross-platform packages
    aptasuite = callPackage (byNamePackage "aptasuite") {};
    capr = callPackage (byNamePackage "capr") {};
    bbtools = callPackage (byNamePackage "bbtools") {};
    edirect = callPackage (byNamePackage "edirect") {};
    fastaptamer = callPackage (byNamePackage "fastaptamer") {};
    flash = callPackage (byNamePackage "flash") {};
    foldseek = callPackage (byNamePackage "foldseek") {};
    infernal = callPackage (byNamePackage "infernal") {};
    jellyfish = callPackage (byNamePackage "jellyfish") {};
    jellyfish-full = callPackage (byNamePackage "jellyfish-full") {};
    kmc = callPackage (byNamePackage "kmc") {};
    kmc-full = callPackage (byNamePackage "kmc-full") {};
    locarna = callPackage (byNamePackage "locarna") {};
    ncbi-dataformat = callPackage (byNamePackage "ncbi-dataformat") {};
    ncbi-datasets = callPackage (byNamePackage "ncbi-datasets") {};
    nextflow = callPackage (byNamePackage "nextflow") {};
    openzl = callPackage (byNamePackage "openzl") {};
    pybind11-abseil = callPackage (byNamePackage "pybind11-abseil") {
      inherit (python3PackagesExtended) pybind11;
      python3 = python3PackagesExtended.python;
    };
    vsearch = callPackage (byNamePackage "vsearch") {};
  }
  // lib.optionalAttrs stdenv.isLinux {
    # Linux-only packages (cross-architecture)
    blast = callPackage (byNamePackage "blast") {};
    cuda-compat = callPackage (byNamePackage "cuda-compat") {};
    viennarna-hpc = callPackage (byNamePackage "viennarna-hpc") {};
  }
  // lib.optionalAttrs (stdenv.isLinux && stdenv.isx86_64) {
    alphafold3 = callPackage (byNamePackage "alphafold3") {
      inherit pkgs pythonOverlayFunc;
      python3Packages = python3PackagesExtended;
    };
    interproscan = callPackage (byNamePackage "interproscan") {};
  }
