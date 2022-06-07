{CCEnv, noCCEnv, fetchurl, callPackage, crossConfig}:

rec {
  name = "rpi-toolchain";
  cross-binutils = callPackage ./binutils.nix {
    crossConfig = crossConfig;
  };
  gcc-static = callPackage ./gcc.nix {
    cross-binutils = cross-binutils;
    crossConfig = crossConfig;
    mkDerivation = CCEnv.mkDerivation;
    musl = null;
  };
  musl = callPackage ./musl.nix {
    gcc = gcc-static;
    cross-binutils = cross-binutils;
    crossConfig = crossConfig;
    mkDerivation = noCCEnv.mkDerivation;
  };
  gcc = callPackage ./gcc.nix {
    cross-binutils = cross-binutils;
    crossConfig = crossConfig;
    mkDerivation = CCEnv.mkDerivation;
    musl = musl;
  };
}
