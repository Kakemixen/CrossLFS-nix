rec {
  pkgs = import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/93ca5ab64f78ce778c0bcecf9458263f0f6289b6.tar.gz") {};
  stdenv = pkgs.stdenv;
  fetchurl = pkgs.fetchurl;
  callPackage = pkgs.callPackage;

  crossConfig = rec {
    float="hard";
    fpu="vfp";
    host="x86_64-cross-linux-gnu";
    target="arm-linux-musleabihf";
    arch="arm";
    endian="little";
    arm_arch="armv6z";
  };
  toolchain = callPackage ./toolchain/derivation.nix {
    crossConfig = crossConfig;
  };
}
