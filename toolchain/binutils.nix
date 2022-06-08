{stdenv, sources, crossConfig}:

stdenv.mkDerivation rec {
  name = "binutils";

  src = sources.binutils;

  phases = [
    "unpackPhase"
    "configurePhase"
    "buildPhase"
    "installPhase"
  ];

  unpackPhase = ''
    tar xaf $src
    cd binutils-*
  '';

  configurePhase = ''
    ./configure \
       --prefix=$out \
       --target=${crossConfig.target} \
       --with-sysroot=$out/${crossConfig.target} \
       --disable-nls \
       --disable-multilib && \
    make configure-host
  '';

  buildPhase = ''
    make -j$NIX_BUILD_CORES
  '';

  installPhase = ''
    make install
  '';
}
