{env, parted, dosfstools, e2fsprogs}:
env.mkDerivation {
  name = "disk-image";

  phases = [
    "buildPhase"
    "installPhase"
  ];

  nativeBuildInputs = [
    parted
    dosfstools
    e2fsprogs
  ];

  buildPhase = ''
    dd if=/dev/zero of=clfs.img bs=1k count=2000000

    parted --script clfs.img mklabel msdos
    parted --script clfs.img mkpart primary fat32 1MiB 301MiB
    parted --script clfs.img mkpart primary ext4 301MiB 100%

    format_partition() {
      rootfile=$1
      partnum=$2
      mkfscmd=$3

      read pstart psize < <( LANG=C parted -s $rootfile unit B print | sed 's/B//g' |
          awk -v P=$partnum '/^Number/{start=1;next}; start {if ($1==P) {print $2, $4}}' )

      pstart_sector=$(($pstart / 512))
      psize_sector=$(($psize / 512))

      dd bs=512 if=$rootfile of=tmp.img skip=$pstart_sector count=$psize_sector
      $mkfscmd tmp.img
      dd conv=notrunc bs=512 if=tmp.img of=$rootfile seek=$pstart_sector count=$psize_sector
      rm tmp.img
    }

    # boot
    format_partition clfs.img 1 "mkfs.vfat -F 32 -n boot"

    # rootfs
    format_partition clfs.img 2 "mkfs.ext4 -F"
  '';

  installPhase = ''
    cp clfs.img $out
  '';
}
