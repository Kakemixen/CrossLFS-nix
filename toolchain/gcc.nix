{mkDerivation, fetchurl, crossConfig, cross-binutils, musl ? null}:

mkDerivation rec {
  name = if musl == null then "gcc-static" else "gcc";
  full_name = gcc_version;

  gcc_version="gcc-11.2.0";
  mpfr_version="mpfr-4.1.0";
  gmp_version="gmp-6.2.1";
  mpc_version="mpc-1.2.1";

  gcc_src = fetchurl {
    url = "https://gcc.gnu.org/pub/gcc/releases/${gcc_version}/${gcc_version}.tar.xz";
    sha256 = "12zs6vd2rapp42x154m479hg3h3lsafn3xhg06hp5hsldd9xr3nh";
  };
  mpfr_src = fetchurl {
    url = "http://ftp.gnu.org/gnu/mpfr/${mpfr_version}.tar.xz";
    sha256 = "0zwaanakrqjf84lfr5hfsdr7hncwv9wj0mchlr7cmxigfgqs760c";
  };
  gmp_src = fetchurl {
    url = "http://ftp.gnu.org/gnu/gmp/${gmp_version}.tar.xz";
    sha256 = "1wml97fdmpcynsbw9yl77rj29qibfp652d0w3222zlfx5j8jjj7x";
  };
  mpc_src = fetchurl {
    url = "http://ftp.gnu.org/gnu/mpc/${mpc_version}.tar.gz";
    sha256 = "0n846hqfqvmsmim7qdlms0qr86f1hck19p12nq3g3z2x74n3sl0p";
  };
  srcs = [
    gcc_src
    mpfr_src
    gmp_src
    mpc_src
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
    ../${gcc_version}/configure \
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

    ../${gcc_version}/configure \
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
