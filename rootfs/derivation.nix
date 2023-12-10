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

  iana_etc = pkgs.callPackage ./iana_etc.nix {
    env = env;
    sources = sources;
  };

  zlib = pkgs.callPackage ./zlib.nix {
    env = env;
    toolchain = toolchain;
    crossConfig = crossConfig;
    linux-headers = linux.headers;
    sources = sources;
  };

  netplug = pkgs.callPackage ./netplug/derivation.nix {
    env = env;
    toolchain = toolchain;
    crossConfig = crossConfig;
    linux-headers = linux.headers;
    sources = sources;
  };

  dropbear = pkgs.callPackage ./dropbear/derivation.nix {
    env = env;
    toolchain = toolchain;
    crossConfig = crossConfig;
    linux-headers = linux.headers;
    zlib = zlib;
    sources = sources;
  };

  symlinks = pkgs.symlinkJoin {
    name = "rootfs-partition-parts";
    paths = [
      busybox
      iana_etc
      zlib
      netplug
      dropbear
      toolchain.for_target
      linux.kernel_lib
      ./files
    ];
  };

  squashfs = env.mkDerivation {
    name = "rootfs-partition";
    buildInputs = [
      pkgs.coreutils
      pkgs.bash
      pkgs.squashfsTools
    ];
    rootfs = symlinks;
    phases = [
      "buildPhase"
      "installPhase"
    ];
    buildPhase = ''
      # directory tree
      mkdir root
      mkdir -pv root/{bin,boot,dev,etc,home,lib/{firmware,modules}}
      mkdir -pv root/{mnt,opt,proc,sbin,srv,sys}
      mkdir -pv root/var/{cache,lib,local,lock,log,opt,run,spool}
      install -dv -m 0750 root/root
      install -dv -m 1777 root/{var/,}tmp
      mkdir -pv root/usr/{,local/}{bin,include,lib,sbin,share,src}

      # populate with files
      find $rootfs -type f,l \
      -exec ${./copy_rootfs.sh} {} root \;

      echo HERE
      cp -rnv $rootfs/* root/

      mksquashfs root/ root.sqsh
    '';
    installPhase = ''
      mkdir $out
      mv root.sqsh $out/
    '';
  };
in
  {
    squashfs = squashfs;
    busybox = busybox;
    iana_etc = iana_etc;
    zlib = zlib;
    netplug = netplug;
    dropbear = dropbear;
  }
