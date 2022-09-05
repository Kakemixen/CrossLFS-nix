{fetchurl}:
rec {
  rpi_hash="ecc243c52789f4d8e837c7300b6effb059dc18c0";

  bootcode_bin = fetchurl {
    url = "https://github.com/raspberrypi/firmware/raw/${rpi_hash}/boot/bootcode.bin";
    sha256 = "1zsjdqny93dqk7hx9zr1gs095jfl351j941kfdbzg1f4c4m5m389";
  };
  start_elf = fetchurl {
    url = "https://github.com/raspberrypi/firmware/raw/${rpi_hash}/boot/start.elf";
    sha256 = "1k5dw798f242lvb313j3hzkxaggp7fg2102d1dr3rbp23clagd4s";
  };
  fixup_dat = fetchurl {
    url = "https://github.com/raspberrypi/firmware/raw/${rpi_hash}/boot/fixup.dat";
    sha256 = "1022cn1ypizsyrf0x7cd08zk6garf3aask89x384ckx2j1gh0znh";
  };
}
