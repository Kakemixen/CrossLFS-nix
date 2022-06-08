{stdenv, sources, toolchain, crossConfig}:
  stdenv.mkDerivation {
    name = "linux-clfs";
    src = sources.linux;
    phases = [
      "unpackPhase"
      "configurePhase"
      "buildPhase"
      "installPhase"
    ];

    unpackPhase = ''
      tar xaf $src
      cd linux-*
    '';

    configurePhase = ''
      make mrproper
    '';

    buildPhase = ''
      make ARCH=${crossConfig.arch} headers_check
    '';

    installPhase = ''
      mkdir $out/${crossConfig.target}
      make ARCH=${crossConfig.arch} \
        INSTALL_HDR_PATH=$out/${crossConfig.target} headers_install
    '';
  }
