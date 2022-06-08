{mkDerivation, sources, crossConfig, cross-binutils, musl}:

mkDerivation rec {
  name = "gcc";

  srcs = [
    sources.gcc
    sources.mpfr
    sources.gmp
    sources.mpc
  ];

  hardeningDisable = [ "format" ];  # to build the cross-compiler

  host = crossConfig.host;
  target = crossConfig.target;
  arm_arch = crossConfig.arm_arch;
  float = crossConfig.float;
  fpu = crossConfig.fpu;

  phases = [
    "unpackPhase"
    "configurePhase"
    "buildPhase"
    "installPhase"
  ];

  buildInputs = [ cross-binutils musl ];

  unpackPhase = ''
    echo whoami $(whoami)
    gcc --version
    mkdir src
    cd src
    for src in $srcs
    do
      tar xaf $src
    done
    mv mpfr-* gcc-*/
    mv gmp-* gcc-*/
    mv mpc-* gcc-*/
    cd gcc-*
    mv mpfr-* mpfr -v
    mv gmp-* gmp -v
    mv mpc-* mpc -v
    cd ..
    mkdir gcc-build
    cd gcc-build
  '';

  muslEnv = musl;
  binutilsEnv = cross-binutils;
  configurePhase = ''
    # make tmp rootfs
    mkdir -p ../rootfs/${target}
    ln -sf . ../rootfs/${target}/usr # this is kinda weird
    cp -r $muslEnv/* ../rootfs/
    chmod u+w -R ../rootfs   # why is this necessary?
    cp -r $binutilsEnv/* ../rootfs/

    ../${sources.gcc_version}/configure \
        --build=${host} \
        --host=${host} \
        --target=${target} \
        --prefix=$out \
        --with-sysroot=$(pwd)/../rootfs/${target} \
        --disable-nls \
        --enable-languages=c \
        --enable-c99 \
        --enable-long-long \
        --disable-libmudflap \
        --disable-multilib \
        --with-arch=${arm_arch} \
        --with-float=${float} \
        --with-fpu=${fpu}
  '';

  buildPhase = ''
    make -j$NIX_BUILD_CORES
  '';

  installPhase = ''
    make install
  '';
}
