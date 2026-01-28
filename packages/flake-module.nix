{ self, ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      packages = import (self + "/default.nix") { inherit pkgs; };
    };
}
