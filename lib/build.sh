#!/bin/sh -ex

mz_ver=4.2.2

cd minizip

if [ "${MSYSTEM}" = 'MINGW64' ]; then
  mz_arch=64
else
  mz_arch=32
fi 

mz_dll=libminizip-ng.dll

prefix=../../bin/Win$mz_arch

rm -rf "${prefix:?}"/bin
rm -rf "${prefix:?}"/include
rm -rf "${prefix:?}"/lib
rm -rf "${prefix:?}"/share
rm -rf "${prefix:?}"/$mz_dll

cmake . '-GMSYS Makefiles' \
        "-DMZ_COMPAT=0" \
        "-DMZ_ZLIB=1" \
        "-DMZ_BZIP2=1" \
        "-DMZ_LZMA=1" \
        "-DMZ_PPMD=0" \
        "-DMZ_ZSTD=1" \
        "-DMZ_PKCRYPT=0" \
        "-DMZ_WZAES=0" \
        "-DMZ_OPENSSL=0" \
        "-DMZ_LIBBSD=0" \
        "-DMZ_LIBCOMP=0" \
        "-DMZ_ICONV=0" \
        "-DMZ_COMPRESS_ONLY=0" \
        "-DMZ_DECOMPRESS_ONLY=0" \
        "-DMZ_FILE32_API=0" \
        "-DMZ_BUILD_TESTS=0" \
        "-DMZ_BUILD_UNIT_TESTS=0" \
        "-DMZ_BUILD_FUZZ_TESTS=0" \
        "-DMZ_CODE_COVERAGE=0" \
        "-DMZ_SANITIZER=0" \
        "-DMZ_FETCH_LIBS=1" \
        "-DMZ_FORCE_FETCH_LIBS=0" \
        "-DBUILD_SHARED_LIBS=1" \
        "-DCMAKE_BUILD_TYPE=Release" \
        "-DCMAKE_C_FLAGS=-static-libgcc" \
        "-DCMAKE_INSTALL_PREFIX=${prefix}" 
        
mingw32-make install
mingw32-make clean

rm CMakeCache.txt
rm -rf CMakeFiles

cd "${prefix}"

strip -v --strip-debug --strip-unneeded ./bin/$mz_dll

echo 'bin/*.*' > list.txt
echo 'include/*.*' >> list.txt
echo 'lib/*.*' >> list.txt

7z a -tzip ../libminizip-$mz_ver-win$mz_arch-mingw.zip @list.txt

rm -rf list.txt

cp -v --remove-destination ./bin/$mz_dll ./$mz_dll

cd ..
