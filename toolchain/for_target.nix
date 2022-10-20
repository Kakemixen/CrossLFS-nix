{mkDerivation, sources, crossConfig, gcc_unwrapped, cc}:

mkDerivation rec {
  name = "tooclahin-files-for-target";

  src = sources.musl;

  buildInputs = [
    cc
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
    cd musl-*
  '';

  configurePhase = ''
    ./configure \
      CROSS_COMPILE=${target}- \
      --prefix=/ \
      --disable-static \
      --target=${target}
  '';

  buildPhase = ''
    make -j$NIX_BUILD_CORES
  '';

  installPhase = ''
    mkdir -p $out/lib
    cp -vrL ${gcc_unwrapped}/${crossConfig.target}/lib/* $out/lib

    DESTDIR=$out make install-libs
  '';
}
