{
  lib,
  stdenv,
  viennarna,
}:
viennarna.overrideAttrs (oldAttrs: {
  pname = "viennarna-hpc";

  configureFlags =
    (builtins.filter (flag: flag != "--with-python3") (oldAttrs.configureFlags or [ ]))
    ++ lib.optionals stdenv.isx86_64 [
      "--enable-sse"
    ];

  NIX_CFLAGS_COMPILE = toString (
    lib.toList (oldAttrs.NIX_CFLAGS_COMPILE or "")
    ++ lib.optionals stdenv.isx86_64 [
      "-march=native"
      "-O3"
      "-mtune=native"
    ]
  );

  meta = oldAttrs.meta // {
    description = "ViennaRNA Package (HPC Build with SSE4.1 SIMD, no Python)";
    longDescription = ''
      RNA secondary structure prediction and comparison with HPC optimizations.

      This is the core C/C++ library WITHOUT Python bindings.
      For Python support, use viennarna-python package.

      Performance enhancements:
      - SSE4.1 SIMD instructions: ~2x faster multibranch loop decomposition
      - Native CPU optimization: -march=native -mtune=native
      - Aggressive optimization: -O3
      - OpenMP parallel processing
      - POSIX threads support
      - Link-time optimization

      Note: Requires x86_64 CPU with SSE4.1 support
    '';
    platforms = lib.platforms.unix;
  };
})
