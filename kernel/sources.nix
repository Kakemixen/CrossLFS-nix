{fetchurl}:
rec {
  linux_version="linux-stable_20240423";

  linux = builtins.fetchGit {
    url = "https://github.com/raspberrypi/linux.git";
    name = "rpi-linux";
    ref = "rpi-6.6.y";
    rev = "dda83b1";
  };
}
