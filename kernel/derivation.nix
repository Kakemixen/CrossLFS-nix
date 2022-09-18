{env, fetchurl, callPackage, toolchain, crossConfig}:
let
  sources = callPackage ./sources.nix {
    fetchurl = fetchurl;
  };
  kernel = callPackage ./kernel.nix {
    env = env;
    sources = sources;
    toolchain = toolchain;
    crossConfig = crossConfig;
  };
in
{
  headers = callPackage ./headers.nix {
    sources = sources;
    toolchain = toolchain;
    crossConfig = crossConfig;
  };
  kernel_boot = env.mkDerivation {
    name = "linux-clfs-boot";
    src = kernel;
    phases = [
      "installPhase"
    ];
    installPhase = ''
      ln -sf $src/boot $out
    '';
  };
  kernel_lib = env.mkDerivation {
    name = "linux-clfs-lib";
    src = kernel;
    phases = [
      "installPhase"
    ];
    installPhase = ''
      mkdir -p $out
      ln -sf $src/lib $out/lib
    '';
  };
}
