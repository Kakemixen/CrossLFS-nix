{stdenv, fetchurl, crossConfig}:

stdenv.mkDerivation rec {
  name = "gcc";
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

  phases = [
    "unpackPhase"
    "configurePhase"
    "buildPhase"
    "installPhase"
  ];

  unpackPhase = ''
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
    #mv mpc-* mpc -v
    cd ..
    mkdir gcc-build
    cd gcc-build
  '';

  configurePhase = ''
    ../${gcc_version}/configure \
        --build=${crossConfig.host} \
        --host=${crossConfig.host} \
        --target=${crossConfig.target} \
        --prefix=$out/cross-tools \
        --with-sysroot=$out/cross-tools/${crossConfig.target} \
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
        --with-arch=${crossConfig.arch} \
        --with-float=${crossConfig.float} \
        --with-fpu=${crossConfig.fpu}
  '';

  buildPhase = ''
    make -j42 all-gcc all-target-libgcc
  '';

  installPhase = ''
    make install-gcc install-target-libgcc
  '';
}
