{pkgs, callPackage}:
let
  empty_image = callPackage ./empty_image.nix {
    env = pkgs.stdenv;
    parted = pkgs.parted;
    dosfstools = pkgs.dosfstools;
    e2fsprogs = pkgs.e2fsprogs;
  };
in
  empty_image
