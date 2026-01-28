{
  pkgs,
  inputs ? { },
  system ? null,
  ...
}:
let
  inherit (pkgs) lib callPackage stdenv;

  # Build Python overlay function
  pythonOverlayFunc = callPackage ./python-packages.nix { };

  # Apply overlay to get Python packages
  python3PackagesExtended = pkgs.python3Packages.overrideScope pythonOverlayFunc;

  regularPackages = callPackage ./regular-packages.nix {
    inherit pythonOverlayFunc python3PackagesExtended;
  };

  externalPackages = import ./external-packages.nix { inherit inputs system; };
in
regularPackages
// externalPackages
// {
  # Expose Python packages at top level (CLI tools)
  inherit (python3PackagesExtended) cutadapt nupack zensical;

  # Expose Python package sets
  python3Packages = python3PackagesExtended;

  # Multi-version Python support
  python3 = pkgs.python3.override { packageOverrides = pythonOverlayFunc; };
  python311 = pkgs.python311.override { packageOverrides = pythonOverlayFunc; };
  python312 = pkgs.python312.override { packageOverrides = pythonOverlayFunc; };
  python313 = pkgs.python313.override { packageOverrides = pythonOverlayFunc; };

  python311Packages = pkgs.python311Packages.overrideScope pythonOverlayFunc;
  python312Packages = pkgs.python312Packages.overrideScope pythonOverlayFunc;
  python313Packages = pkgs.python313Packages.overrideScope pythonOverlayFunc;
}
// lib.optionalAttrs (stdenv.isLinux && stdenv.isx86_64) {
  inherit (regularPackages) alphafold3;
}
