{mkDerivation, sources, crossConfig, binutils, gmp}:

mkDerivation rec {
  name = "mpfr";

  src = sources.mpfr;

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

  buildInputs = [ binutils gmp ];

  unpackPhase = ''
    tar xaf $src
    mkdir mpfr-build
    cd mpfr-build
  '';

  configurePhase = ''
    ../${sources.mpfr_version}/configure \
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
