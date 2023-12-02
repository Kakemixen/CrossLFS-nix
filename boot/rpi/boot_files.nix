{stdenv, fetchurl, callPackage, uboot_tools}:
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
      ./files/config.txt
      ./files/cmdline.txt
      ./files/boot.txt
    ];

    phases = [
      "unpackPhase"
      "buildPhase"
      "installPhase"
    ];

    nativeBuildInputs = [
      uboot_tools
    ];

    unpackPhase = ''
      for src in $srcs
      do
        #get filename without nix hash
        name=$(echo $src | awk -F- '{ print $2}')

        cp -v $src $name
      done
    '';

    buildPhase = ''
      mkimage -T script -n 'CLFS script' -d boot.txt boot.scr
      rm boot.txt
    '';

    installPhase = ''
      mkdir -p $out
      mv * $out
    '';
  }
