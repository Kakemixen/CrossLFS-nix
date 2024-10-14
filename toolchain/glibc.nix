{mkDerivation, sources, crossConfig, gcc, strace, binutils}:

mkDerivation rec {
  name = "glibc";

  src = sources.glibc;

  nativeBuildInputs = [
    gcc
    binutils
  ];

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
    tar xaf $src
    cd glibc-*
    mkdir -v build
    cd build
  '';

  configurePhase = ''
    #patch -Np1 -i ../glibc-2.39-fhs-1.patch
    echo "rootsbindir=/usr/sbin" > configparms

    sed -i '3466s/test $ac_status = 0; }/if test $ac_status = 0; then break; fi; }/' ../configure

    TARGET=${target} \
    BUILD_CC="gcc" CC="${target}-gcc" \
    AR="${target}-ar" RANLIB="${target}-ranlib" \
    ../configure \
      CROSS_COMPILE=${target}- \
      --prefix=/ \
      --host=${target} \
      --build=${host} \
      --enable-stack-protector=strong \
      --with-binutils=${binutils}/bin
  '';

  buildPhase = ''
    make -j$NIX_BUILD_CORES

    #sed '/RTLDLIST=/s@/usr@@g' -i /usr/bin/ldd
  '';

  installPhase = ''
    DESTDIR=$out/${target} make install
  '';
}
