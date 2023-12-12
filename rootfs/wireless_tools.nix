{env, sources, toolchain, crossConfig, linux-headers, zlib}:

env.mkDerivation rec {
  name = "wireless-tools";

  src = sources.wireless_tools;
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
    cd wireless_tools*
  '';

  arch = crossConfig.arch;
  target = crossConfig.target;

  configurePhase = ''
    sed -i s/CC\ =\ gcc/CC\ =\ ${target}\-gcc/g Makefile
    sed -i s/AR\ =\ ar/AR\ =\ ${target}\-ar/g Makefile
    sed -i s/RANLIB\ =\ ranlib/RANLIB\ =\ ${target}\-ranlib/g Makefile
  '';

  buildPhase = ''
    make PREFIX=$out
  '';

  installPhase = ''
    mkdir -p $out

    make install PREFIX=$out
  '';
}
