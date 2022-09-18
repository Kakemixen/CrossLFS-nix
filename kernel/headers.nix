{stdenv, sources, toolchain, crossConfig, rsync}:
  stdenv.mkDerivation {
    name = "linux-headers";
    src = sources.linux;
    phases = [
      "unpackPhase"
      "configurePhase"
      "installPhase"
    ];

    buildInputs = [
      rsync
    ];

    unpackPhase = ''
      tar xaf $src
      cd linux-*
    '';

    configurePhase = ''
      make mrproper
    '';

    # TODO why no work?
    #buildPhase = ''
    #  make ARCH=${crossConfig.arch} headers_check
    #'';

    installPhase = ''
      mkdir -p $out/${crossConfig.target}
      make ARCH=${crossConfig.arch} \
        INSTALL_HDR_PATH=$out/${crossConfig.target} headers_install
    '';
  }
