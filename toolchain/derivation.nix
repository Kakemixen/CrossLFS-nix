{pkgs, CCEnv, noCCEnv, fetchurl, callPackage, crossConfig}:

let
  sources = callPackage ./sources.nix {
    fetchurl = fetchurl;
  };

  name = "rpi-toolchain";
  usr-symlink = noCCEnv.mkDerivation {
    name = "usr-symlink";
    unpackPhase = "true";
    installPhase = ''
      mkdir -p $out/${crossConfig.target}
      ln -sf . $out/${crossConfig.target}/usr
      '';
  };
  binutils = callPackage ./binutils.nix {
    sources = sources;
    crossConfig = crossConfig;
  };
  gcc-static = callPackage ./gcc_static.nix {
    sources = sources;
    binutils = binutils;
    crossConfig = crossConfig;
    mkDerivation = CCEnv.mkDerivation;
  };
  musl = callPackage ./musl.nix {
    sources = sources;
    gcc = gcc-static;
    binutils = binutils;
    crossConfig = crossConfig;
    mkDerivation = noCCEnv.mkDerivation;
  };
  sysroot = pkgs.symlinkJoin {
    name = "sysroot-cross-toolchain";
    paths = [ usr-symlink musl binutils ];
  };
  gcc = callPackage ./gcc.nix {
    sources = sources;
    binutils = binutils;
    crossConfig = crossConfig;
    mkDerivation = CCEnv.mkDerivation;
    sysroot = sysroot;
  };
  gmp = callPackage ./gmp.nix {
    sources = sources;
    binutils = binutils;
    crossConfig = crossConfig;
    mkDerivation = CCEnv.mkDerivation;
    m4 = pkgs.m4;
  };
  mpfr = callPackage ./mpfr.nix {
    sources = sources;
    binutils = binutils;
    crossConfig = crossConfig;
    mkDerivation = CCEnv.mkDerivation;
    gmp = gmp;
  };
  mpc = callPackage ./mpc.nix {
    sources = sources;
    binutils = binutils;
    crossConfig = crossConfig;
    mkDerivation = CCEnv.mkDerivation;
    gmp = gmp;
    mpfr = mpfr;
  };
in
  {
    sysroot = sysroot;
    binutils = binutils;
    musl = musl;
    gcc = gcc;
    gmp = gmp;
    mpc = mpc;
    mpfr = mpfr;
  }
