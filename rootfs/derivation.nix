{pkgs, linux}:
pkgs.symlinkJoin {
  name = "rootfs-partition";
  paths = [
    linux.kernel_lib
  ];
}
