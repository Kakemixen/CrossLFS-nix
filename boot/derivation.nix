{pkgs, env, toolchain, crossConfig, linux, rootfs}:
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
  uboot_tools = pkgs.callPackage ./uboot_tools.nix {
    env = env;
    sources = sources;
    toolchain = toolchain;
    crossConfig = crossConfig;
  };

  boot_files = pkgs.callPackage ./rpi/boot_files.nix {
    uboot_tools = uboot_tools;
  };

  initramfs = pkgs.callPackage ./initramfs.nix {
    env = env;
    sources = sources;
    toolchain = toolchain;
    crossConfig = crossConfig;
    linux_tools = linux.kernel_tools;
    uboot_tools = uboot_tools;
    rootfs = rootfs;
  };

  partition = pkgs.symlinkJoin {
    name = "boot-partition";
    paths = [
      linux.kernel_boot
      uboot
      boot_files
      initramfs
    ];
  };
in
  {
    partition = partition;
    uboot = uboot;
    uboot_tools = uboot_tools;
    boot_files = boot_files;
    initramfs = initramfs;
  }
