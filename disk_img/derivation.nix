{pkgs, callPackage}:
let
  empty_image = callPackage ./empty_image.nix {
    env = pkgs.stdenv;
    parted = pkgs.parted;
  };
in
  empty_image
