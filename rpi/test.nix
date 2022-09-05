{stdenv, boot_partition}:
stdenv.mkDerivation {
  name = "true";

  phases = [
    "installPhase"
  ];

  boot_partition = boot_partition;
  installPhase = ''
    cp -r $boot_partition $out
  '';
}
