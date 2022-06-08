{fetchurl}:
rec {
  binutils_version="binutils-2.37";
  gcc_version="gcc-11.2.0";
  mpfr_version="mpfr-4.1.0";
  gmp_version="gmp-6.2.1";
  mpc_version="mpc-1.2.1";
  musl_version = "musl-1.2.2";

  binutils = fetchurl {
    url = "http://ftp.gnu.org/gnu/binutils/${binutils_version}.tar.xz";
    sha256 = "0b53hhgfnafw27y0c3nbmlfidny2cc5km29pnfffd8r0y0j9f3c2";
  };
  gcc = fetchurl {
    url = "https://gcc.gnu.org/pub/gcc/releases/${gcc_version}/${gcc_version}.tar.xz";
    sha256 = "12zs6vd2rapp42x154m479hg3h3lsafn3xhg06hp5hsldd9xr3nh";
  };
  mpfr = fetchurl {
    url = "http://ftp.gnu.org/gnu/mpfr/${mpfr_version}.tar.xz";
    sha256 = "0zwaanakrqjf84lfr5hfsdr7hncwv9wj0mchlr7cmxigfgqs760c";
  };
  gmp = fetchurl {
    url = "http://ftp.gnu.org/gnu/gmp/${gmp_version}.tar.xz";
    sha256 = "1wml97fdmpcynsbw9yl77rj29qibfp652d0w3222zlfx5j8jjj7x";
  };
  mpc = fetchurl {
    url = "http://ftp.gnu.org/gnu/mpc/${mpc_version}.tar.gz";
    sha256 = "0n846hqfqvmsmim7qdlms0qr86f1hck19p12nq3g3z2x74n3sl0p";
  };
  musl = fetchurl {
    url = "http://www.musl-libc.org/releases/${musl_version}.tar.gz";
    sha256 = "1p8r6bac64y98ln0wzmnixysckq3crca69ys7p16sy9d04i975lv";
  };
}
