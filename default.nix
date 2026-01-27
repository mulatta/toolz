{
  pkgs ? import <nixpkgs> { },
}:
let
  inherit (pkgs) lib;
  allPackages = import ./packages/lib/all-packages.nix { inherit pkgs; };

  isDrv = value: lib.isDerivation value;
in
lib.filterAttrs (_name: isDrv) allPackages
