{env, sources, toolchain, crossConfig, hostcc, linux-headers}:

env.mkDerivation rec {
  name = "busybox";

  src = sources.busybox;

  phases = [
    "unpackPhase"
    "configurePhase"
    "buildPhase"
    "installPhase"
  ];

  buildInputs = [
    env.cc
    toolchain.gmp
    toolchain.mpc
    toolchain.mpfr
    linux-headers
  ];

  nativeBuildInputs = [
    hostcc
  ];

  unpackPhase = ''
    tar xaf $src
    cd busybox-*
    make distclean
  '';

  arch = crossConfig.arch;
  target = crossConfig.target;

  configurePhase = ''
    export ARCH=${arch}
    export CROSS_COMPILE=${target}-

    make defconfig

    # make static
    sed -i 's/# \(CONFIG_STATIC\) is not set/\1=y/' .config

    # Disable building both ifplugd and inetd as they both have issues building against musl:
    sed -i 's/\(CONFIG_\)\(.*\)\(INETD\)\(.*\)=y/# \1\2\3\4 is not set/g' .config
    sed -i 's/\(CONFIG_IFPLUGD\)=y/# \1 is not set/' .config

    # Disable the use of utmp/wtmp as musl does not support them:
    sed -i 's/\(CONFIG_FEATURE_WTMP\)=y/# \1 is not set/' .config
    sed -i 's/\(CONFIG_FEATURE_UTMP\)=y/# \1 is not set/' .config


    # Disable the use of ipsvd for both TCP and UDP as it has issues building against musl (similar to inetd's issues):
    sed -i 's/\(CONFIG_UDPSVD\)=y/# \1 is not set/' .config
    sed -i 's/\(CONFIG_TCPSVD\)=y/# \1 is not set/' .config
  '';

  buildPhase = ''
    make -j$NIX_BUILD_CORES
  '';

  installPhase = ''
    mkdir -p $out

    make CONFIG_PREFIX=$out install
  '';
}
