#!/bin/sh

# exit on error
set -e

X86_TRIPLET="--overlay-triplets=. --triplet=x86-linux-ete"
LIBRARIES="discord-rpc ijg-libjpeg sdl2"
vcpkg/vcpkg install ${=X86_TRIPLET} ${=LIBRARIES}
