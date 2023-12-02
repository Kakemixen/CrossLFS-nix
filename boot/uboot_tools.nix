{pkgs, env, sources, toolchain, crossConfig}:
env.mkDerivation rec {
  name = "uboot-clfs";

  src = sources.uboot;

  phases = [
    "unpackPhase"
    "configurePhase"
    "buildPhase"
    "installPhase"
  ];

  unpackPhase = ''
    tar xaf $src
    cd u-boot-*
  '';

  buildInputs = [
    toolchain.gcc
  ];

  nativeBuildInputs = [
    pkgs.flex
    pkgs.bison
    pkgs.bc
    pkgs.openssl
    pkgs.python3
    pkgs.SDL2.dev
    pkgs.swig
    pkgs.which
    pkgs.libuuid
    pkgs.gnutls
  ];

  configurePhase = ''
    # assume this works
    make tools-only_defconfig
  '';

  buildPhase = ''
    make -j$NIX_BUILD_CORES tools
    #make tools
  '';

  installPhase = ''
    mkdir -p $out/bin
    tools=$(find tools/ -type f -executable -maxdepth 1)
    echo $tools
    cp $tools $out/bin
  '';
}
