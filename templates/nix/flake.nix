{
  description = "PROJ_NAME";

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = import inputs.systems;

      imports = [
        ./nix/shell.nix
        ./nix/formatter.nix
      ];

      perSystem =
        {
          lib,
          self',
          system,
          ...
        }:
        {
          _module.args.pkgs = import inputs.nixpkgs {
            inherit system;
            config.allowUnfree = true;
            overlays = [ inputs.toolz.overlays.default ];
          };

          checks =
            let
              packages = lib.mapAttrs' (n: lib.nameValuePair "package-${n}") self'.packages;
              devShells = lib.mapAttrs' (n: lib.nameValuePair "devShell-${n}") self'.devShells;
            in
            { inherit (self') formatter; } // packages // devShells;
        };
    };

  inputs = {
    # keep-sorted start
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default";
    toolz.inputs.flake-parts.follows = "flake-parts";
    toolz.inputs.nixpkgs.follows = "nixpkgs";
    toolz.inputs.systems.follows = "systems";
    toolz.inputs.treefmt-nix.follows = "treefmt-nix";
    toolz.url = "github:zmblr/toolz";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    # keep-sorted end
  };
}
