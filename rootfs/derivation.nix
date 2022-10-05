{pkgs, env, toolchain, crossConfig, linux}:
let
  sources = pkgs.callPackage ./sources.nix {
    fetchurl = pkgs.fetchurl;
  };
  busybox = pkgs.callPackage ./busybox.nix {
    env = env;
    toolchain = toolchain;
    crossConfig = crossConfig;
    linux-headers = linux.headers;
    sources = sources;
  };

  boot_mount = env.mkDerivation {
    name = "true";
    phases = [ "installPhase" ];
    installPhase = "mkdir -p $out/boot";
  };
in
pkgs.symlinkJoin {
  name = "rootfs-partition";
  paths = [
    linux.kernel_lib
    busybox
    boot_mount
  ];
}
