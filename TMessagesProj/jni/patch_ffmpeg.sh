#!/bin/bash

set -e

patch -d ffmpeg -p1 < patches/ffmpeg/0001-compilation-magic.patch
patch -d ffmpeg -p1 < patches/ffmpeg/0002-compilation-magic-2.patch

# Fix: restore headers needed by newer clang (NDK 21+) that treats
# implicit function declarations as hard errors instead of warnings.
sed -i '/#ifndef NEG_USR32/i \
#include <limits.h>\
#include "libavutil/common.h"\
#include "libavutil/intreadwrite.h"\
#include "libavutil/log.h"\
#include "libavutil/avassert.h"\
#include "libavutil/error.h"\
#include "mathops.h"\
#ifndef AV_INPUT_BUFFER_PADDING_SIZE\
#   define AV_INPUT_BUFFER_PADDING_SIZE 64\
#endif' ffmpeg/libavcodec/get_bits.h

function cp {
	install -D $@
}

cp ffmpeg/libavformat/dv.h ffmpeg/build/arm64-v8a/include/libavformat/dv.h
cp ffmpeg/libavformat/isom.h ffmpeg/build/arm64-v8a/include/libavformat/isom.h
cp ffmpeg/libavformat/dv.h ffmpeg/build/armeabi-v7a/include/libavformat/dv.h
cp ffmpeg/libavformat/isom.h ffmpeg/build/armeabi-v7a/include/libavformat/isom.h
cp ffmpeg/libavformat/dv.h ffmpeg/build/x86/include/libavformat/dv.h
cp ffmpeg/libavformat/isom.h ffmpeg/build/x86/include/libavformat/isom.h
cp ffmpeg/libavformat/dv.h ffmpeg/build/x86_64/include/libavformat/dv.h
cp ffmpeg/libavformat/isom.h ffmpeg/build/x86_64/include/libavformat/isom.h

cp ffmpeg/libavcodec/bytestream.h ffmpeg/build/arm64-v8a/include/libavcodec/bytestream.h
cp ffmpeg/libavcodec/bytestream.h ffmpeg/build/armeabi-v7a/include/libavcodec/bytestream.h
cp ffmpeg/libavcodec/bytestream.h ffmpeg/build/x86/include/libavcodec/bytestream.h
cp ffmpeg/libavcodec/bytestream.h ffmpeg/build/x86_64/include/libavcodec/bytestream.h

cp ffmpeg/libavcodec/get_bits.h ffmpeg/build/arm64-v8a/include/libavcodec/get_bits.h
cp ffmpeg/libavcodec/get_bits.h ffmpeg/build/armeabi-v7a/include/libavcodec/get_bits.h
cp ffmpeg/libavcodec/get_bits.h ffmpeg/build/x86/include/libavcodec/get_bits.h
cp ffmpeg/libavcodec/get_bits.h ffmpeg/build/x86_64/include/libavcodec/get_bits.h

cp ffmpeg/libavcodec/golomb.h ffmpeg/build/arm64-v8a/include/libavcodec/golomb.h
cp ffmpeg/libavcodec/golomb.h ffmpeg/build/armeabi-v7a/include/libavcodec/golomb.h
cp ffmpeg/libavcodec/golomb.h ffmpeg/build/x86/include/libavcodec/golomb.h
cp ffmpeg/libavcodec/golomb.h ffmpeg/build/x86_64/include/libavcodec/golomb.h

cp ffmpeg/libavcodec/vlc.h ffmpeg/build/arm64-v8a/include/libavcodec/vlc.h
cp ffmpeg/libavcodec/vlc.h ffmpeg/build/armeabi-v7a/include/libavcodec/vlc.h
cp ffmpeg/libavcodec/vlc.h ffmpeg/build/x86/include/libavcodec/vlc.h
cp ffmpeg/libavcodec/vlc.h ffmpeg/build/x86_64/include/libavcodec/vlc.h

cp ffmpeg/libavutil/intmath.h ffmpeg/build/arm64-v8a/include/libavutil/intmath.h
cp ffmpeg/libavutil/intmath.h ffmpeg/build/armeabi-v7a/include/libavutil/intmath.h
cp ffmpeg/libavutil/intmath.h ffmpeg/build/x86/include/libavutil/intmath.h
cp ffmpeg/libavutil/intmath.h ffmpeg/build/x86_64/include/libavutil/intmath.h
