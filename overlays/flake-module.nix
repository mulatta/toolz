{
  self,
  inputs,
  ...
}:
{
  flake.overlays.default =
    final: prev:
    let
      inherit (prev) lib system stdenv;

      # Create callPackage using final for lazy evaluation
      callPackage = final.newScope { };

      # Build Python overlay function by importing directly
      pythonOverlayFunc = import (self + "/packages/lib/python-packages.nix") {
        inherit lib stdenv;
        pkgs = final;
      };

      # Apply overlay to get Python packages
      python3PackagesExtended = prev.python3Packages.overrideScope pythonOverlayFunc;

      # Build regular packages by importing directly
      regularPackages = import (self + "/packages/lib/regular-packages.nix") {
        inherit lib stdenv callPackage;
        inherit pythonOverlayFunc python3PackagesExtended;
        pkgs = final;
      };

      # Import external packages
      externalPackages = import (self + "/packages/lib/external-packages.nix") {
        inherit inputs system;
      };
    in
    regularPackages
    // externalPackages
    // {
      # Expose Python packages at top level (CLI tools)
      inherit (python3PackagesExtended) cutadapt nupack zensical;

      # Expose Python package sets
      python3Packages = python3PackagesExtended;

      # Multi-version Python support
      python3 = prev.python3.override { packageOverrides = pythonOverlayFunc; };
      python311 = prev.python311.override { packageOverrides = pythonOverlayFunc; };
      python312 = prev.python312.override { packageOverrides = pythonOverlayFunc; };
      python313 = prev.python313.override { packageOverrides = pythonOverlayFunc; };

      python311Packages = prev.python311Packages.overrideScope pythonOverlayFunc;
      python312Packages = prev.python312Packages.overrideScope pythonOverlayFunc;
      python313Packages = prev.python313Packages.overrideScope pythonOverlayFunc;
    }
    // lib.optionalAttrs stdenv.isLinux {
      inherit (regularPackages) alphafold3;
    };
}
