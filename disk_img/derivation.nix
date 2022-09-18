{pkgs, callPackage, bootfs, rootfs}:
let
  empty_image = callPackage ./empty_image.nix {
    env = pkgs.stdenv;
    parted = pkgs.parted;
    dosfstools = pkgs.dosfstools;
    e2fsprogs = pkgs.e2fsprogs;
    mtools = pkgs.mtools;
    bootfs = bootfs;
    rootfs = rootfs;
  };
in
  empty_image
