{
  flake.templates = let
    welcomeText = ''
      IMPORTANT: Run init-template before direnv or nix develop:

        nix run github:zmblr/toolz#init-template -- <project-name> .

      Then start developing:

        direnv allow
        # or: nix develop .#impure
    '';
  in {
    rust = {
      path = ./rust;
      description = "Basic toolz rust project template";
      inherit welcomeText;
    };
    pixi = {
      path = ./pixi;
      description = "Basic toolz pixi project template";
      inherit welcomeText;
    };
    uv = {
      path = ./uv;
      description = "Basic toolz uv project template";
      inherit welcomeText;
    };
    default = {
      path = ./nix;
      description = "Basic toolz nix project template";
      inherit welcomeText;
    };
    marimo = {
      path = ./marimo;
      description = "Marimo reactive notebook project using uv2nix";
      inherit welcomeText;
    };
  };

  perSystem = {pkgs, ...}: {
    # Template initialization app
    # Usage: nix run .#init-template -- <project-name> [directory]
    apps.init = {
      type = "app";
      program = "${pkgs.writeShellApplication {
        name = "init-template";
        runtimeInputs = with pkgs; [coreutils gnused findutils file gnugrep];
        text = builtins.readFile ./lib/init-template.sh;
      }}/bin/init-template";
    };
  };
}
