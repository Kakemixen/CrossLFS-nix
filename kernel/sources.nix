{fetchurl}:
rec {
  linux_version="linux-5.19.7";

  linux = fetchurl {
    url = "https://mirrors.edge.kernel.org/pub/linux/kernel/v5.x/${linux_version}.tar.gz";
    sha256 = "0vqzr7v9zw4k34cf5wqzi96xgjzxwm36bmdjivhg8p5yfy5ml3cr";
  };
}
