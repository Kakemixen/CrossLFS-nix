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
    export CC=${target}-gcc

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
