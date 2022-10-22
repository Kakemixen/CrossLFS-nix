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
    name = "boot-mount";
    phases = [ "installPhase" ];
    installPhase = "mkdir -p $out/boot";
  };
  symlinks = pkgs.symlinkJoin {
    name = "rootfs-partition-parts";
    paths = [
      busybox
      boot_mount
      toolchain.for_target
      linux.kernel_lib
      ./files
    ];
  };
  partition = env.mkDerivation {
    name = "rootfs-partition";
    buildInputs = [
      pkgs.coreutils
      pkgs.bash
    ];
    rootfs = symlinks;
    phases = [ "installPhase" ];
    installPhase = ''
      mkdir $out

      find $rootfs -type f,l \
      -exec ${./copy_rootfs.sh} {} $out \;

      cp -rn $rootfs/* $out/
    '';
  };
in
  {
    partition = partition;
    contents = {
      busybox = busybox;
    };
  }
