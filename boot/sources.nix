{fetchurl}:
rec {
  uboot_rev = "e092e3250270a1016c877da7bdd9384f14b1321e";
  uboot = fetchurl {
    url = "https://github.com/u-boot/u-boot/archive/${uboot_rev}.tar.gz";
    sha256 = "0iqnmn87zisgb2wz8w7wy7bkf5f30p8hcxa1zpn7lnxniy3c21a8";
  };
}
