{fetchurl}:
rec {
  busybox_version = "1.35.0";
  busybox = fetchurl {
    url = "https://busybox.net/downloads/busybox-${busybox_version}.tar.bz2";
    sha256 = "1556hfgw32xf226dd138gfq0z1zf4r3f8naa9wrqld2sqd2b5vps";
  };
}
