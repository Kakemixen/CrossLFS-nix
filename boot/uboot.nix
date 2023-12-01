{pkgs, env, sources, toolchain, crossConfig}:
env.mkDerivation rec {
  name = "uboot-clfs";

  src = sources.uboot;

  files = [
    ./rpi/clfs_defconfig
    ./rpi/clfs_env.env
  ];

  phases = [
    "unpackPhase"
    "configurePhase"
    "buildPhase"
    "installPhase"
  ];

  unpackPhase = ''
    tar xaf $src
    cd u-boot-*

    cp $files .

    # this only works because there is only one of each

    mv *clfs_defconfig configs/clfs_defconfig
    mv *.env board/raspberrypi/rpi/clfs_env.env

    # remove conflicting define
    sed -i '/#define CONFIG_EXTRA_ENV_SETTINGS/,+5d' \
        include/configs/rpi.h

  '';

  arch = crossConfig.arch;
  host = crossConfig.host;
  target = crossConfig.target;
  arm_arch = crossConfig.arm_arch;
  float = crossConfig.float;
  fpu = crossConfig.fpu;

  buildInputs = [
    toolchain.gcc
    pkgs.flex
    pkgs.bison
    pkgs.bc
    pkgs.openssl
  ];

  configurePhase = ''
    export ARCH=${arch}
    export CROSS_COMPILE=${target}-

    # assume this works
    make clfs_defconfig
  '';

  buildPhase = ''
    make -j$NIX_BUILD_CORES
  '';

  installPhase = ''
    mkdir -p $out
    cp u-boot.bin $out
  '';
}
