# [WIP] Cross Linux From Scratch (CLFS) in nix

This repo is my attempt at CLFS using nix as a build system.
It is mainly for educational purposes, but the end goal is a usable system along with a somewhat ergonomic environment for further development.

This README talks about the different parts of the project, focusing on pitfalls I fell into. It also contains notes for myself, as long as the project is unfinished

## HOWTO

	nix-build -> flash SD-card -> UART root shell

Generate the default output with `nix-build`. This builds a disk image (`.img`) that can be flashed to a storage medium, and booted from. 

You can also specify other derivations with `nix-build -A debug.<derivation>`. There's probably a way to list the possible attributes, but I don't know of anything except reading the derivations.

## Supported HW

 * Raspberry pi 3 A+

Currently, everything reladed to HW configs is hardcoded. Figuring out how to deal with this is something I'll get to eventually.

## Toolchain

The toolchain is built from source, it's nice to not have to think too much about isolation from host OS.

### Pitfalls

 * Nix GCC wrapper by default adds several hardening flags. Of importance here is `-Wformat-security`, as one cannot compile GCC with that flag.
   * the `hardeningDisable` derivation property can remove such flags, allowing to compile the compiler.
 * Setting up the nix wrapper with `wrapCCWith` doesn't work properly if the platforms in the stdenv is not set properly.
   * the `override` functionality is nice here, so that we can use `stdenv` as a base.
   * Without the wrapper, finding the required output of previous derivation requires very hacky hacks.
 * Keeping in mind that one should be careful with subdirectories of `$out`, it impacts the generated nix path.
   * E.g. only derivations with an `$out/include` are included in the `NIX_CFLAGS_COMPILE` env-var, adding them to the include path.

## Booting the kernel

With a working toolchain, this was the easy part.
There is currently not any customization.

No initramfs, so it boots directly to the rootfs on the SD-card.

## [WIP] Rootfs

It runs the init-program just fine, the debug-led on the rpi3 blinks, but everything seems to work well, I'll deal with it later.

Running the kernel with `init=/bin/sh` doesn't work, as the sysem seems to just hang. Could just be that it needs some initialization,
which is done by the clfs bootscripts, so perhaps using an initramfs could solve this?

### Pitfalls

 * When merging the rootfs to format the partitions with is, the nix web symlinks is difficult to work with.
   * Ended up creating a script to follow symlinks for links to `/nix/store`, as we want to keep the relative symlinks that will work on the system.
 * When creating binaries for the system, you may end up with the cross-compiled binaries shadowing binaries for your system.
 * When joining symlinks, directory-links are not merged.
   * So make sure all relevant diretories are "true" diretories, and only files are symlinked.
