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
    export CC=${target}-gcc

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
