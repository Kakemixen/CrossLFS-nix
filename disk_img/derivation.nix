{pkgs, callPackage, bootfs, rootfs}:
let
  image = callPackage ./make_image.nix {
    env = pkgs.stdenv;
    parted = pkgs.parted;
    coreutils = pkgs.coreutils;
    sed = pkgs.gnused;
    dosfstools = pkgs.dosfstools;
    e2fsprogs = pkgs.e2fsprogs;
    mtools = pkgs.mtools;
    bootfs = bootfs;
    rootfs = rootfs;
  };
in
  image
