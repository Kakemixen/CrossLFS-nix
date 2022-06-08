{CCEnv, noCCEnv, fetchurl, callPackage, crossConfig}:

rec {
  sources = callPackage ./sources.nix {
    fetchurl = fetchurl;
  };

  name = "rpi-toolchain";
  cross-binutils = callPackage ./binutils.nix {
    sources = sources;
    crossConfig = crossConfig;
  };
  gcc-static = callPackage ./gcc.nix {
    sources = sources;
    cross-binutils = cross-binutils;
    crossConfig = crossConfig;
    mkDerivation = CCEnv.mkDerivation;
    musl = null;
  };
  musl = callPackage ./musl.nix {
    sources = sources;
    gcc = gcc-static;
    cross-binutils = cross-binutils;
    crossConfig = crossConfig;
    mkDerivation = noCCEnv.mkDerivation;
  };
  gcc = callPackage ./gcc.nix {
    sources = sources;
    cross-binutils = cross-binutils;
    crossConfig = crossConfig;
    mkDerivation = CCEnv.mkDerivation;
    musl = musl;
  };
}
