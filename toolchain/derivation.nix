{env, fetchurl, callPackage, crossConfig}:

rec {
  name = "rpi-toolchain";
  cross-binutils = callPackage ./binutils.nix {
    crossConfig = crossConfig;
  };
  gcc = callPackage ./gcc.nix {
    cross-binutils = cross-binutils;
    crossConfig = crossConfig;
    strace = strace;
    mkDerivation = env.mkDerivation;
  };
}
