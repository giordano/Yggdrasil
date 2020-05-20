# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder

name = "HDF4"
version = v"4.2.15"

# Collection of sources required to build HDF4
sources = [
    ArchiveSource("https://support.hdfgroup.org/ftp/HDF/releases/HDF4.2.15/src/hdf-4.2.15.tar.bz2",
                  "bde035ef5a1cd5fdbd0a7f1fa5c17e98bbd599300189ac4d234f16e9bb7bcb12"),
    DirectorySource("./bundled"),
]

# Bash recipe for building across all platforms
script = raw"""
cd ${WORKSPACE}/srcdir/hdf-*
atomic_patch -p1 "${WORKSPACE}/srcdir/patches/link-mhdf-to-hdf.patch"
atomic_patch -p1 "${WORKSPACE}/srcdir/patches/no-ncgen.patch"
update_configure_scripts
./configure --prefix=${prefix} \
    --build=${MACHTYPE} \
    --host=${target} \
    --enable-shared \
    --disable-static \
    --enable-production \
    --disable-fortran
make -j${nproc}
make install
"""

platforms = [
    # Linux(:i686, libc=:glibc),
    Linux(:x86_64, libc=:glibc),
    # Linux(:aarch64, libc=:glibc),
    # Linux(:armv7l, libc=:glibc, call_abi=:eabihf),
    # Linux(:powerpc64le, libc=:glibc),
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
products = Product[
    LibraryProduct("libdf", :libdf),
    LibraryProduct("libmfhdf", :libmfhdf),
    ExecutableProduct("gif2hdf", :gif2hdf),
    ExecutableProduct("hdf24to8", :hdf24to8),
    ExecutableProduct("hdf2gif", :hdf2gif),
    ExecutableProduct("hdf2jpeg", :hdf2jpeg),
    ExecutableProduct("hdf8to24", :hdf8to24),
    ExecutableProduct("hdfcomp", :hdfcomp),
    ExecutableProduct("hdfed", :hdfed),
    ExecutableProduct("hdfimport", :hdfimport),
    ExecutableProduct("hdfls", :hdfls),
    ExecutableProduct("hdfpack", :hdfpack),
    ExecutableProduct("hdftopal", :hdftopal),
    ExecutableProduct("hdftor8", :hdftor8),
    ExecutableProduct("hdfunpac", :hdfunpac),
    ExecutableProduct("hdiff", :hdiff),
    ExecutableProduct("hdp", :hdp),
    ExecutableProduct("hrepack", :hrepack),
    ExecutableProduct("jpeg2hdf", :jpeg2hdf),
    ExecutableProduct("ncdump", :ncdump),
    ExecutableProduct("paltohdf", :paltohdf),
    ExecutableProduct("r8tohdf", :r8tohdf),
    ExecutableProduct("ristosds", :ristosds),
    ExecutableProduct("vmake", :vmake),
    ExecutableProduct("vshow", :vshow),
]

# Dependencies that must be installed before this package can be built
dependencies = [
    Dependency("JpegTurbo_jll"),
    Dependency("Zlib_jll"),
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies)
