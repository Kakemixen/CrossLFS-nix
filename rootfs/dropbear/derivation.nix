{env, sources, toolchain, crossConfig, linux-headers, zlib}:

env.mkDerivation rec {
  name = "dropbear";

  src = sources.dropbear;
  files = ./files;

  phases = [
    "unpackPhase"
    "configurePhase"
    "buildPhase"
    "installPhase"
  ];

  buildInputs = [
    env.cc
    #toolchain.gmp
    #toolchain.mpc
    #toolchain.mpfr
    linux-headers
    zlib
  ];

  unpackPhase = ''
    tar xaf $src
    cd dropbear*
  '';

  arch = crossConfig.arch;
  target = crossConfig.target;

  configurePhase = ''
    export CC="${target}-gcc --sysroot=${toolchain.sysroot}/${target}"
    export CXX="${target}-g++ --sysroot=${toolchain.sysroot}/${target}"
    export AR="${target}-ar"
    export AS="${target}-as"
    export LD="${target}-ld --sysroot=${toolchain.sysroot}/${target}"
    export RANLIB="${target}-ranlib"
    export READELF="${target}-readelf"
    export STRIP="${target}-strip"

    CC="$CC -Os" ./configure --prefix=/usr --host=${target}
  '';

  buildPhase = ''
    make MULTI=1 \
      PROGRAMS="dropbear dbclient dropbearkey dropbearconvert scp" \
      -j$NIX_BUILD_CORES
  '';

  installPhase = ''
    mkdir -p $out

    make MULTI=1 \
      PROGRAMS="dropbear dbclient dropbearkey dropbearconvert scp" \
      install DESTDIR=$out


    # Add init files
    mkdir -p $out/etc/dropbear
    cp -ra $files/* $out
  '';
}
