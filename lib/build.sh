#!/bin/sh -ex

cd minizip

if [ $MSYSTEM = 'MINGW64' ]; then
  arch=64
else
  arch=32
fi 

dll=libminizip.dll

prefix=../../bin/Win$arch

rm -rf $prefix/bin
rm -rf $prefix/include
rm -rf $prefix/lib
rm -rf $prefix/share
rm -rf $prefix/$dll

sed -i 's/enable_language(C)$/enable_language(C) \nset(CMAKE_FIND_LIBRARY_SUFFIXES .a)/i' CMakeLists.txt

sed -i 's/set(ZSTD_TARGET libzstd_shared)/set(ZSTD_TARGET libzstd_static)/i' CMakeLists.txt

cmake . '-GMSYS Makefiles' \
        "-DMZ_COMPAT=0" \
        "-DMZ_ZLIB=1" \
        "-DMZ_BZIP2=1" \
        "-DMZ_LZMA=1" \
        "-DMZ_ZSTD=0" \
        "-DMZ_PKCRYPT=0" \
        "-DMZ_WZAES=0" \
        "-DMZ_OPENSSL=0" \
        "-DMZ_LIBBSD=0" \
        "-DMZ_LIBCOMP=0" \
        "-DMZ_BRG=0" \
        "-DMZ_COMPRESS_ONLY=0" \
        "-DMZ_DECOMPRESS_ONLY=0" \
        "-DMZ_BUILD_TEST=0" \
        "-DMZ_BUILD_UNIT_TEST=0" \
        "-DMZ_BUILD_FUZZ_TEST=0" \
        "-DZLIB_FORCE_FETCH=0" \
        "-DZSTD_FORCE_FETCH=1" \
        "-DBUILD_SHARED_LIBS=1" \
        "-DCMAKE_BUILD_TYPE=Release" \
        "-DCMAKE_C_FLAGS=-static-libgcc" \
        "-DCMAKE_INSTALL_PREFIX=${prefix}"
        
mingw32-make install
mingw32-make clean

rm CMakeCache.txt
rm -rf CMakeFiles

cd $prefix

strip -v --strip-debug --strip-unneeded ./bin/$dll

echo 'bin/*.*' > list.txt
echo 'include/*.*' >> list.txt
echo 'lib/*.*' >> list.txt

7z a -tzip ../libminizip-2.10.0-win$arch-mingw.zip @list.txt

rm -rf list.txt

cp -v --remove-destination ./bin/$dll ./$dll

cd ..
