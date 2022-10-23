# [WIP] Cross Linux From Scratch (CLFS) in nix

This repo is my attempt at CLFS using nix as a build system.
It is mainly for educational purposes, but the end goal is a usable system along with a somewhat ergonomic environment for further development.

## HOWTO

	nix-build -> flash SD-card -> UART root shell

Generate the default output with `nix-build`. This builds a disk image (`.img`) that can be flashed to a storage medium, and booted from. 

You can also specify other derivations with `nix-build -A debug.<derivation>`. There's probably a way to list the possible attributes, but I don't know of anything except reading the derivations.

## Supported HW

 * Raspberry pi 3 A+

Currently, everything reladed to HW configs is hardcoded. Figuring out how to deal with this is something I'll get to eventually.
