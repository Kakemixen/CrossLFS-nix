{env, fetchurl, callPackage, toolchain, crossConfig}:
rec {
  sources = callPackage ./sources.nix {
    fetchurl = fetchurl;
  };
  headers = callPackage ./headers.nix {
    sources = sources;
    toolchain = toolchain;
    crossConfig = crossConfig;
  };
  kernel = callPackage ./kernel.nix {
    env = env;
    sources = sources;
    toolchain = toolchain;
    crossConfig = crossConfig;
  };
}
