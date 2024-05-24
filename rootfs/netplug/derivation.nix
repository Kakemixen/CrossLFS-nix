{env, sources, toolchain, crossConfig, linux-headers}:

env.mkDerivation rec {
  name = "netplug";

  src = sources.netplug;
  patches = [
    ./patch1.patch
  ];
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
  ];

  unpackPhase = ''
    tar xaf $src
    cd netplug-*
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


    for patch in $patches
    do
      patch -Np1 -i $patch
    done
  '';

  buildPhase = ''
    make -j$NIX_BUILD_CORES
  '';

  installPhase = ''
    mkdir -p $out

    make install DESTDIR=$out

    # Add init files
    cp -ra $files/* $out
  '';
}
