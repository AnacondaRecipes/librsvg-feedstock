#! /bin/bash
set -ex

if [[ "$(uname)" == "Darwin" ]]; then
  # Fix locale issues on macOS for docutils/rst2man
  export LC_ALL=en_US.UTF-8
  export LANG=en_US.UTF-8
fi

# Get an updated config.sub and config.guess
cp $BUILD_PREFIX/share/gnuconfig/config.* .

export PKG_CONFIG_PATH_FOR_BUILD=$BUILD_PREFIX/lib/pkgconfig
export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:$BUILD_PREFIX/lib/pkgconfig

if [ -n "${XDG_DATA_DIRS}" ]; then
  export XDG_DATA_DIRS=${XDG_DATA_DIRS}:$PREFIX/share:$BUILD_PREFIX/share
else
  export XDG_DATA_DIRS=$PREFIX/share:$BUILD_PREFIX/share
fi

# https://github.com/rust-lang/cargo/issues/10583#issuecomment-1129997984
export CARGO_NET_GIT_FETCH_WITH_CLI=true

configure_args=(
    --disable-Bsymbolic
    --disable-static
    --enable-pixbuf-loader=yes
    --enable-introspection=yes
)

export RUST_TARGET=$CARGO_BUILD_TARGET
unset CARGO_BUILD_TARGET

./configure --prefix=$PREFIX "${configure_args[@]}" || { cat config.log ; exit 1 ; }
make -j$CPU_COUNT
make install

rm -rf $PREFIX/share/gtk-doc

