#!/bin/bash

set -e

patch -d ffmpeg -p1 < patches/ffmpeg/0001-compilation-magic.patch
# 0002-compilation-magic-2.patch is intentionally NOT applied to the ffmpeg
# SOURCE tree (it strips function bodies needed for linking). Instead we
# sanitize separate INSTALLED copies below for C++17 app consumers.

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

cp ffmpeg/libavcodec/mathops.h ffmpeg/build/arm64-v8a/include/libavcodec/mathops.h
cp ffmpeg/libavcodec/mathops.h ffmpeg/build/armeabi-v7a/include/libavcodec/mathops.h
cp ffmpeg/libavcodec/mathops.h ffmpeg/build/x86/include/libavcodec/mathops.h
cp ffmpeg/libavcodec/mathops.h ffmpeg/build/x86_64/include/libavcodec/mathops.h

cp ffmpeg/libavutil/intmath.h ffmpeg/build/arm64-v8a/include/libavutil/intmath.h
cp ffmpeg/libavutil/intmath.h ffmpeg/build/armeabi-v7a/include/libavutil/intmath.h
cp ffmpeg/libavutil/intmath.h ffmpeg/build/x86/include/libavutil/intmath.h
cp ffmpeg/libavutil/intmath.h ffmpeg/build/x86_64/include/libavutil/intmath.h

# --- Sanitize INSTALLED copies for C++17 app consumers ---
# (the ffmpeg source tree itself is left untouched)
for ARCH_DIR in arm64-v8a armeabi-v7a x86 x86_64; do
	INC="ffmpeg/build/${ARCH_DIR}/include/libavcodec"
	GB="$INC/get_bits.h"
	GOLOMB="$INC/golomb.h"
	VLC="$INC/vlc.h"
	PUTBITS="$INC/put_bits.h"
	BYTESTREAM="$INC/bytestream.h"

	# 'register' is invalid in C++17; harmless to drop everywhere.
	for f in "$GB" "$GOLOMB" "$VLC" "$PUTBITS" "$BYTESTREAM"; do
		sed -i 's/\bregister //g' "$f"
	done

	# mathops.h (and internal headers it pulls in, e.g. libavutil/reverse.h)
	# are not installed publicly. We provide fallback macros ourselves, so
	# just neutralize the include wherever it appears.
	for f in "$GB" "$GOLOMB" "$VLC" "$PUTBITS" "$BYTESTREAM"; do
		sed -i 's|#include "mathops.h"|// #include "mathops.h" (removed for public/C++ consumers)|' "$f"
	done

	# Portable fallbacks for macros normally supplied by FFmpeg's internal
	# arch-specific mathops headers. Inserted once into get_bits.h; golomb.h
	# etc. pick them up transitively since they #include get_bits.h.
	sed -i '/#include <stdint.h>/a \
#include <limits.h>\
#ifndef NEG_USR32\
#   define NEG_USR32(a,s) (((uint32_t)(a))>>(32-(s)))\
#endif\
#ifndef NEG_SSR32\
#   define NEG_SSR32(a,s) (((int32_t)(a))>>(32-(s)))\
#endif\
#ifndef sign_extend\
static inline int sign_extend(int val, unsigned bits) {\
    unsigned shift = 8 * sizeof(int) - bits;\
    union { unsigned u; int s; } v = { (unsigned) val << shift };\
    return v.s >> shift;\
}\
#endif\
#ifndef zero_extend\
static inline unsigned zero_extend(unsigned val, unsigned bits) {\
    return (val << ((8 * sizeof(int)) - bits)) >> ((8 * sizeof(int)) - bits);\
}\
#endif\
#ifndef SUINT\
#   define SUINT unsigned\
#endif\
#ifndef MASK_ABS\
#   define MASK_ABS(mask, level) do { mask = level >> 31; level = (level ^ mask) - mask; } while (0)\
#endif\
#ifndef FASTDIV\
#   define FASTDIV(a,b) ((a)/(b))\
#endif' "$GB"
done
