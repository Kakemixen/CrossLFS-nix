{mkDerivation, sources, crossConfig, binutils, gmp, mpfr}:

mkDerivation rec {
  name = "mpc";

  src = sources.mpc;

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

  buildInputs = [ binutils gmp mpfr ];

  unpackPhase = ''
    tar xaf $src
    mkdir mpc-build
    cd mpc-build
  '';

  configurePhase = ''
    ../${sources.mpc_version}/configure \
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
