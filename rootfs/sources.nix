{fetchurl}:
rec {
  busybox_version = "1.35.0";
  busybox = fetchurl {
    url = "https://busybox.net/downloads/busybox-${busybox_version}.tar.bz2";
    sha256 = "1556hfgw32xf226dd138gfq0z1zf4r3f8naa9wrqld2sqd2b5vps";
  };

  iana_etc_version = "20231117";
  iana_etc = fetchurl {
    url = "https://github.com/Mic92/iana-etc/releases/download/${iana_etc_version}/iana-etc-${iana_etc_version}.tar.gz";
    sha256 = "18dglj4zd21mxbvmn7yrh8yqb77qfsixlv6qapgr10zjw20n8vvy";
  };

  zlib_version = "1.3";
  zlib = fetchurl {
    url = "https://www.zlib.net/zlib-${zlib_version}.tar.gz";
    sha256 = "0gjrz8p70mgkic7mxjh1vqwws4x8z7hq2fhbackvqg81jb1a82zz";
  };

  dropbear_version = "2022.83";
  dropbear = fetchurl {
    url = "https://matt.ucc.asn.au/dropbear/releases/dropbear-${dropbear_version}.tar.bz2";
    sha256 = "0fs495ks354qcfj4k5bwg6m50vbl8az03gjymmqm2jy9zcgi4nmw";
  };

  netplug_version = "1.2.9.2";
  netplug = fetchurl {
    url = "https://www.red-bean.com/~bos/netplug/netplug-${netplug_version}.tar.bz2";
    sha256 = "0kl62h4bj8s4sn5x8g414d3ad9j53gq082kv08x67l6klzcxz02i";
  };
}
