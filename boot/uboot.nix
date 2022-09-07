{pkgs, env, sources, toolchain, crossConfig}:
env.mkDerivation rec {
  name = "uboot-clfs";

  src = sources.uboot;

  phases = [
    "unpackPhase"
    "configurePhase"
    "buildPhase"
    "installPhase"
  ];

  unpackPhase = ''
    tar xaf $src
    cd u-boot-*
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
    make rpi_3_32b_defconfig
  '';

  buildPhase = ''
    make -j$NIX_BUILD_CORES
  '';

  installPhase = ''
    mkdir -p $out/boot
    cp u-boot.bin $out/boot
  '';
}
