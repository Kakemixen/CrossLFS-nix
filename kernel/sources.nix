{fetchurl}:
rec {
  linux_version="linux-5.17";

  linux = fetchurl {
    url = "https://mirrors.edge.kernel.org/pub/linux/kernel/v5.x/${linux_version}.tar.gz";
    sha256 = "1n60y80p57hgsa65dbqmykw07ac9xyyxxcwwmd1rgiq9ngldb2ws";
  };
}
