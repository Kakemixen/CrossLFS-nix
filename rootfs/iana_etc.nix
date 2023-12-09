{env, sources}:

env.mkDerivation rec {
  name = "iana-etc";

  src = sources.iana_etc;

  phases = [
    "unpackPhase"
    "installPhase"
  ];

  unpackPhase = ''
    tar xaf $src
    cd iana*
  '';

  installPhase = ''
    mkdir -p $out/etc

    cp protocols $out/etc
    cp services $out/etc
  '';
}
