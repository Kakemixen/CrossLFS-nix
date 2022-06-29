{pkgs, env, sources, toolchain, crossConfig}:

env.mkDerivation rec {
  name = "linux-clfs";

  src = sources.linux;

  phases = [
    "unpackPhase"
    "configurePhase"
    "buildPhase"
    "installPhase"
  ];

  buildInputs = [
    toolchain.gcc
    toolchain.binutils
    toolchain.musl
    pkgs.flex
    pkgs.bison
    pkgs.bc
    pkgs.openssl
    pkgs.perl
  ];

  unpackPhase = ''
    tar xaf $src
    cd linux-*
    make mrproper
  '';

  arch = crossConfig.arch;
  host = crossConfig.host;
  target = crossConfig.target;
  arm_arch = crossConfig.arm_arch;
  float = crossConfig.float;
  fpu = crossConfig.fpu;

  configurePhase = ''
    export ARCH=${arch}
    export CROSS_COMPILE=${target}-

    make bcm2835_defconfig
  '';

  buildPhase = ''
    make -j$NIX_BUILD_CORES zImage
    make -j$NIX_BUILD_CORES dtbs
    make -j$NIX_BUILD_CORES modules
  '';

  installPhase = ''
    mkdir -p $out/boot

    INSTALL_PATH=$out/boot make install
    cp arch/arm/boot/*Image $out/boot
    cp -r arch/arm/boot/dts/* $out/boot

    make INSTALL_MOD_PATH=$out modules_install
  '';
}
