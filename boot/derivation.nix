{pkgs, env, toolchain, crossConfig, linux}:
let
  sources = pkgs.callPackage ./sources.nix {
    fetchurl = pkgs.fetchurl;
  };
  uboot = pkgs.callPackage ./uboot.nix {
    env = env;
    sources = sources;
    toolchain = toolchain;
    crossConfig = crossConfig;
  };

  boot_files = pkgs.callPackage ./rpi/boot_files.nix {};

  partition = pkgs.symlinkJoin {
    name = "boot-partition";
    paths = [
      linux.kernel_boot
      uboot
      boot_files
    ];
  };
in
  {
    partition = partition;
    uboot = uboot;
    boot_files = boot_files;
  }
