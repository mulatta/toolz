name:
let
  firstTwo = builtins.substring 0 2 name;
in
../by-name + "/${firstTwo}/${name}/package.nix"
