let
  crossConfig = {
    float="hard";
    fpu="vfp";
    host="x86_64-cross-linux-gnu";
    target="arm-linux-musleabihf";
    arch="arm";
    endian="little";
    arm_arch="armv6zk";
  };

  pkgs = import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/93ca5ab64f78ce778c0bcecf9458263f0f6289b6.tar.gz") {};

  callPackage = pkgs.callPackage;

  toolchain = callPackage ./toolchain/derivation.nix {
    crossConfig = crossConfig;
  };

  linux = callPackage ./kernel/derivation.nix {
    env = pkgs.gcc11Stdenv;
    toolchain = toolchain;
    crossConfig = crossConfig;
  };

  boot_partition = callPackage ./boot/derivation.nix {
    env = pkgs.gcc11Stdenv;
    toolchain = toolchain;
    crossConfig = crossConfig;
    linux = linux;
  };

  rootfs_partition = callPackage ./rootfs/derivation.nix {
    linux = linux;
  };

  image = callPackage ./disk_img/derivation.nix {
    bootfs = boot_partition;
    rootfs = rootfs_partition;
  };
in
  image
