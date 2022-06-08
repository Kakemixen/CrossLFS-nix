{mkDerivation, sources, crossConfig, cross-binutils, musl ? null}:

mkDerivation rec {
  name = if musl == null then "gcc-static" else "gcc";

  srcs = [
    sources.gcc
    sources.mpfr
    sources.gmp
    sources.mpc
  ];

  buildInputs = if musl == null then [ cross-binutils ] else [ cross-binutils musl ];
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
    #mkdir -p $out/cross-tools/${target}
    #echo "hello" > $out
    #echo $(pwd) > $out
    #echo $(ls) > $out
    #mkdir -p -- .deps
  '';

  staticConfigurePhase = ''
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

  staticBuildPhase = ''
    make -j$NIX_BUILD_CORES all-gcc all-target-libgcc
  '';

  staticInstallPhase = ''
    make install-gcc install-target-libgcc
  '';

  libBuildPhase = ''
    make -j$NIX_BUILD_CORES
  '';

  libInstallPhase = ''
    make install
  '';

  muslEnv = musl;
  binutilsEnv = cross-binutils;
  libConfigurePhase = ''
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

  configurePhase = if musl == null then staticConfigurePhase else libConfigurePhase;
  buildPhase = if musl == null then staticBuildPhase else libBuildPhase;
  installPhase = if musl == null then staticInstallPhase else libInstallPhase;
}
