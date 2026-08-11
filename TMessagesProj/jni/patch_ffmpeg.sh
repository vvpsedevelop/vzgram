#!/bin/bash
 
set -e
 
patch -d ffmpeg -p1 < patches/ffmpeg/0001-compilation-magic.patch
# NOTE: 0002-compilation-magic-2.patch is intentionally NOT applied to the
# ffmpeg SOURCE tree. It strips real function bodies (get_xbits, show_bits,
# get_vlc2, etc.) which breaks linking of libavcodec.a/libavformat.a on
# modern NDK/clang. FFmpeg's own build must compile the untouched header.
#
# The app's own C++ files (gifvideo.cpp, TgNetWrapper.cpp, ...) also
# #include this same header directly though, and being C++17 they choke on
# the C-only 'register' keyword and on macros (NEG_USR32, sign_extend, ...)
# that only resolve inside FFmpeg's own internal build. So we install a
# separately sanitized COPY for external/app consumption below, while the
# ffmpeg source tree itself stays untouched.
 
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
 
# --- Sanitize the INSTALLED copies of get_bits.h for C++17 app consumers ---
# (the ffmpeg source tree itself is left untouched, see note above)
for ARCH_DIR in arm64-v8a armeabi-v7a x86 x86_64; do
	GB="ffmpeg/build/${ARCH_DIR}/include/libavcodec/get_bits.h"
 
	# 'register' is invalid in C++17; harmless to drop as a storage class.
	sed -i 's/\bregister //g' "$GB"
 
	# Provide portable fallbacks for macros that normally come from
	# FFmpeg's internal, non-installed arch-specific mathops headers.
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
#endif' "$GB"
done
