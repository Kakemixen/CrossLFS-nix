{env, fetchurl, callPackage, toolchain, crossConfig}:
rec {
  sources = callPackage ./sources.nix {
    fetchurl = fetchurl;
  };
  uboot = callPackage ./uboot.nix {
    env = env;
    sources = sources;
    toolchain = toolchain;
    crossConfig = crossConfig;
  };
}
