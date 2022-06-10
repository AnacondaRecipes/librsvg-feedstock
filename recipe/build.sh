#! /bin/bash
set -ex

# Get an updated config.sub and config.guess
cp $BUILD_PREFIX/share/gnuconfig/config.* .

export XDG_DATA_DIRS=${XDG_DATA_DIRS}:$PREFIX/share:$BUILD_PREFIX/share

configure_args=(
    --disable-Bsymbolic
    --disable-static
    --enable-pixbuf-loader=yes
    --enable-introspection=yes
)

export PKG_CONFIG_PATH_FOR_BUILD=$BUILD_PREFIX/lib/pkgconfig
export PKG_CONFIG_PATH=${PKG_CONFIG_PATH:-}:${PREFIX}/lib/pkgconfig:$BUILD_PREFIX/$BUILD/sysroot/usr/lib64/pkgconfig:$BUILD_PREFIX/$BUILD/sysroot/usr/share/pkgconfig

export RUST_TARGET=$CARGO_BUILD_TARGET
unset CARGO_BUILD_TARGET

./configure --prefix=$PREFIX "${configure_args[@]}" || { cat config.log ; exit 1 ; }
make -j$CPU_COUNT
make install

rm -rf $PREFIX/share/gtk-doc
