{stdenv, fetchurl, callPackage, crossConfig}:

rec {
  name = "rpi-toolchain";
  binutils = callPackage ./binutils.nix {
    crossConfig = crossConfig;
  };
  gcc = callPackage ./gcc.nix {
    crossConfig = crossConfig;
  };
}
