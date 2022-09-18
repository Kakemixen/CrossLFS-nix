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
    CCEnv = pkgs.gcc11Stdenv;
    noCCEnv = pkgs.stdenvNoCC;
    fetchurl = pkgs.fetchurl;
    callPackage = pkgs.callPackage;
  };

  linux = callPackage ./kernel/derivation.nix {
    env = pkgs.gcc11Stdenv;
    toolchain = toolchain;
    crossConfig = crossConfig;
  };

  boot = callPackage ./boot/derivation.nix {
    env = pkgs.gcc11Stdenv;
    toolchain = toolchain;
    crossConfig = crossConfig;
  };

  boot_files = callPackage ./rpi/boot_files.nix {};

  boot_partition = pkgs.symlinkJoin {
    name = "boot-partition";
    paths = [
      linux.kernel_boot
      boot.uboot
      boot_files
    ];
  };

  image = callPackage ./disk_img/derivation.nix {
    bootfs = boot_partition;
    rootfs = null;
  };
in
  image
