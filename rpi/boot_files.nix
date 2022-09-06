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
    ];

    phases = [
      "installPhase"
    ];

    installPhase = ''
      mkdir -p $out/boot
      for src in $srcs
      do
        #get filename without nix hash
        name=$(echo $src | awk -F- '{ print $2}')

        cp $src $out/boot/$name
      done
    '';
  }