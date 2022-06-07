{mkDerivation, fetchurl, crossConfig, gcc, cross-binutils, strace}:

mkDerivation rec {
  name = "musl-1.2.2";
  src = fetchurl {
    url = "http://www.musl-libc.org/releases/${name}.tar.gz";
    sha256 = "1p8r6bac64y98ln0wzmnixysckq3crca69ys7p16sy9d04i975lv";
  };

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
