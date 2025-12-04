{
  description = "toolz";
  nixConfig = {
    extra-substituters = ["https://cache.sjanglab.org/toolz"];
    extra-trusted-public-keys = ["toolz:TOX1KA7jJYaosx/t7tch0x5GaUws3I4dPW4TgwFjHKk="];
  };
  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = import inputs.systems;
      imports = [
        ./packages/flake-module.nix
        ./overlays/flake-module.nix
        ./templates/flake-module.nix
        ./dev/formatter.nix
        ./dev/shell.nix
        ./website/flake-module.nix
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
        };

        checks = let
          packages = lib.mapAttrs' (n: lib.nameValuePair "package-${n}") self'.packages;
          devShells = lib.mapAttrs' (n: lib.nameValuePair "devShell-${n}") self'.devShells;
        in
          {inherit (self') formatter;} // packages // devShells;
      };
    };

  inputs = {
    # keep-sorted start
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    systems.url = "github:nix-systems/default";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    # keep-sorted end

    # ==== Curated External Flakes ====
    # keep-sorted start
    selexqc.inputs.nixpkgs.follows = "nixpkgs";
    selexqc.url = "github:mulatta/selexqc?ref=v0.1.0";
    seqtable.inputs.nixpkgs.follows = "nixpkgs";
    seqtable.url = "github:mulatta/seqtable?ref=v0.1.1";
    # keep-sorted end
  };
}
