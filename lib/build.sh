#!/bin/sh -ex

cd minizip

if [ $MSYSTEM = 'MINGW64' ]; then
  arch=64
else
  arch=32
fi 

prefix=../../bin/Win$arch

sed -i 's/enable_language(C)$/enable_language(C) \nset(CMAKE_FIND_LIBRARY_SUFFIXES .a)/i' CMakeLists.txt

cmake . '-GMSYS Makefiles' \
        "-DMZ_COMPAT=0" \
        "-DMZ_ZLIB=1" \
        "-DMZ_BZIP2=1" \
        "-DMZ_LZMA=1" \
        "-DMZ_PKCRYPT=0" \
        "-DMZ_WZAES=0" \
        "-DMZ_OPENSSL=0" \
        "-DMZ_LIBCOMP=0" \
        "-DMZ_BRG=0" \
        "-DMZ_COMPRESS_ONLY=0" \
        "-DMZ_DECOMPRESS_ONLY=0" \
        "-DMZ_BUILD_TEST=0" \
        "-DMZ_BUILD_UNIT_TEST=0" \
        "-DMZ_BUILD_FUZZ_TEST=0" \
        "-DBUILD_SHARED_LIBS=1" \
        "-DCMAKE_BUILD_TYPE=Release" \
        "-DCMAKE_C_FLAGS=-static-libgcc" \
        "-DCMAKE_INSTALL_PREFIX=${prefix}"
        
mingw32-make install
mingw32-make clean

rm CMakeCache.txt
rm -rf CMakeFiles

dll=libminizip.dll
cp -v --remove-destination $prefix/bin/$dll $prefix/$dll

strip $prefix/$dll

cd ..
