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
      # directory tree
      mkdir $out
      mkdir -pv $out/{bin,boot,dev,etc,home,lib/{firmware,modules}}
      mkdir -pv $out/{mnt,opt,proc,sbin,srv,sys}
      mkdir -pv $out/var/{cache,lib,local,lock,log,opt,run,spool}
      install -dv -m 0750 $out/root
      install -dv -m 1777 $out/{var/,}tmp
      mkdir -pv $out/usr/{,local/}{bin,include,lib,sbin,share,src}

      # populate with files
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
