{stdenv, fetchurl, callPackage}:
let
  sources = callPackage ./sources.nix {
    fetchurl = fetchurl;
  };
in
  stdenv.mkDerivation {
    name = "rpi-boot-files";

    srcs = [
      sources.bootcode_bin
      sources.start_elf
      sources.fixup_dat
      ./files/uboot.env
      ./files/config.txt
      ./files/cmdline.txt
    ];

    phases = [
      "installPhase"
    ];

    installPhase = ''
      mkdir -p $out
      for src in $srcs
      do
        #get filename without nix hash
        name=$(echo $src | awk -F- '{ print $2}')

        cp -v $src $out/$name
      done
    '';
  }
