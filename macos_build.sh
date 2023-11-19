#!/bin/zsh

# exit on error
set -e

easy_install --user pyyaml==5.4.1 

git clone -q https://github.com/Microsoft/vcpkg.git

if [ -v VCPKG_COMMIT_HASH ]; then
  echo "Using pinned vcpkg commit: ${VCPKG_COMMIT_HASH}"
  pushd vcpkg
  git checkout -q $VCPKG_COMMIT_HASH
  popd
fi

vcpkg/bootstrap-vcpkg.sh

ARM_TRIPLET="--overlay-triplets=. --triplet=arm64-osx-ete"
X64_TRIPLET="--overlay-triplets=. --triplet=x64-osx-ete"
LIBRARIES="openssl discord-rpc libjpeg sdl2"
vcpkg/vcpkg install ${=ARM_TRIPLET} ${=LIBRARIES}
vcpkg/vcpkg install ${=X64_TRIPLET} ${=LIBRARIES}

rsync -ah vcpkg/installed/x64-osx-ete/* universal-osx-ete
for lib in vcpkg/installed/x64-osx-ete/lib/*.dylib; do
    if [ -f "$lib" ] && [ ! -L $lib ]; then
      lib_filename=$(basename "$lib")
      lib_name=$(echo $lib_filename | cut -d'.' -f 1)
      echo "Creating universal (fat) $lib_name"
      lipo -create "vcpkg/installed/x64-osx-ete/lib/$lib_filename" "vcpkg/installed/arm64-osx-ete/lib/$lib_filename" -output "universal-osx-ete/lib/$lib_filename"
    fi
done

(
  cd universal-osx-ete &&
  zip -rXy ../ete-libs-v${version}-universal-macos-dylibs.zip * -x '*/.*'
)