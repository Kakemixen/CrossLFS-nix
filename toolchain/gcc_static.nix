{mkDerivation, sources, crossConfig, cross-binutils}:

mkDerivation rec {
  name = "gcc-static";

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

  buildInputs = [ cross-binutils ];

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

  configurePhase = ''
    ../${sources.gcc_version}/configure \
        --build=${host} \
        --host=${host} \
        --target=${target} \
        --prefix=$out \
        --with-sysroot=$out/${target} \
        --disable-nls \
        --disable-shared \
        --without-headers \
        --with-newlib \
        --disable-decimal-float \
        --disable-libgomp \
        --disable-libmudflap \
        --disable-libssp \
        --disable-libatomic \
        --disable-libquadmath \
        --disable-threads \
        --enable-languages=c \
        --disable-multilib \
        --with-arch=${arm_arch} \
        --with-float=${float} \
        --with-fpu=${fpu}
  '';

  buildPhase = ''
    make -j$NIX_BUILD_CORES all-gcc all-target-libgcc
  '';

  installPhase = ''
    make install-gcc install-target-libgcc
  '';
}
