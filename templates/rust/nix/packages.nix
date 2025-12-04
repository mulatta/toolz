{inputs, ...}: {
  perSystem = {
    lib,
    pkgs,
    ...
  }: let
    # Crane setup with rust-overlay toolchain
    rustToolchain = pkgs.rust-bin.stable.latest.default.override {
      extensions = ["rust-src" "rust-analyzer"];
    };

    craneLib = (inputs.crane.mkLib pkgs).overrideToolchain rustToolchain;

    # Common source filtering
    src = let
      # Only include Rust-relevant files
      rustFilter = path: type:
        (craneLib.filterCargoSources path type)
        || (builtins.match ".*\\.md$" path != null);
    in
      lib.cleanSourceWith {
        src = inputs.gitignore.lib.gitignoreSource ../.;
        filter = rustFilter;
      };

    # Common build arguments
    commonArgs = {
      inherit src;
      strictDeps = true;

      nativeBuildInputs = with pkgs; [
        pkg-config
      ];

      buildInputs = with pkgs;
        lib.optionals stdenv.isDarwin [
          # macOS-specific dependencies
          darwin.apple_sdk.frameworks.Security
          darwin.apple_sdk.frameworks.SystemConfiguration
        ];
    };

    # Build only dependencies (for caching)
    cargoArtifacts = craneLib.buildDepsOnly commonArgs;

    # Build the actual package
    PROJ_NAME = craneLib.buildPackage (commonArgs
      // {
        inherit cargoArtifacts;

        doCheck = true;

        meta = with lib; {
          description = "DESCRIPTION";
          homepage = "https://github.com/yourusername/PROJ_NAME";
          license = licenses.mit;
          maintainers = [];
          platforms = platforms.linux ++ platforms.darwin;
          mainProgram = "PROJ_NAME";
        };
      });

    # Clippy check
    PROJ_NAME-clippy = craneLib.cargoClippy (commonArgs
      // {
        inherit cargoArtifacts;
        cargoClippyExtraArgs = "--all-targets -- --deny warnings";
      });

    # Format check
    PROJ_NAME-fmt = craneLib.cargoFmt {
      inherit src;
    };

    # Documentation
    PROJ_NAME-doc = craneLib.cargoDoc (commonArgs
      // {
        inherit cargoArtifacts;
      });
  in {
    packages = {
      inherit PROJ_NAME;
      default = PROJ_NAME;

      # Expose artifacts for shell reuse
      deps = cargoArtifacts;
    };

    # Expose checks
    checks = {
      inherit PROJ_NAME PROJ_NAME-clippy PROJ_NAME-fmt PROJ_NAME-doc;
    };
  };
}
