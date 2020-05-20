# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder

name = "NetCDF"
version = v"3.1.7"

# Collection of sources required to build NetCDF
sources = [
    ArchiveSource("https://anaconda.org/anaconda/libnetcdf/4.7.3/download/linux-64/libnetcdf-4.7.3-hb80b6cc_0.tar.bz2",
                  "b1337e44931363cdca484942f06f054c5dc70c4e179b318ac7a511cd623a060e";
                  unpack_target = "x86_64-linux-gnu"),
    ArchiveSource("https://anaconda.org/anaconda/libnetcdf/4.7.3/download/linux-ppc64le/libnetcdf-4.7.3-hb80b6cc_0.tar.bz2",
                  "964b122ec96e6f2dfaaaf502473cb8c992d220f09bc902ef0960efb9bf3fb7b7";
                  unpack_target = "powerpc64le-linux-gnu"),
    ArchiveSource("https://anaconda.org/anaconda/libnetcdf/4.7.3/download/osx-64/libnetcdf-4.7.3-he3b6227_0.tar.bz2",
                  "0f2e6d20a03bcd9a369e7d17bb0b39701d59ab82504b14fccd5450e4276b8134";
                  unpack_target = "x86_64-apple-darwin14"),
    ArchiveSource("https://anaconda.org/anaconda/libnetcdf/4.7.3/download/win-32/libnetcdf-4.7.3-h1302dcc_0.tar.bz2",
                  "e4f9db07ed23d18f6d5f59cf8014242001af131140b0ebdc97b704815189e585";
                  unpack_target = "i686-w64-mingw32"),
    ArchiveSource("https://anaconda.org/anaconda/libnetcdf/4.7.3/download/win-64/libnetcdf-4.7.3-h1302dcc_0.tar.bz2",
                  "f28c2b3d7fdfbf127803b55aacb6fb3dd9f8e9e9751857060ae324d12e1760f3";
                  unpack_target = "x86_64-w64-mingw32"),
]

# Bash recipe for building across all platforms
script = raw"""
cd "${WORKSPACE}/srcdir/${target}"
rm lib/libnetcdf.a
cp -r bin/ include/ lib/ "${prefix}"
install_license info/licenses/COPYRIGHT
"""

platforms = [
    # Linux(:i686, libc=:glibc),
    Linux(:x86_64, libc=:glibc),
    # Linux(:aarch64, libc=:glibc),
    # Linux(:armv7l, libc=:glibc, call_abi=:eabihf),
    Linux(:powerpc64le, libc=:glibc),
    # Linux(:i686, libc=:musl),
    # Linux(:x86_64, libc=:musl),
    # Linux(:aarch64, libc=:musl),
    # Linux(:armv7l, libc=:musl, call_abi=:eabihf),
    MacOS(:x86_64),
    # FreeBSD(:x86_64),
    Windows(:i686),
    Windows(:x86_64),
]

# The products that we will ensure are always built
products = [
    LibraryProduct("libnetcdf", :libnetcdf),
    ExecutableProduct("nccopy", :nccopy),
    ExecutableProduct("ncdump", :ncdump),
    ExecutableProduct("ncgen",  :ncgen),
    ExecutableProduct("ncgen3", :ncgen3),
]

# Dependencies that must be installed before this package can be built
dependencies = [
    Dependency("HDF4_jll"),
    Dependency("HDF5_jll"),
    Dependency("LibCURL_jll"),
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies)
