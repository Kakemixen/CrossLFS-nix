{mkDerivation, sources, crossConfig, gcc, cross-binutils, strace}:

mkDerivation rec {
  name = "musl";

  src = sources.musl;

  buildInputs = [ cross-binutils gcc ];

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

  binutilsEnv = cross-binutils;
  configurePhase = ''
    export PATH=$binutilsEnv/${target}/bin:$PATH
    ./configure \
      CROSS_COMPILE=${target}- \
      --prefix=/ \
      --target=${target} \
      --build=${host}
  '';

  buildPhase = ''
    make -j$NIX_BUILD_CORES
  '';

  installPhase = ''
    DESTDIR=$out/${target} make install
  '';
}
