{stdenv, fetchurl, crossConfig}:

stdenv.mkDerivation rec {
  name = "binutils";
  full_name = "binutils-2.37";
  src = fetchurl {
    url = "http://ftp.gnu.org/gnu/binutils/${full_name}.tar.xz";
    sha256 = "0b53hhgfnafw27y0c3nbmlfidny2cc5km29pnfffd8r0y0j9f3c2";
  };

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
