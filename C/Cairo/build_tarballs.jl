# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder
name = "Cairo"
version = v"1.14.12"

sources = [
    "https://www.cairographics.org/releases/cairo-1.14.12.tar.xz" =>
    "8c90f00c500b2299c0a323dd9beead2a00353752b2092ead558139bd67f7bf16",
    "./bundled"
]

# Bash recipe for building across all platforms
script = raw"""
cd $WORKSPACE/srcdir/cairo-*/

LDFLAGS="${LDFLAGS} -L${prefix}/lib"
# TODO: find out why we need to manually add "${prefix}/include/freetype2",
# the pkg-config file for freetype2 should already have this information.
CFLAGS="-I${prefix}/include -I${prefix}/include/freetype2"

if [[ "${target}" == *-apple-* ]]; then
    BACKEND_OPTIONS="--enable-quartz --enable-quartz-image --disable-xcb --disable-xlib"
elif [[ "${target}" == *-mingw* ]]; then
    BACKEND_OPTIONS="--enable-win32 --disable-xcb --disable-xlib"
elif [[ "${target}" == *-linux-* ]] || [[ "${target}" == *freebsd* ]]; then
    BACKEND_OPTIONS="--enable-xlib --enable-xcb --enable-xlib-xcb"
fi

# There is a mess with the version of freetype2.  The following patch changes
# the required version to the one that is actually found by pkg-config.
atomic_patch -p1 ../patches/configure.ac.patch
./autogen.sh --prefix=${prefix} --host=${target}
./configure --prefix=${prefix} --host=${target} \
    --disable-static \
    --enable-ft \
    --enable-tee \
    --disable-dependency-tracking \
    ${BACKEND_OPTIONS}
make -j${nproc}
make install
"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = supported_platforms()

# The products that we will ensure are always built
products(prefix) = [
    LibraryProduct(prefix, "libcairo", :libcairo),
]

# Dependencies that must be installed before this package can be built
dependencies = [
    "https://github.com/bicycle1885/ZlibBuilder/releases/download/v1.0.4/build_Zlib.v1.2.11.jl",
    "https://github.com/JuliaIO/LibpngBuilder/releases/download/v1.0.3/build_libpng.v1.6.37.jl",
    "https://github.com/JuliaPackaging/Yggdrasil/releases/download/Pixman-v0.36.0-0/build_Pixman.v0.36.0.jl",
    "https://github.com/JuliaGraphics/FreeTypeBuilder/releases/download/v2.9.1-4/build_FreeType2.v2.10.0.jl",
    "https://github.com/JuliaPackaging/Yggdrasil/releases/download/Bzip2-v1.0.6-2/build_Bzip2.v1.0.6.jl",
    "https://github.com/giordano/Yggdrasil/releases/download/Cairo-v1.14.12/build_X11.v1.6.8.jl",
    "https://github.com/giordano/Yggdrasil/releases/download/Cairo-v1.14.12/build_LZO.v2.10.0.jl",
    "https://github.com/giordano/Yggdrasil/releases/download/Cairo-v1.14.12/build_Libuuid.v2.34.0.jl",
    "https://github.com/giordano/Yggdrasil/releases/download/Cairo-v1.14.12/build_Expat.v2.2.7.jl",
    "https://github.com/giordano/Yggdrasil/releases/download/Cairo-v1.14.12/build_Fontconfig.v2.13.1.jl",
]


# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies)
