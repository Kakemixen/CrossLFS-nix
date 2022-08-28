{mkDerivation, sources, crossConfig, binutils, m4}:

mkDerivation rec {
  name = "gmp";

  src = sources.gmp;

  hardeningDisable = [ "format" ];  # to build the cross-compiler

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

  buildInputs = [ binutils m4 ];

  unpackPhase = ''
    tar xaf $src
    mkdir gmp-build
    cd gmp-build
  '';

  configurePhase = ''
    ../${sources.gmp_version}/configure \
        --build=${host} \
        --host=${host} \
        --prefix=$out \
        --with-sysroot=$out/${target} \
  '';

  buildPhase = ''
    make -j$NIX_BUILD_CORES
  '';

  installPhase = ''
    make install
  '';
}
