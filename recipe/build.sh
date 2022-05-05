#! /bin/bash
set -ex

# Get an updated config.sub and config.guess
cp $BUILD_PREFIX/share/gnuconfig/config.* .

export XDG_DATA_DIRS=${XDG_DATA_DIRS}:$PREFIX/share

configure_args=(
    --disable-Bsymbolic
    --disable-static
    --enable-pixbuf-loader=yes
    --enable-introspection=yes
    --without-ran
)

if [[ $target_platform == osx-* ]] ; then
  # Workaround for https://gitlab.gnome.org/GNOME/librsvg/-/issues/545 ; should be removable soon.
  export LDFLAGS="$LDFLAGS -lobjc"
fi

#export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:${CONDA_BUILD_SYSROOT}/usr/lib/pkgconfig:${CONDA_BUILD_SYSROOT}/usr/lib64/pkgconfig:${CONDA_BUILD_SYSROOT}/usr/share/pkgconfig:${BUILD_PREFIX}/x86_64-conda_cos6-linux-gnu/sysroot/lib64/pkgconfig"

export PKG_CONFIG_LIBDIR=${PREFIX}/lib
export RUST_TARGET=$CARGO_BUILD_TARGET
unset CARGO_BUILD_TARGET

./configure --prefix=$PREFIX "${configure_args[@]}"
make -j$CPU_COUNT
make install
# It's not clear why the following is not installed by the build system
cp gdk-pixbuf-loader/.libs/libpixbufloader-svg.so $PREFIX/lib/gdk-pixbuf-2.0/2.10.0/loaders

rm -rf $PREFIX/share/gtk-doc
