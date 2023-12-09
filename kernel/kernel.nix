{pkgs, env, sources, toolchain, crossConfig}:

env.mkDerivation rec {
  name = "linux-clfs";

  src = sources.linux;
  defconfig = ./clfs_defconfig;

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
    toolchain.gmp
    toolchain.mpc
    toolchain.mpfr
    pkgs.flex
    pkgs.bison
    pkgs.bc
    pkgs.openssl
    pkgs.perl
    pkgs.libyaml
  ];

  nativeBuildInputs = [
    pkgs.ncurses
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


    cp ${defconfig} arch/arm/configs/clfs_defconfig
    make clfs_defconfig
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
    cp -r arch/arm/boot/dts/bcm2837* $out/boot

    make INSTALL_MOD_PATH=$out modules_install

    mkdir -p $out/bin
    cp usr/gen_init* $out/bin
  '';
}
