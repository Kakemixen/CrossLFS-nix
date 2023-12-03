{pkgs, env, sources, toolchain, crossConfig, linux_tools, uboot_tools, rootfs}:

env.mkDerivation rec {
  name = "initramfs";

  init = ./init;

  nativeBuildInputs = [
    toolchain.gcc
    linux_tools
    uboot_tools
  ];

  init_cpio_list = ''
    dir /dev 0755 0 0
    nod /dev/console 0600 0 0 c 5 1
    dir /root 0700 0 0
    dir /sbin 0755 0 0
    dir /bin 0755 0 0
    file /bin/busybox ${rootfs.busybox}/bin/busybox 0755 0 0
    file /init ${init} 0755 0 0
  '';

  phases = [
    "configurePhase"
    "buildPhase"
    "installPhase"
  ];

  configurePhase = ''
    echo "$init_cpio_list" > init_cpio_list.txt
  '';

  buildPhase = ''
    #${crossConfig.target}-gcc --static init.c -o init
    gen_init_cpio init_cpio_list.txt > init.cpio.gz
    mkimage -A arm -T ramdisk -d init.cpio.gz initrd.img
  '';

  installPhase = ''
    mkdir -p $out
    mv * $out
  '';
}
