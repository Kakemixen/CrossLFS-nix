{pkgs, crossConfig, targetPlatform}:

let
  sources = callPackage ./sources.nix {
    fetchurl = pkgs.fetchurl;
  };

  CCEnv = pkgs.gcc11Stdenv;
  noCCEnv = pkgs.stdenvNoCC;
  callPackage = pkgs.callPackage;

  myTargetPlatformElab = pkgs.lib.systems.elaborate targetPlatform;
  crossEnvNoCC = pkgs.stdenvNoCC.override {
    targetPlatform = myTargetPlatformElab;
  };

  usr-symlink = noCCEnv.mkDerivation {
    name = "usr-symlink";
    unpackPhase = "true";
    installPhase = ''
      mkdir -p $out/${crossConfig.target}
      ln -sf . $out/${crossConfig.target}/usr
      '';
  };
  binutils_unwrapped = callPackage ./binutils.nix {
    sources = sources;
    crossConfig = crossConfig;
  };
  binutils_nolib = pkgs.wrapBintoolsWith {
    name = "binutils-nolib-wrapped";
    bintools = binutils_unwrapped;
    libc = null;
    stdenvNoCC = crossEnvNoCC;
  };

  gcc_static_unwrapped = callPackage ./gcc_static.nix {
    sources = sources;
    binutils = binutils_nolib;
    crossConfig = crossConfig;
    mkDerivation = CCEnv.mkDerivation;
  };
  gcc_static = pkgs.wrapCCWith rec {
    name = "gcc-static-wrapped";
    cc = gcc_static_unwrapped;
    bintools = binutils_nolib;
    stdenvNoCC = crossEnvNoCC;
  };

  musl = callPackage ./musl.nix {
    sources = sources;
    gcc = gcc_static;
    crossConfig = crossConfig;
    mkDerivation = crossEnvNoCC.mkDerivation;
  };
  glibc = callPackage ./glibc.nix {
    sources = sources;
    gcc = gcc_static;
    binutils = binutils_nolib;
    crossConfig = crossConfig;
    mkDerivation = crossEnvNoCC.mkDerivation;
    bison = pkgs.bison;
    python3 = pkgs.python3;
    coreutils = pkgs.coreutils;
  };
  libc = if targetPlatform.libc == "musl" then musl else glibc;

  binutils = pkgs.wrapBintoolsWith {
    name = "binutils-wrapped";
    bintools = binutils_unwrapped;
    libc = libc;
    stdenvNoCC = crossEnvNoCC;
  };

  sysroot = pkgs.symlinkJoin {
    name = "sysroot-cross-toolchain";
    paths = [ usr-symlink libc binutils ];
  };
  gcc_unwrapped = callPackage ./gcc.nix {
    sources = sources;
    binutils = binutils;
    crossConfig = crossConfig;
    mkDerivation = CCEnv.mkDerivation;
    sysroot = sysroot;
  };
  gcc = pkgs.wrapCCWith rec {
    name = "gcc-wrapped";
    cc = gcc_unwrapped;
    bintools = binutils;
    stdenvNoCC = crossEnvNoCC;
  };

  files_for_target = callPackage ./for_target.nix {
    mkDerivation = crossEnvNoCC.mkDerivation;
    sources = sources;
    crossConfig = crossConfig;
    cc = gcc;
    gcc_unwrapped = gcc_unwrapped;
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
    glibc = glibc;
    libc = libc;
    gcc = gcc;
    gmp = gmp;
    mpc = mpc;
    mpfr = mpfr;
    for_target = files_for_target;
  }
