# [WIP] Cross Linux From Scratch (CLFS) in nix

This repo is my attempt at CLFS using nix as a build system.
It is mainly for educational purposes, but the end goal is a usable system along with a somewhat ergonomic environment for further development.
This may or may not be of interest

This README talks about the different parts of the project, focusing on pitfalls I fell into. It also contains notes for myself, as long as the project is unfinished

## Toolchain

The toolchain is built from source, it's nice to not have to think too much about isolation from host OS.

### Pitfalls

 * Nix GCC wrapper by default adds several hardening flags. Of importance here is `-Wformat-security`, as one cannot compile GCC with that flag.
  * the `hardeningDisable` derivation property can remove such flags, allowing to compile the compiler.
 * Setting up the nix wrapper with `wrapCCWith` doesn't work properly if the platforms is not set properly.
  * the `override` functionality is nice here, so that we can use `stdenv` as a base.
  * Without the wrapper, finding the required output of previous derivation requires very hacky hacks.
 * Keeping in mind that one should be careful with subdirectories of `$out`, it impacts the generated nix path.

## Booting the kernel

Building didn't require an advanced nix toolchain, so was pretty OK.
There is currently not any customization.

It is able to run the rootfs the rpi-images come with. Overriding the boot partition with these files work well.
The debug led flashes, but everything seems OK?

## [WIP] Rootfs

It currently hangs after running the init-program, which is kinda sad.

### Pitfalls

 * When merging the rootfs to format the partitions with is, the nix web symlinks is difficult to work with.
  * Ended up creating a script to follow symlinks for links to `/nix/store`, as we want to keep the relative symlinks that will work on the system.
 * When creating binaries for the system, you may end up with the cross-compiled binaries shadowing binaries for your system.
