#!/bin/bash

set -e

patch -d ffmpeg -p1 < patches/ffmpeg/0001-compilation-magic.patch
# NOTE: 0002-compilation-magic-2.patch is intentionally NOT applied.
# It strips real function bodies (get_xbits, show_bits, get_vlc2, etc.)
# out of get_bits.h, which breaks linking on modern NDK/clang.
# Skipping it keeps get_bits.h intact with all its original includes
# and function implementations, which is what we actually need.

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

cp ffmpeg/libavcodec/put_bits.h ffmpeg/build/arm64-v8a/include/libavcodec/put_bits.h
cp ffmpeg/libavcodec/put_bits.h ffmpeg/build/armeabi-v7a/include/libavcodec/put_bits.h
cp ffmpeg/libavcodec/put_bits.h ffmpeg/build/x86/include/libavcodec/put_bits.h
cp ffmpeg/libavcodec/put_bits.h ffmpeg/build/x86_64/include/libavcodec/put_bits.h

cp ffmpeg/libavutil/intmath.h ffmpeg/build/arm64-v8a/include/libavutil/intmath.h
cp ffmpeg/libavutil/intmath.h ffmpeg/build/armeabi-v7a/include/libavutil/intmath.h
cp ffmpeg/libavutil/intmath.h ffmpeg/build/x86/include/libavutil/intmath.h
cp ffmpeg/libavutil/intmath.h ffmpeg/build/x86_64/include/libavutil/intmath.h
