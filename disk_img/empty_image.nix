{env, parted, dosfstools, e2fsprogs, mtools, bootfs, rootfs}:
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
    mtools
    bootfs
    rootfs
  ];

  bootfs=bootfs;
  rootfs=rootfs;
  buildPhase = ''
    dd if=/dev/zero of=clfs.img bs=1k count=2000000

    parted --script clfs.img mklabel msdos
    parted --script clfs.img mkpart primary fat32 1MiB 301MiB
    parted --script clfs.img mkpart primary ext4 301MiB 100%


    extract_partition() {
      rootfile=$1
      partnum=$2
      partfile=$3

      read pstart psize < <( LANG=C parted -s $rootfile unit B print | sed 's/B//g' |
          awk -v P=$partnum '/^Number/{start=1;next}; start {if ($1==P) {print $2, $4}}' )

      pstart_sector=$(($pstart / 512))
      psize_sector=$(($psize / 512))

      dd bs=512 if=$rootfile of=$partfile skip=$pstart_sector count=$psize_sector
    }

    merge_partition() {
      rootfile=$1
      partnum=$2
      partfile=$3

      read pstart psize < <( LANG=C parted -s $rootfile unit B print | sed 's/B//g' |
          awk -v P=$partnum '/^Number/{start=1;next}; start {if ($1==P) {print $2, $4}}' )

      pstart_sector=$(($pstart / 512))
      psize_sector=$(($psize / 512))

      dd conv=notrunc bs=512 if=$partfile of=$rootfile seek=$pstart_sector count=$psize_sector
    }


    # boot
    extract_partition clfs.img 1 boot.part
    mkfs.vfat -F 32 -n boot boot.part
    mcopy $bootfs/* -sb -i boot.part ::
    merge_partition clfs.img 1 boot.part
    rm boot.part

    # rootfs
    extract_partition clfs.img 2 rootfs.part
    mkdir rootfs
    mkfs.ext4 -F rootfs.part -d $rootfs
    merge_partition clfs.img 2 rootfs.part
    rm rootfs.part
  '';

  installPhase = ''
    cp clfs.img $out
  '';
}
