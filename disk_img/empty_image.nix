{env, parted}:
env.mkDerivation {
  name = "disk-image";

  phases = [
    "buildPhase"
    "installPhase"
  ];

  nativeBuildInputs = [
    parted
  ];

  buildPhase = ''
    dd if=/dev/zero of=clfs.img bs=1k count=2000000

    parted --script clfs.img mklabel msdos
    parted --script clfs.img mkpart primary fat32 1MiB 301MiB
    parted --script clfs.img mkpart primary ext4 301MiB 100%

    # gpt/EFI does not work for rpi, but keep commented here
    #parted --script clfs.img mklabel gpt
    #parted --script clfs.img mkpart "boot" fat32 1MiB 301MiB
    #parted --script clfs.img mkpart "rootfs" ext4 301MiB 100%
  '';

  installPhase = ''
    cp clfs.img $out
  '';
}
