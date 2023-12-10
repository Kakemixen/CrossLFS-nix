{env, sources, toolchain, crossConfig, linux-headers}:

env.mkDerivation rec {
  name = "zlib";

  src = sources.zlib;

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
    #linux-headers
  ];

  unpackPhase = ''
    tar xaf $src
    cd zlib-*
  '';

  arch = crossConfig.arch;
  target = crossConfig.target;

  configurePhase = ''
    export ARCH=${arch}
    export CROSS_COMPILE=${target}-
    export CHOST=${target}

    CFLAGS="-Os" ./configure --shared
  '';

  buildPhase = ''
    make -j$NIX_BUILD_CORES
  '';

  installPhase = ''
    mkdir -p $out/lib

    make prefix=$out install
  '';
}
