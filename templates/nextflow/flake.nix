{
  description = "PROJ_NAME Project flake";
  nixConfig = {
    extra-substituters = ["https://mulatta.cachix.org"];
    extra-trusted-public-keys = ["mulatta.cachix.org-1:fh++Q+sBr+s6+/SNiaXXc8cCsKeAvb5oxP8fG06eDBE="];
  };
  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = import inputs.systems;
      imports = [
        ./nix/packages.nix
        ./nix/shell.nix
        ./nix/images.nix
        ./nix/formatter.nix
      ];
      perSystem = {
        lib,
        self',
        system,
        ...
      }: {
        _module.args.pkgs = import inputs.nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = [inputs.toolz.overlays.default];
        };
        checks = let
          packages = lib.mapAttrs' (n: lib.nameValuePair "package-${n}") self'.packages;
          devShells = lib.mapAttrs' (n: lib.nameValuePair "devShell-${n}") self'.devShells;
        in
          {inherit (self') formatter;}
          // packages
          // devShells;
      };
    };

  inputs = {
    # keep-sorted start
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    systems.url = "github:nix-systems/default-linux";
    toolz.inputs.flake-parts.follows = "flake-parts";
    toolz.inputs.nixpkgs-unstable.follows = "nixpkgs-unstable";
    toolz.inputs.nixpkgs.follows = "nixpkgs";
    toolz.inputs.systems.follows = "systems";
    toolz.inputs.treefmt-nix.follows = "treefmt-nix";
    toolz.url = "github:zmblr/toolz";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    # keep-sorted end
  };
}
