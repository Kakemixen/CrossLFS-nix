{pkgs, env, linux}:
let
  boot_mount = env.mkDerivation {
    name = "true";

    phases = [ "installPhase" ];

    installPhase = ''
      mkdir -p $out/boot
    '';
  };
in
pkgs.symlinkJoin {
  name = "rootfs-partition";
  paths = [
    linux.kernel_lib
    boot_mount
  ];
}
