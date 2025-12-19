{
  lib,
  stdenv,
  pkgs,
}: let
  byNamePackage = import ./by-name.nix;
in
  pySelf: _pySuper:
    {
      # Cross-platform Python packages
      # keep-sorted start
      cuda-bindings = pySelf.callPackage (byNamePackage "cuda-bindings") {};
      cuda-core = pySelf.callPackage (byNamePackage "cuda-core") {};
      cuda-pathfinder = pySelf.callPackage (byNamePackage "cuda-pathfinder") {};
      cuda-python = pySelf.callPackage (byNamePackage "cuda-python") {};
      cuda-toolkit = pySelf.callPackage (byNamePackage "cuda-toolkit") {};
      cutadapt = pySelf.callPackage (byNamePackage "cutadapt") {};
      dnaio = pySelf.callPackage (byNamePackage "dnaio") {};
      finch-clust = pySelf.callPackage (byNamePackage "finch-clust") {};
      forgi = pySelf.callPackage (byNamePackage "forgi") {};
      # NOTE: jax, jaxlib, jaxtyping removed from global overlay
      # These are now local dependencies in alphafold3 to avoid conflicts with nixpkgs
      jax-cuda12-pjrt = pySelf.callPackage (byNamePackage "jax-cuda12-pjrt") {};
      jax-cuda12-plugin = pySelf.callPackage (byNamePackage "jax-cuda12-plugin") {};
      jax-triton = pySelf.callPackage (byNamePackage "jax-triton") {};
      logging-exceptions = pySelf.callPackage (byNamePackage "logging-exceptions") {};
      logomaker = pySelf.callPackage (byNamePackage "logomaker") {};
      mkdocs-static-i18n = pySelf.callPackage (byNamePackage "mkdocs-static-i18n") {};
      numba-cuda = pySelf.callPackage (byNamePackage "numba-cuda") {};
      nupack = pySelf.callPackage (byNamePackage "nupack") {};
      nvidia-cublas-cu12 = pySelf.callPackage (byNamePackage "nvidia-cublas-cu12") {};
      nvidia-cuda-cupti-cu12 = pySelf.callPackage (byNamePackage "nvidia-cuda-cupti-cu12") {};
      nvidia-cuda-nvcc-cu12 = pySelf.callPackage (byNamePackage "nvidia-cuda-nvcc-cu12") {};
      nvidia-cuda-runtime-cu12 = pySelf.callPackage (byNamePackage "nvidia-cuda-runtime-cu12") {};
      nvidia-cudnn-cu12 = pySelf.callPackage (byNamePackage "nvidia-cudnn-cu12") {};
      nvidia-cufft-cu12 = pySelf.callPackage (byNamePackage "nvidia-cufft-cu12") {};
      nvidia-cusolver-cu12 = pySelf.callPackage (byNamePackage "nvidia-cusolver-cu12") {};
      nvidia-cusparse-cu12 = pySelf.callPackage (byNamePackage "nvidia-cusparse-cu12") {};
      nvidia-nccl-cu12 = pySelf.callPackage (byNamePackage "nvidia-nccl-cu12") {};
      nvidia-nvjitlink-cu12 = pySelf.callPackage (byNamePackage "nvidia-nvjitlink-cu12") {};
      nvtx = pySelf.callPackage (byNamePackage "nvtx") {};
      pyclibrary = pySelf.callPackage (byNamePackage "pyclibrary") {};
      # NOTE: pyarrow removed from global overlay to avoid conflicts
      # Now used as local dependency in cudf-cu12
      # NOTE: pymdown-extensions removed from global overlay to avoid conflicts
      # Now used as local dependency in zensical
      rapids-build-backend = pySelf.callPackage (byNamePackage "rapids-build-backend") {};
      rapids-dask-dependency = pySelf.callPackage (byNamePackage "rapids-dask-dependency") {};
      rapids-logger = pySelf.callPackage (byNamePackage "rapids-logger") {};
      xopen = pySelf.callPackage (byNamePackage "xopen") {};
      zensical = pySelf.callPackage (byNamePackage "zensical") {};
      # keep-sorted end
    }
    // lib.optionalAttrs stdenv.isLinux
    {
      # Linux-only Python packages
      alphafold3 = let
        alphafold3-base = pySelf.callPackage ../by-name/al/alphafold3/base.nix {};
        inherit (alphafold3-base.passthru) componentsCif;

        # Unified data package: components.cif + pickle files
        # This derivation decompresses components.cif once and generates all pickle files
        alphafold3-data =
          pySelf.pkgs.runCommand "alphafold3-data-${alphafold3-base.version}" {
            nativeBuildInputs = [
              (pySelf.python.withPackages (_ps: [alphafold3-base]))
              pySelf.pkgs.gzip
            ];
          } ''
            mkdir -p $out/share/libcifpp
            mkdir -p $out/constants/converters

            # Decompress components.cif once (used by both pickle generation and final package)
            gunzip -c ${componentsCif} > $out/share/libcifpp/components.cif

            # Set LIBCIFPP_DATA_DIR for C++ module to find components.cif
            export LIBCIFPP_DATA_DIR=$out/share/libcifpp

            # Verify C++ module can be imported
            python3 -c "import alphafold3.cpp" || {
              echo "Error: C++ module import failed"
              exit 1
            }

            # Generate CCD pickle using the decompressed cif file
            python3 -m alphafold3.constants.converters.ccd_pickle_gen \
              $out/share/libcifpp/components.cif \
              $out/constants/converters/ccd.pickle || exit 1

            # Generate chemical component sets pickle
            python3 <<EOF
            import pickle, re

            with open('$out/constants/converters/ccd.pickle', 'rb') as f:
                ccd = pickle.load(f)

            glycans_linking, glycans_other, ions = [], [], []
            for name, comp in ccd.items():
                if name == 'UNX': continue
                comp_type = comp['_chem_comp.type'][0].lower()
                if re.findall(r'\\bsaccharide\\b', comp_type):
                    (glycans_linking if 'linking' in comp_type else glycans_other).append(name)
                if re.findall(r'\\bion\\b', comp['_chem_comp.name'][0].lower()):
                    ions.append(name)

            with open('$out/constants/converters/chemical_component_sets.pickle', 'wb') as f:
                pickle.dump({
                    'glycans_linking': frozenset(glycans_linking),
                    'glycans_other': frozenset(glycans_other),
                    'ions': frozenset(ions),
                }, f)
            EOF
          '';
      in
        alphafold3-base.overrideAttrs (oldAttrs: {
          pname = "alphafold3";

          postInstall =
            (oldAttrs.postInstall or "")
            + ''
              SITE_PACKAGES="lib/${pySelf.python.libPrefix}/site-packages"

              # Install components.cif and pickle files from unified data package
              cp -r ${alphafold3-data}/share $out/$SITE_PACKAGES/
              mkdir -p $out/$SITE_PACKAGES/alphafold3/constants
              cp -r ${alphafold3-data}/constants/converters $out/$SITE_PACKAGES/alphafold3/constants/
            '';

          passthru =
            (oldAttrs.passthru or {})
            // {
              data = alphafold3-data;
              base = alphafold3-base;
            };

          meta =
            (oldAttrs.meta or {})
            // {
              description = "AlphaFold 3 structure prediction with pre-generated pickle files";
            };
        });
      cudf-cu12 = pySelf.callPackage (byNamePackage "cudf-cu12") {
        inherit (pkgs) cuda-compat;
      };
      cugraph-cu12 = pySelf.callPackage (byNamePackage "cugraph-cu12") {
        inherit (pkgs) cuda-compat;
      };
      dask-cuda = pySelf.callPackage (byNamePackage "dask-cuda") {};
      dask-cudf-cu12 = pySelf.callPackage (byNamePackage "dask-cudf-cu12") {};
      distributed-ucxx-cu12 = pySelf.callPackage (byNamePackage "distributed-ucxx-cu12") {};
      libcudf-cu12 = pySelf.callPackage (byNamePackage "libcudf-cu12") {};
      libcugraph-cu12 = pySelf.callPackage (byNamePackage "libcugraph-cu12") {};
      libkvikio-cu12 = pySelf.callPackage (byNamePackage "libkvikio-cu12") {};
      libraft-cu12 = pySelf.callPackage (byNamePackage "libraft-cu12") {};
      librmm-cu12 = pySelf.callPackage (byNamePackage "librmm-cu12") {};
      libucx-cu12 = pySelf.callPackage (byNamePackage "libucx-cu12") {};
      libucxx-cu12 = pySelf.callPackage (byNamePackage "libucxx-cu12") {};
      pylibcugraph-cu12 = pySelf.callPackage (byNamePackage "pylibcugraph-cu12") {};
      pylibraft-cu12 = pySelf.callPackage (byNamePackage "pylibraft-cu12") {};
      raft-dask-cu12 = pySelf.callPackage (byNamePackage "raft-dask-cu12") {};
      rmm-cu12 = pySelf.callPackage (byNamePackage "rmm-cu12") {};
      ucxx-cu12 = pySelf.callPackage (byNamePackage "ucxx-cu12") {};
      pylibcudf-cu12 = pySelf.callPackage (byNamePackage "pylibcudf-cu12") {};
    }
